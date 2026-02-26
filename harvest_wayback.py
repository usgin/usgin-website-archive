#!/usr/bin/env python3
"""
harvest_wayback.py — Mirror the usgin.org website from the Wayback Machine.

Creates a self-contained local copy suitable for offline browsing and Zenodo
archival.  Uses only `requests` and `beautifulsoup4` (no extra dependencies).

Phases:
  1. CDX Discovery   – query the Wayback Machine CDX API for all captured URLs
  2. Download         – fetch every URL via the id_ endpoint (clean, no toolbar)
  3. Asset Discovery  – parse HTML/CSS to find additional assets not in CDX
  4. Link Rewriting   – rewrite internal links to relative local paths
  5. Report           – print summary, write manifest.json

Usage:
  python harvest_wayback.py                    # defaults
  python harvest_wayback.py --delay 0.5 -v     # faster, verbose
  python harvest_wayback.py --resume            # resume after interruption
  python harvest_wayback.py --skip-rewrite      # download only, no rewriting
"""

import argparse
import hashlib
import json
import logging
import mimetypes
import os
import re
import shutil
import sys
import time
from collections import defaultdict
from dataclasses import dataclass, field, asdict
from pathlib import Path, PurePosixPath
from typing import Optional
from urllib.parse import (
    urljoin,
    urlparse,
    urlunparse,
    unquote,
    quote,
)

import requests
from bs4 import BeautifulSoup

# ---------------------------------------------------------------------------
# Data classes
# ---------------------------------------------------------------------------

@dataclass
class CdxEntry:
    """One row from the CDX API."""
    urlkey: str
    timestamp: str
    original: str
    mimetype: str
    statuscode: str
    digest: str
    length: str


@dataclass
class HarvestStats:
    """Accumulates statistics for the final report."""
    cdx_total: int = 0
    cdx_after_dedup: int = 0
    downloaded: int = 0
    skipped_resume: int = 0
    asset_discovered: int = 0
    asset_downloaded: int = 0
    rewritten_html: int = 0
    rewritten_css: int = 0
    failures: list = field(default_factory=list)
    bytes_total: int = 0
    by_extension: dict = field(default_factory=lambda: defaultdict(int))


# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

WAYBACK_CDX = "https://web.archive.org/cdx/search/cdx"
WAYBACK_WEB = "https://web.archive.org/web"

EXCLUDED_PATTERNS = [
    re.compile(r"cgi-sys/suspendedpage\.cgi"),
    re.compile(r"user/login"),
    re.compile(r"user/password"),
    re.compile(r"user/register"),
    re.compile(r"search/node"),
    re.compile(r"^mailto:"),
    re.compile(r"^javascript:"),
    re.compile(r"^data:"),
    re.compile(r"^#"),
]

# File extensions that indicate a static asset (not an HTML page)
ASSET_EXTENSIONS = {
    ".css", ".js", ".png", ".jpg", ".jpeg", ".gif", ".svg", ".ico",
    ".woff", ".woff2", ".ttf", ".eot", ".otf",
    ".pdf", ".doc", ".docx", ".xls", ".xlsx", ".ppt", ".pptx",
    ".zip", ".gz", ".tar", ".xml", ".json", ".csv", ".txt",
    ".mp3", ".mp4", ".webm", ".ogg", ".wav",
    ".map", ".swf",
}

logger = logging.getLogger("harvest")

# ---------------------------------------------------------------------------
# Harvester
# ---------------------------------------------------------------------------

