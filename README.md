# USGIN Website Archive

Offline archive of **usgin.org** (U.S. Geoscience Information Network), harvested
from the Wayback Machine in February 2026. The site is no longer maintained;
this archive preserves its content for reference and deposit on Zenodo.

## What is USGIN?

USGIN was a distributed, interoperable data network for the geosciences,
developed as a partnership between the Association of American State Geologists
(AASG) and the U.S. Geological Survey (USGS), managed by the Arizona Geological
Survey (AZGS). Funded by NSF under award EAR-0753154, USGIN provided
standardized web services, metadata catalogs, and interchange formats to make
data from state and federal geological surveys accessible online using open
standards and common protocols.

USGIN was also the technology platform behind the National Geothermal Data
System (NGDS), supported by DOE grants EE-0002850 and EE-0001120.

## Archive contents

**Total size:** ~248 MB (208 MB from lab.usgin.org content, 40 MB from usgin.org)

### Main website (usgin.org)

| Directory | Content |
|-----------|---------|
| `index.html` | Landing page with archive resource links |
| `content/` | 28 pages covering USGIN concepts, objectives, best practices, data provider workflow, FAQ, glossary, and tutorials |
| `page/` | Special pages: About, NGDS Atlas, Open Data Solutions, How USGIN Works, USGIN in Action, Host Your Own Data |
| `documentation/` | Specification documentation index with links to live specs at usgin.github.io/usginspecs |
| `tutorials/` | Tutorial index: deploying GeoServer, metadata, web services, ArcMap geodatabases, NGDS content models |
| `specifications/` | Categorized listing of USGIN specifications (metadata, web services, data standards, URI profiles) |
| `glossary/` | 30+ defined terms (ArcGIS, CSW, GeoSciML, HTTP, metadata, OGC, WFS, XML, etc.) |
| `opportunities/` | Archived job postings |
| `node/` | Drupal node pages with additional content |
| `GenericMetadataModelDoc/` | Enterprise Architect model documentation (content pages not captured; .EAP file available in labUSGINDrupalContent) |
| `sites/` | CSS, JavaScript, images, and PDFs (Drupal theme assets) |
| `modules/`, `misc/` | Drupal core CSS and UI icons |

### Lab content archive (labUSGINDrupalContent/)

89 documents (208 MB) extracted from the [usgin/lab-usgin-site](https://github.com/usgin/lab-usgin-site)
GitHub repository. These files were originally hosted on **lab.usgin.org**
(a Drupal 7 site now offline). Organized into 10 categories:

| Category | Files | Content |
|----------|-------|---------|
| `specifications/` | 19 | USGIN ISO metadata profiles (v0.9.1–1.1.4), URI schemes (v1.0.1–1.0.3), GeoSciML Portrayal Cookbook, controlled vocabulary guidelines, service naming conventions, metadata conceptual model |
| `tutorials/` | 8 | Metadata Wizard tutorial, GeoNetwork Eclipse setup, CI_OnlineResource guide, schema validation, ETL documentation |
| `presentations/` | 14 | Conference posters and slides from GSA 2011, AGU 2011, EGU 2012, ESRI UC 2011, CSIG 2011; NGDS poster; USGIN architecture posters |
| `software/` | 5 | CSW Client v2/v3, AZGS CSW tools, URI resolver packages (generic + USGIN) |
| `xslt/` | 4 | CSW GetRecords/GetRecordByID request/response stylesheets, WMS-to-ISO 19119 transform |
| `xml-schemas/` | 3 | NGDS Heat Flow and Borehole Temperature content models, GeoServer datastore config |
| `scripts/` | 7 | Python examples for CSW transactions, ISO 19139-to-MEF conversion, XSLT transforms, WMS-to-CSW ETL |
| `images/logos/` | 21 | Organization logos (USGIN, NGDS, AASG, AZGS, NSF, USGS, DOE, OGC, W3C, etc.) and software logos (GeoServer, GeoNetwork, ESRI, Drupal, Python) |
| `images/banners/` | 4 | Site interface banners (AASG, DOE, NSF, USGS) |
| `images/diagrams/` | 4 | USGIN system overview, GeoServer+GeoNetwork architecture, URI Venn diagram, Metadata Wizard flowchart |

See `labUSGINDrupalContent/index.html` for a browsable table of contents with
titles, descriptions, and file sizes.

## Key topics

- **Distributed network architecture** for geoscience data sharing
- **Metadata standards**: ISO 19115/19139, FGDC-CSDGM, USGIN metadata profiles
- **Web services**: OGC Catalog Service for the Web (CSW), Web Feature Service (WFS), Web Map Service (WMS)
- **Data interchange formats**: GeoSciML, XML-based content models, GML simple features
- **URI policies**: Dereferenceable HTTP URIs for geoscience resources
- **Geothermal data**: National Geothermal Data System (NGDS) content models and services
- **Open data**: Compliance guides, data provider workflows, best practices
- **Tools**: GeoNetwork, GeoServer, PostGIS, ArcGIS integration, CSW clients, metadata wizards

## Browsing the archive

Open `index.html` in a web browser, or serve locally:

```bash
python -m http.server -d /path/to/usgin-website-archive 8080
# Then visit http://localhost:8080
```

Navigation works via relative links. CSS styling is preserved. Some pages
reference Drupal JavaScript that may not function fully offline.

## Known limitations

- **Dead external links**: 77 external URLs are no longer reachable (marked
  inline as `[Dead Link, url]`). See `dead_links_report.json` for details.
  Major dead domains include lab.usgin.org, catalog.usgin.org,
  repository.usgin.org, schemas.usgin.org, and geothermaldata.org.
- **3 specification links restored**: Links to USGIN ISO Metadata, Metadata
  Recommendations, and URI Scheme specs on the documentation page now point to
  live copies at https://usgin.github.io/usginspecs/.
- **Dynamic content**: Search forms, login pages, and newsletter signups do not
  function offline and have been removed.
- **Enterprise Architect model**: The `GenericMetadataModelDoc/` HTML report
  relied on JavaScript-loaded content pages that were never captured by the
  Wayback Machine. The page now displays an explanatory note and links to the
  `.EAP` project file.
- **157 failed asset downloads**: Mostly old Drupal node pages and glossary
  terms that were not fully archived by the Wayback Machine.

## How this archive was created

### Phase 1: Wayback Machine harvest (usgin.org)

The `harvest_wayback.py` script downloaded the usgin.org website from the
Wayback Machine snapshot dated June 12, 2025. The process:

1. **CDX Discovery** — Queried the Wayback Machine CDX API
   (`web.archive.org/cdx/search/cdx?url=usgin.org/*`) to discover all captured
   URLs. Found 479 entries, deduplicated to 250 unique URLs.

2. **Download** — Fetched each URL using the Wayback Machine `id_` flag
   (`web.archive.org/web/{timestamp}id_/{url}`) to retrieve original content
   without the Wayback toolbar. All 250 URLs downloaded successfully.

3. **Asset discovery** — Parsed downloaded HTML and CSS files for additional
   assets (images, scripts, stylesheets) not in the CDX results. Found 158
   additional URLs; 1 downloaded successfully, 157 returned 404.

4. **Link rewriting** — Rewrote all internal `href`/`src` attributes in 59 HTML
   files and `url()` references in 8 CSS files to use relative paths for
   offline browsing.

Result: 251 files, ~40 MB. Metadata recorded in `manifest.json`.

### Phase 2: Dead link cleanup

Scanned all HTML files for external links and tested each via HTTP HEAD/GET
requests. Dead links (HTTP 400/500/timeout) were replaced inline with
`text [Dead Link, url]`. False positives from bot-blocking sites (drupal.org,
w3.org, whitehouse.gov, nsf.gov, mysql.com) were identified and restored.
Links to geothermaldata.org (responding but with no content) were also removed.

Three specification links on `documentation/index.html` were matched to live
equivalents at https://usgin.github.io/usginspecs/ and restored.

Non-functional pages (Drupal login form, MailChimp newsletter signup,
confirmation pages) were removed. Drupal navigation sidebars with dead links
were removed from 12 pages. Results recorded in `dead_links_report.json`.

### Phase 3: Lab content extraction (lab.usgin.org)

Content documents were downloaded from the
[usgin/lab-usgin-site](https://github.com/usgin/lab-usgin-site) GitHub
repository (`sites/default/files/` directory). The lab.usgin.org Drupal site is
offline, but the repository preserves file attachments (though not database-stored
page content). 89 documents organized into 10 categories with a generated
`index.html` table of contents.

### Phase 4: Encoding and cleanup

Fixed 12 UTF-8 replacement characters (U+FFFD, originally non-breaking spaces
from ISO-8859-1 source) in the main `index.html`. Added an Archive Resources
navigation section to the main page linking to all major content sections.

### Tools used

- Python 3 with `requests` and `beautifulsoup4`
- Wayback Machine CDX API and `id_` download flag
- GitHub API and raw.githubusercontent.com for lab content
- `curl` for file downloads

## File manifest

| File | Purpose |
|------|---------|
| `index.html` | Archive landing page with navigation |
| `manifest.json` | Harvest metadata: timestamps, file list, statistics |
| `dead_links_report.json` | Dead link scan results and restoration log |
| `harvest_wayback.py` | Python script used to harvest from Wayback Machine |
| `labUSGINDrupalContent/index.html` | Table of contents for lab content |

## License

The original usgin.org content was produced by the Arizona Geological Survey on
behalf of AASG, with funding from NSF and DOE. This archive is provided for
reference and preservation purposes.

## Citation

If referencing this archive, please cite:

> USGIN Website Archive. Harvested from the Wayback Machine
> (web.archive.org, snapshot 2025-06-12) in February 2026. Original content
> by the Arizona Geological Survey, Association of American State Geologists,
> and U.S. Geological Survey.