class WaybackHarvester:
    def __init__(
        self,
        domain: str = "usgin.org",
        timestamp: str = "20250612",
        output_dir: str = ".",
        delay: float = 1.0,
        max_retries: int = 5,
        verbose: bool = False,
    ):
        self.domain = domain
        self.target_timestamp = timestamp
        self.output_dir = Path(output_dir)
        self.delay = delay
        self.max_retries = max_retries
        self.verbose = verbose
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "usgin-archive-harvester/1.0 (research archival)"
        })
        self.stats = HarvestStats()
        # url_map: normalized original URL -> CdxEntry
        self.url_map: dict[str, CdxEntry] = {}
        # local_map: normalized original URL -> local Path (relative to output_dir)
        self.local_map: dict[str, Path] = {}
        # track which URLs we've already downloaded (for asset rounds)
        self.downloaded_urls: set[str] = set()

    # ------------------------------------------------------------------
    # Phase 1: CDX Discovery
    # ------------------------------------------------------------------

    def _query_cdx_domain(self, url_pattern: str) -> list[CdxEntry]:
        """Query CDX API for a single URL pattern, returning all entries."""
        # Note: we do NOT use closest/sort=closest here because combining
        # those with collapse=urlkey causes the CDX API to hang on large
        # domains.  Instead we fetch all entries (collapsed to one per urlkey)
        # and pick the best timestamp in Python via deduplicate_urls().
        params = {
            "url": url_pattern,
            "output": "json",
            "fl": "urlkey,timestamp,original,mimetype,statuscode,digest,length",
            "filter": "statuscode:200",
            "collapse": "urlkey",
            "limit": "100000",
        }
        resp = self._get_with_retry(WAYBACK_CDX, params=params, timeout=300)
        if resp is None or resp.status_code != 200:
            logger.error("CDX query failed for %s", url_pattern)
            return []
        try:
            rows = resp.json()
        except json.JSONDecodeError:
            logger.error("CDX returned non-JSON for %s", url_pattern)
            return []
        if not rows or len(rows) <= 1:
            return []
        entries = []
        for row in rows[1:]:  # skip header row
            if len(row) >= 7:
                entries.append(CdxEntry(*row[:7]))
        logger.info("  CDX %s: %d entries", url_pattern, len(entries))
        return entries

    def query_cdx(self) -> list[CdxEntry]:
        """Query the CDX API for all captures of the domain."""
        logger.info("Querying CDX API for %s ...", self.domain)
        all_entries: list[CdxEntry] = []

        # The CDX urlkey normalizes www.usgin.org to org,usgin) so both
        # bare and www URLs are returned by the single bare-domain query.
        # Skipping the separate www query avoids intermittent CDX timeouts.
        all_entries.extend(self._query_cdx_domain(f"{self.domain}/*"))

        self.stats.cdx_total = len(all_entries)
        logger.info("CDX total entries (before dedup): %d", len(all_entries))
        return all_entries

    def normalize_url(self, url: str) -> str:
        """Normalize a URL for deduplication."""
        parsed = urlparse(url)
        # Force http scheme, lowercase host, strip :80 port
        scheme = "http"
        host = (parsed.hostname or "").lower().rstrip(".")
        if host.startswith("www."):
            host = host[4:]
        port = parsed.port
        if port == 80:
            port = None
        path = parsed.path or "/"
        # Collapse // in path
        while "//" in path:
            path = path.replace("//", "/")
        # Strip trailing slash for non-root paths
        if path != "/" and path.endswith("/"):
            path = path.rstrip("/")
        netloc = host if port is None else f"{host}:{port}"
        return urlunparse((scheme, netloc, path, "", "", ""))

    def deduplicate_urls(self, entries: list[CdxEntry]) -> dict[str, CdxEntry]:
        """Keep one entry per normalized URL, preferring closest timestamp."""
        url_map: dict[str, CdxEntry] = {}
        target = int(self.target_timestamp)
        for entry in entries:
            norm = self.normalize_url(entry.original)
            if norm in url_map:
                existing_dist = abs(int(url_map[norm].timestamp) - target)
                new_dist = abs(int(entry.timestamp) - target)
                if new_dist < existing_dist:
                    url_map[norm] = entry
            else:
                url_map[norm] = entry
        return url_map

    def filter_urls(self, url_map: dict[str, CdxEntry]) -> dict[str, CdxEntry]:
        """Remove URLs matching exclusion patterns."""
        filtered = {}
        for norm_url, entry in url_map.items():
            path = urlparse(norm_url).path
            full = entry.original
            skip = False
            for pattern in EXCLUDED_PATTERNS:
                if pattern.search(path) or pattern.search(full):
                    skip = True
                    break
            if not skip:
                filtered[norm_url] = entry
        removed = len(url_map) - len(filtered)
        if removed:
            logger.info("Filtered out %d excluded URLs", removed)
        return filtered

    # ------------------------------------------------------------------
    # Phase 2: Download
    # ------------------------------------------------------------------

    def url_to_local_path(self, original_url: str) -> Path:
        """Map an original URL to a local filesystem path."""
        parsed = urlparse(original_url)
        path = unquote(parsed.path or "/")

        # Strip leading slash
        if path.startswith("/"):
            path = path[1:]

        # Root -> index.html
        if not path or path == "":
            return Path("index.html")

        # Check extension
        _, ext = os.path.splitext(path.split("?")[0])

        if ext.lower() in ASSET_EXTENSIONS or ext.lower() in {".html", ".htm"}:
            # Has a recognized extension; use as-is (strip query string)
            clean = path.split("?")[0]
            return Path(clean)

        # No extension or unrecognized — treat as HTML page
        # query string pages get sanitized filename
        if parsed.query:
            safe_query = re.sub(r"[^\w\-.]", "_", parsed.query)
            return Path(path) / f"q_{safe_query}.html"

        # Extensionless path -> directory/index.html
        return Path(path) / "index.html"

    def wayback_url(self, original_url: str, timestamp: str) -> str:
        """Build the id_ Wayback URL for clean content (no toolbar)."""
        return f"{WAYBACK_WEB}/{timestamp}id_/{original_url}"

    def _get_with_retry(
        self, url: str, params: dict = None, stream: bool = False,
        timeout: int = 120,
    ) -> Optional[requests.Response]:
        """HTTP GET with exponential backoff on transient errors."""
        for attempt in range(self.max_retries):
            try:
                resp = self.session.get(
                    url, params=params, stream=stream, timeout=timeout
                )
                if resp.status_code == 200:
                    return resp
                if resp.status_code in (429, 503, 504, 520, 521, 522, 523, 524):
                    wait = (2 ** attempt) + 1
                    logger.warning(
                        "  HTTP %d for %s — retrying in %ds",
                        resp.status_code, url[:120], wait,
                    )
                    time.sleep(wait)
                    continue
                if resp.status_code == 404:
                    logger.debug("  404: %s", url[:120])
                    return None
                logger.warning(
                    "  HTTP %d for %s", resp.status_code, url[:120]
                )
                return None
            except (
                requests.ConnectionError,
                requests.Timeout,
                requests.exceptions.ReadTimeout,
                requests.exceptions.ChunkedEncodingError,
            ) as exc:
                wait = (2 ** attempt) + 1
                logger.warning(
                    "  Connection error for %s: %s — retrying in %ds",
                    url[:120], exc, wait,
                )
                time.sleep(wait)
        logger.error("  Giving up on %s after %d attempts", url[:120], self.max_retries)
        return None

    def download_url(self, original_url: str, timestamp: str) -> Optional[bytes]:
        """Download a single URL from the Wayback Machine."""
        wb_url = self.wayback_url(original_url, timestamp)
        resp = self._get_with_retry(wb_url)
        if resp is None:
            return None
        return resp.content

    def save_file(self, content: bytes, local_path: Path) -> None:
        """Write content to disk, creating directories as needed."""
        full_path = self.output_dir / local_path
        full_path.parent.mkdir(parents=True, exist_ok=True)
        full_path.write_bytes(content)
        size = len(content)
        self.stats.bytes_total += size
        ext = local_path.suffix.lower() or "(none)"
        self.stats.by_extension[ext] += 1

    def download_all_cdx(self, resume: bool = False) -> None:
        """Download all URLs from the CDX results."""
        total = len(self.url_map)
        logger.info("Downloading %d URLs ...", total)
        for i, (norm_url, entry) in enumerate(self.url_map.items(), 1):
            local_path = self.url_to_local_path(entry.original)
            self.local_map[norm_url] = local_path

            full_path = self.output_dir / local_path
            if resume and full_path.exists() and full_path.stat().st_size > 0:
                self.stats.skipped_resume += 1
                self.downloaded_urls.add(norm_url)
                if self.verbose:
                    logger.debug("  [%d/%d] SKIP (exists): %s", i, total, norm_url)
                continue

            content = self.download_url(entry.original, entry.timestamp)
            if content is not None:
                self.save_file(content, local_path)
                self.downloaded_urls.add(norm_url)
                self.stats.downloaded += 1
                if self.verbose:
                    logger.info(
                        "  [%d/%d] %s -> %s (%d bytes)",
                        i, total, norm_url, local_path, len(content),
                    )
            else:
                self.stats.failures.append(
                    {"url": entry.original, "phase": "cdx_download"}
                )
                logger.warning("  [%d/%d] FAILED: %s", i, total, norm_url)

            if self.delay > 0:
                time.sleep(self.delay)

    # ------------------------------------------------------------------
    # Phase 3: Asset Discovery
    # ------------------------------------------------------------------

    def resolve_url(self, ref: str, base_url: str) -> Optional[str]:
        """Resolve a reference relative to a base URL. Returns normalized URL or None."""
        if not ref or not ref.strip():
            return None
        ref = ref.strip()
        # Skip non-HTTP refs
        for pattern in EXCLUDED_PATTERNS:
            if pattern.search(ref):
                return None
        # Resolve relative to base
        absolute = urljoin(base_url, ref)
        if not absolute.startswith(("http://", "https://")):
            return None
        return self.normalize_url(absolute)

    def is_internal(self, url: str) -> bool:
        """Check if a URL is internal to the target domain."""
        parsed = urlparse(url)
        host = (parsed.hostname or "").lower().rstrip(".")
        if host.startswith("www."):
            host = host[4:]
        return host == self.domain

    def parse_html(self, html_bytes: bytes, page_url: str) -> set[str]:
        """Extract internal asset URLs from HTML."""
        refs: set[str] = set()
        try:
            soup = BeautifulSoup(html_bytes, "html.parser")
        except Exception:
            return refs

        # <link href="..."> (CSS, icons, etc.)
        for tag in soup.find_all("link", href=True):
            resolved = self.resolve_url(tag["href"], page_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)

        # <script src="...">
        for tag in soup.find_all("script", src=True):
            resolved = self.resolve_url(tag["src"], page_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)

        # <img src="..."> and <img srcset="...">
        for tag in soup.find_all("img"):
            if tag.get("src"):
                resolved = self.resolve_url(tag["src"], page_url)
                if resolved and self.is_internal(resolved):
                    refs.add(resolved)
            if tag.get("srcset"):
                for part in tag["srcset"].split(","):
                    src = part.strip().split()[0] if part.strip() else ""
                    resolved = self.resolve_url(src, page_url)
                    if resolved and self.is_internal(resolved):
                        refs.add(resolved)

        # <a href="..."> (internal pages)
        for tag in soup.find_all("a", href=True):
            resolved = self.resolve_url(tag["href"], page_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)

        # <source src="...">
        for tag in soup.find_all("source", src=True):
            resolved = self.resolve_url(tag["src"], page_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)

        # <video> and <audio> with src
        for tag_name in ("video", "audio"):
            for tag in soup.find_all(tag_name, src=True):
                resolved = self.resolve_url(tag["src"], page_url)
                if resolved and self.is_internal(resolved):
                    refs.add(resolved)

        # Inline style with url()
        for tag in soup.find_all(style=True):
            refs.update(self._extract_css_urls(tag["style"], page_url))

        # <style> blocks
        for tag in soup.find_all("style"):
            if tag.string:
                refs.update(self._extract_css_urls(tag.string, page_url))

        # @import in <style> blocks
        for tag in soup.find_all("style"):
            if tag.string:
                for match in re.finditer(
                    r'@import\s+(?:url\s*\(\s*)?["\']?([^"\')\s]+)',
                    tag.string,
                ):
                    resolved = self.resolve_url(match.group(1), page_url)
                    if resolved and self.is_internal(resolved):
                        refs.add(resolved)

        return refs

    def _extract_css_urls(self, css_text: str, base_url: str) -> set[str]:
        """Extract url() references from CSS text."""
        refs: set[str] = set()
        for match in re.finditer(r'url\s*\(\s*["\']?([^"\')\s]+)["\']?\s*\)', css_text):
            ref = match.group(1)
            if ref.startswith("data:"):
                continue
            resolved = self.resolve_url(ref, base_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)
        return refs

    def parse_css(self, css_content: str, css_url: str) -> set[str]:
        """Extract internal asset URLs from CSS."""
        refs: set[str] = set()
        # url() references
        refs.update(self._extract_css_urls(css_content, css_url))
        # @import
        for match in re.finditer(
            r'@import\s+(?:url\s*\(\s*)?["\']?([^"\')\s;]+)', css_content
        ):
            resolved = self.resolve_url(match.group(1), css_url)
            if resolved and self.is_internal(resolved):
                refs.add(resolved)
        return refs

    def _find_best_timestamp(self, original_url: str) -> Optional[str]:
        """Query CDX for a single URL to find its best timestamp."""
        params = {
            "url": original_url,
            "output": "json",
            "fl": "timestamp",
            "filter": "statuscode:200",
            "closest": self.target_timestamp,
            "sort": "closest",
            "limit": "1",
        }
        resp = self._get_with_retry(WAYBACK_CDX, params=params)
        if resp and resp.status_code == 200:
            try:
                rows = resp.json()
                if len(rows) > 1:
                    return rows[1][0]
            except (json.JSONDecodeError, IndexError):
                pass
        return None

    def discover_and_download_assets(self, resume: bool = False) -> None:
        """Parse downloaded files for asset references and download missing ones."""
        for round_num in range(1, 3):  # up to 2 rounds
            new_urls: set[str] = set()
            logger.info("Asset discovery round %d ...", round_num)

            # Scan all downloaded HTML files
            for norm_url, local_path in list(self.local_map.items()):
                full_path = self.output_dir / local_path
                if not full_path.exists():
                    continue
                suffix = local_path.suffix.lower()

                if suffix in (".html", ".htm") or (
                    suffix == "" and norm_url in self.downloaded_urls
                ):
                    try:
                        content = full_path.read_bytes()
                        # Reconstruct original URL for resolving relative refs
                        orig_url = self._norm_to_original(norm_url)
                        refs = self.parse_html(content, orig_url)
                        for ref in refs:
                            if ref not in self.downloaded_urls and ref not in self.local_map:
                                new_urls.add(ref)
                    except Exception as exc:
                        logger.debug("Error parsing HTML %s: %s", local_path, exc)

                elif suffix == ".css":
                    try:
                        content = full_path.read_text(encoding="utf-8", errors="replace")
                        orig_url = self._norm_to_original(norm_url)
                        refs = self.parse_css(content, orig_url)
                        for ref in refs:
                            if ref not in self.downloaded_urls and ref not in self.local_map:
                                new_urls.add(ref)
                    except Exception as exc:
                        logger.debug("Error parsing CSS %s: %s", local_path, exc)

            if not new_urls:
                logger.info("  No new assets found in round %d", round_num)
                break

            logger.info("  Found %d new asset URLs in round %d", len(new_urls), round_num)
            self.stats.asset_discovered += len(new_urls)

            # Download new assets
            for i, norm_url in enumerate(sorted(new_urls), 1):
                orig_url = self._norm_to_original(norm_url)
                local_path = self.url_to_local_path(orig_url)
                self.local_map[norm_url] = local_path

                full_path = self.output_dir / local_path
                if resume and full_path.exists() and full_path.stat().st_size > 0:
                    self.downloaded_urls.add(norm_url)
                    continue

                # Try to find timestamp from CDX
                ts = self._find_best_timestamp(orig_url)
                if ts is None:
                    ts = self.target_timestamp

                content = self.download_url(orig_url, ts)
                if content is not None:
                    self.save_file(content, local_path)
                    self.downloaded_urls.add(norm_url)
                    self.stats.asset_downloaded += 1
                    if self.verbose:
                        logger.info(
                            "  [asset %d/%d] %s -> %s",
                            i, len(new_urls), norm_url, local_path,
                        )
                else:
                    self.stats.failures.append(
                        {"url": orig_url, "phase": f"asset_round_{round_num}"}
                    )

                if self.delay > 0:
                    time.sleep(self.delay)

    def _norm_to_original(self, norm_url: str) -> str:
        """Convert a normalized URL back to an original URL for resolving."""
        if norm_url in self.url_map:
            return self.url_map[norm_url].original
        # Fallback: use the normalized URL itself
        return norm_url

    # ------------------------------------------------------------------
    # Phase 4: Link Rewriting
    # ------------------------------------------------------------------

    def _find_local_file(self, target_norm_url: str) -> Optional[Path]:
        """Find the local file for a normalized URL."""
        if target_norm_url in self.local_map:
            return self.local_map[target_norm_url]
        # Try with/without trailing index.html
        parsed = urlparse(target_norm_url)
        alt_path = parsed.path.rstrip("/")
        alt1 = urlunparse(
            (parsed.scheme, parsed.netloc, alt_path, "", "", "")
        )
        if alt1 in self.local_map:
            return self.local_map[alt1]
        alt2 = urlunparse(
            (parsed.scheme, parsed.netloc, alt_path + "/", "", "", "")
        )
        if alt2 in self.local_map:
            return self.local_map[alt2]
        return None

    def compute_relative_path(self, from_file: Path, to_file: Path) -> str:
        """Compute a relative path from one local file to another."""
        from_dir = from_file.parent
        rel = os.path.relpath(to_file, from_dir)
        # Use forward slashes
        return rel.replace("\\", "/")

    def rewrite_html_links(self, norm_url: str) -> None:
        """Rewrite links in an HTML file to relative local paths."""
        local_path = self.local_map.get(norm_url)
        if not local_path:
            return
        full_path = self.output_dir / local_path
        if not full_path.exists():
            return

        try:
            html_bytes = full_path.read_bytes()
            soup = BeautifulSoup(html_bytes, "html.parser")
        except Exception:
            return

        orig_url = self._norm_to_original(norm_url)
        changed = False

        # Rewrite href/src attributes
        attrs_to_check = [
            ("a", "href"),
            ("link", "href"),
            ("script", "src"),
            ("img", "src"),
            ("source", "src"),
            ("video", "src"),
            ("audio", "src"),
            ("video", "poster"),
            ("object", "data"),
            ("embed", "src"),
        ]

        for tag_name, attr in attrs_to_check:
            for tag in soup.find_all(tag_name, attrs={attr: True}):
                ref = tag[attr]
                resolved = self.resolve_url(ref, orig_url)
                if resolved and self.is_internal(resolved):
                    target_path = self._find_local_file(resolved)
                    if target_path:
                        rel = self.compute_relative_path(local_path, target_path)
                        if tag[attr] != rel:
                            tag[attr] = rel
                            changed = True

        # Rewrite srcset
        for tag in soup.find_all("img", srcset=True):
            new_parts = []
            srcset_changed = False
            for part in tag["srcset"].split(","):
                part = part.strip()
                if not part:
                    continue
                tokens = part.split()
                src = tokens[0]
                descriptor = " ".join(tokens[1:]) if len(tokens) > 1 else ""
                resolved = self.resolve_url(src, orig_url)
                if resolved and self.is_internal(resolved):
                    target_path = self._find_local_file(resolved)
                    if target_path:
                        rel = self.compute_relative_path(local_path, target_path)
                        if rel != src:
                            src = rel
                            srcset_changed = True
                entry = f"{src} {descriptor}".strip() if descriptor else src
                new_parts.append(entry)
            if srcset_changed:
                tag["srcset"] = ", ".join(new_parts)
                changed = True

        # Rewrite inline style url()
        for tag in soup.find_all(style=True):
            new_style = self._rewrite_css_urls(tag["style"], orig_url, local_path)
            if new_style != tag["style"]:
                tag["style"] = new_style
                changed = True

        # Rewrite <style> blocks
        for tag in soup.find_all("style"):
            if tag.string:
                new_css = self._rewrite_css_urls(tag.string, orig_url, local_path)
                if new_css != tag.string:
                    tag.string = new_css
                    changed = True

        if changed:
            # Write back
            html_out = soup.encode(soup.original_encoding or "utf-8")
            full_path.write_bytes(html_out)
            self.stats.rewritten_html += 1

    def _rewrite_css_urls(
        self, css_text: str, base_url: str, from_file: Path
    ) -> str:
        """Rewrite url() references in CSS text."""
        def replacer(match):
            full_match = match.group(0)
            ref = match.group(1)
            if ref.startswith("data:"):
                return full_match
            resolved = self.resolve_url(ref, base_url)
            if resolved and self.is_internal(resolved):
                target_path = self._find_local_file(resolved)
                if target_path:
                    rel = self.compute_relative_path(from_file, target_path)
                    return f"url({rel})"
            return full_match

        return re.sub(
            r'url\s*\(\s*["\']?([^"\')\s]+)["\']?\s*\)',
            replacer,
            css_text,
        )

    def _rewrite_css_imports(
        self, css_text: str, base_url: str, from_file: Path
    ) -> str:
        """Rewrite @import references in CSS text."""
        def replacer(match):
            full_match = match.group(0)
            ref = match.group(1)
            resolved = self.resolve_url(ref, base_url)
            if resolved and self.is_internal(resolved):
                target_path = self._find_local_file(resolved)
                if target_path:
                    rel = self.compute_relative_path(from_file, target_path)
                    # Preserve the import format
                    if "url(" in full_match:
                        return f'@import url("{rel}")'
                    return f'@import "{rel}"'
            return full_match

        return re.sub(
            r'@import\s+(?:url\s*\(\s*)?["\']?([^"\')\s;]+)["\']?\s*\)?',
            replacer,
            css_text,
        )

    def rewrite_css_links(self, norm_url: str) -> None:
        """Rewrite links in a CSS file."""
        local_path = self.local_map.get(norm_url)
        if not local_path:
            return
        full_path = self.output_dir / local_path
        if not full_path.exists():
            return
        if local_path.suffix.lower() != ".css":
            return

        try:
            css_text = full_path.read_text(encoding="utf-8", errors="replace")
        except Exception:
            return

        orig_url = self._norm_to_original(norm_url)
        new_text = self._rewrite_css_urls(css_text, orig_url, local_path)
        new_text = self._rewrite_css_imports(new_text, orig_url, local_path)

        if new_text != css_text:
            full_path.write_text(new_text, encoding="utf-8")
            self.stats.rewritten_css += 1

    def rewrite_all_links(self) -> None:
        """Rewrite links in all downloaded files."""
        logger.info("Rewriting links in %d files ...", len(self.local_map))
        for norm_url, local_path in self.local_map.items():
            suffix = local_path.suffix.lower()
            if suffix in (".html", ".htm") or suffix == "":
                # Check if it's actually HTML
                full_path = self.output_dir / local_path
                if full_path.exists() and local_path.name == "index.html":
                    self.rewrite_html_links(norm_url)
                elif full_path.exists() and suffix in (".html", ".htm"):
                    self.rewrite_html_links(norm_url)
            elif suffix == ".css":
                self.rewrite_css_links(norm_url)

    # ------------------------------------------------------------------
    # Phase 5: Report
    # ------------------------------------------------------------------

    def print_summary(self) -> None:
        """Print harvest summary to console."""
        s = self.stats
        print("\n" + "=" * 60)
        print("HARVEST SUMMARY")
        print("=" * 60)
        print(f"  CDX entries found:      {s.cdx_total}")
        print(f"  After dedup/filter:     {s.cdx_after_dedup}")
        print(f"  Downloaded (CDX):       {s.downloaded}")
        if s.skipped_resume:
            print(f"  Skipped (resume):       {s.skipped_resume}")
        print(f"  Assets discovered:      {s.asset_discovered}")
        print(f"  Assets downloaded:       {s.asset_downloaded}")
        print(f"  HTML files rewritten:   {s.rewritten_html}")
        print(f"  CSS files rewritten:    {s.rewritten_css}")
        print(f"  Total bytes:            {s.bytes_total:,}")
        print(f"  Failed downloads:       {len(s.failures)}")
        if s.by_extension:
            print("\n  Files by extension:")
            for ext, count in sorted(
                s.by_extension.items(), key=lambda x: -x[1]
            ):
                print(f"    {ext:12s} {count:5d}")
        if s.failures:
            print(f"\n  Failed URLs ({len(s.failures)}):")
            for f in s.failures[:20]:
                print(f"    [{f['phase']}] {f['url']}")
            if len(s.failures) > 20:
                print(f"    ... and {len(s.failures) - 20} more (see manifest.json)")
        print("=" * 60)

    def write_manifest(self) -> None:
        """Write manifest.json with harvest metadata."""
        manifest = {
            "harvest_date": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
            "domain": self.domain,
            "target_timestamp": self.target_timestamp,
            "wayback_snapshot": f"https://web.archive.org/web/{self.target_timestamp}/http://{self.domain}/",
            "statistics": {
                "cdx_entries": self.stats.cdx_total,
                "after_dedup_filter": self.stats.cdx_after_dedup,
                "downloaded_cdx": self.stats.downloaded,
                "skipped_resume": self.stats.skipped_resume,
                "assets_discovered": self.stats.asset_discovered,
                "assets_downloaded": self.stats.asset_downloaded,
                "html_rewritten": self.stats.rewritten_html,
                "css_rewritten": self.stats.rewritten_css,
                "total_bytes": self.stats.bytes_total,
                "failed_count": len(self.stats.failures),
                "files_by_extension": dict(self.stats.by_extension),
            },
            "files": sorted(
                str(p).replace("\\", "/")
                for p in self.local_map.values()
            ),
            "failures": self.stats.failures,
        }
        manifest_path = self.output_dir / "manifest.json"
        manifest_path.write_text(
            json.dumps(manifest, indent=2, ensure_ascii=False),
            encoding="utf-8",
        )
        logger.info("Manifest written to %s", manifest_path)

    # ------------------------------------------------------------------
    # Orchestration
    # ------------------------------------------------------------------

    def run(self, skip_rewrite: bool = False, resume: bool = False) -> None:
        """Run the full harvest pipeline."""
        start_time = time.time()

        # Phase 1: CDX Discovery
        entries = self.query_cdx()
        url_map = self.deduplicate_urls(entries)
        url_map = self.filter_urls(url_map)
        self.url_map = url_map
        self.stats.cdx_after_dedup = len(url_map)
        logger.info("URLs after dedup/filter: %d", len(url_map))

        # Phase 2: Download all CDX URLs
        self.download_all_cdx(resume=resume)

        # Phase 3: Discover and download additional assets
        self.discover_and_download_assets(resume=resume)

        # Phase 4: Rewrite links
        if not skip_rewrite:
            self.rewrite_all_links()
        else:
            logger.info("Skipping link rewriting (--skip-rewrite)")

        # Copy this script into the output directory
        script_src = Path(__file__).resolve()
        script_dst = self.output_dir / script_src.name
        if script_src != script_dst:
            shutil.copy2(script_src, script_dst)

        # Phase 5: Report
        elapsed = time.time() - start_time
        self.print_summary()
        print(f"\n  Elapsed time: {elapsed:.0f}s")
        self.write_manifest()


# ---------------------------------------------------------------------------
# CLI
# ---------------------------------------------------------------------------

def main():
    parser = argparse.ArgumentParser(
        description="Mirror usgin.org from the Wayback Machine.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
        epilog=__doc__,
    )
    parser.add_argument(
        "--domain",
        default="usgin.org",
        help="Domain to harvest (default: usgin.org)",
    )
    parser.add_argument(
        "--timestamp",
        default="20250612",
        help="Target Wayback Machine timestamp (default: 20250612)",
    )
    parser.add_argument(
        "-o", "--output",
        default=None,
        help="Output directory (default: same directory as script)",
    )
    parser.add_argument(
        "--delay",
        type=float,
        default=1.0,
        help="Seconds between requests (default: 1.0)",
    )
    parser.add_argument(
        "--max-retries",
        type=int,
        default=5,
        help="Max retry attempts per URL (default: 5)",
    )
    parser.add_argument(
        "--resume",
        action="store_true",
        help="Skip already-downloaded files",
    )
    parser.add_argument(
        "--skip-rewrite",
        action="store_true",
        help="Download only, skip link rewriting",
    )
    parser.add_argument(
        "-v", "--verbose",
        action="store_true",
        help="Verbose output",
    )
    args = parser.parse_args()

    # Default output dir: directory containing this script
    output_dir = args.output or str(Path(__file__).resolve().parent)

    # Setup logging
    level = logging.DEBUG if args.verbose else logging.INFO
    logging.basicConfig(
        level=level,
        format="%(asctime)s [%(levelname)s] %(message)s",
        datefmt="%H:%M:%S",
    )

    harvester = WaybackHarvester(
        domain=args.domain,
        timestamp=args.timestamp,
        output_dir=output_dir,
        delay=args.delay,
        max_retries=args.max_retries,
        verbose=args.verbose,
    )
    harvester.run(
        skip_rewrite=args.skip_rewrite,
        resume=args.resume,
    )


if __name__ == "__main__":
    main()
