<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                              xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                              xmlns:dct="http://purl.org/dc/terms/"
                              xmlns:ows="http://www.opengis.net/ows"
                              xmlns:dc="http://purl.org/dc/elements/1.1/"
                              xmlns:gmd="http://www.isotc211.org/2005/gmd"
                              xmlns:gco="http://www.isotc211.org/2005/gco"
                              xmlns:srv="http://www.isotc211.org/2005/srv"
                              exclude-result-prefixes="csw dc dct ows">
                              
   <xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes" />
   <xsl:template match="/">
      <Records>
			<xsl:for-each select="/csw:GetRecordsResponse/csw:SearchResults/gmd:MD_Metadata">
				<Record>
					<ID>
						<xsl:value-of select="gmd:fileIdentifier/gco:CharacterString"/>
					</ID>
               <Title>
                  <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:citation/gmd:CI_Citation/gmd:title/gco:CharacterString"/>
               </Title>
               <Abstract>
                  <xsl:value-of select="gmd:identificationInfo/gmd:MD_DataIdentification/gmd:abstract/gco:CharacterString|gmd:identificationInfo/srv:SV_ServiceIdentification/gmd:abstract/gco:CharacterString"/>
               </Abstract>
               <LowerCorner>
                  <xsl:value-of select="./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal|./gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:westBoundLongitude/gco:Decimal"/>
                  <xsl:value-of select="' '"/>
                  <xsl:value-of select="./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal|./gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:southBoundLatitude/gco:Decimal"/>
               </LowerCorner>
               <UpperCorner>
                  <xsl:value-of select="./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal|./gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:eastBoundLongitude/gco:Decimal"/>
                  <xsl:value-of select="' '"/>
                  <xsl:value-of select="./gmd:identificationInfo/gmd:MD_DataIdentification/gmd:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal|./gmd:identificationInfo/srv:SV_ServiceIdentification/srv:extent/gmd:EX_Extent/gmd:geographicElement/gmd:EX_GeographicBoundingBox/gmd:northBoundLatitude/gco:Decimal"/>
               </UpperCorner>
                           
               <!--<xsl:for-each select="./gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:protocol/gco:CharacterString='OGC:WMS']/gmd:linkage/gmd:URL">-->
               <xsl:for-each select="./gmd:distributionInfo/gmd:MD_Distribution/gmd:transferOptions/gmd:MD_DigitalTransferOptions/gmd:onLine/gmd:CI_OnlineResource[gmd:name/gco:CharacterString='serviceDescription']/gmd:linkage/gmd:URL">
                  <References>
                     <xsl:value-of select="."/>
                     <xsl:text>&#x2714;</xsl:text>urn:x-esri:specification:ServiceType:ArcIMS:Metadata:Server<xsl:text>&#x2715;</xsl:text>
                  </References>
                  <Types>liveData<xsl:text>&#x2714;</xsl:text>urn:x-esri:specification:ServiceType:ArcIMS:Metadata:ContentType<xsl:text>&#x2715;</xsl:text>
                  </Types>
                  <Type>liveData</Type>
               </xsl:for-each>
               
               <xsl:for-each select="./gmd:identificationInfo/srv:SV_ServiceIdentification/srv:containsOperations/srv:SV_OperationMetadata[srv:operationName/gco:CharacterString='GetCapabilities']/srv:connectPoint/gmd:CI_OnlineResource/gmd:linkage/gmd:URL">
                  <References>
                        <xsl:value-of select="."/>
                     <xsl:text>&#x2714;</xsl:text>urn:x-esri:specification:ServiceType:ArcIMS:Metadata:Server<xsl:text>&#x2715;</xsl:text>
                  </References>
                  <Types>liveData<xsl:text>&#x2714;</xsl:text>urn:x-esri:specification:ServiceType:ArcIMS:Metadata:ContentType<xsl:text>&#x2715;</xsl:text></Types>
                  <Type>liveData</Type>
               </xsl:for-each>
  				</Record>
			</xsl:for-each>
		</Records>
   </xsl:template>
</xsl:stylesheet>

   <!--
   <xsl:template match="/">
   <xsl:choose>
      <xsl:when test="/ows:ExceptionReport">
         <exception>
            <exceptionText>
               <xsl:for-each select="/ows:ExceptionReport/ows:Exception">
                  <xsl:value-of select="ows:ExceptionText"/>
               </xsl:for-each>
            </exceptionText>
         </exception>
      </xsl:when>
      <xsl:otherwise>
         <Records>
            <xsl:attribute name="maxRecords">
               <xsl:value-of select="/csw:GetRecordsResponse/csw:SearchResults/@numberOfRecordsMatched"/>   
            </xsl:attribute>
               <xsl:for-each select="/csw:GetRecordsResponse/csw:SearchResults/csw:Record | /csw:GetRecordsResponse/csw:SearchResults/csw:BriefRecord | /csw:GetRecordByIdResponse/csw:Record | /csw:GetRecordsResponse/csw:SearchResults/csw:SummaryRecord">
                  <Record>
                     <ID>
                        <xsl:choose>
                           <xsl:when test="string-length(normalize-space(dc:identifier[@scheme='urn:x-esri:specification:ServiceType:ArcIMS:Metadata:DocID']/text())) > 0">
                              <xsl:value-of select="normalize-space(dc:identifier[@scheme='urn:x-esri:specification:ServiceType:ArcIMS:Metadata:DocID'])"/>
                           </xsl:when>
                           <xsl:otherwise>
                              <xsl:value-of select="normalize-space(dc:identifier)"/>
                           </xsl:otherwise>
                        </xsl:choose>                 
                     </ID>
                     <Title>
                        <xsl:value-of select="dc:title"/>
                     </Title>
                     <Abstract>
                        <xsl:value-of select="dct:abstract"/>
                     </Abstract>
                     <Type>
                        <xsl:value-of select="dc:type"/>
                     </Type>
                     <LowerCorner>
                        <xsl:value-of select="ows:WGS84BoundingBox/ows:LowerCorner"/>
                     </LowerCorner>
                     <UpperCorner>
                        <xsl:value-of select="ows:WGS84BoundingBox/ows:UpperCorner"/>
                     </UpperCorner>
                     <MaxX>
                        <xsl:value-of select="normalize-space(substring-before(ows:WGS84BoundingBox/ows:UpperCorner,' '))"/>
                     </MaxX>
                     <MaxY>
                        <xsl:value-of select="normalize-space(substring-after(ows:WGS84BoundingBox/ows:UpperCorner,' '))"/>
                     </MaxY>
                     <MinX>
                        <xsl:value-of select="normalize-space(substring-before(ows:WGS84BoundingBox/ows:LowerCorner,' '))"/>
                     </MinX>
                     <MinY>
                        <xsl:value-of select="normalize-space(substring-after(ows:WGS84BoundingBox/ows:LowerCorner,' '))"/>
                     </MinY>
                     <ModifiedDate>
                        <xsl:value-of select="./dct:modified"/>
                     </ModifiedDate>
                  
                     <References>
                        <xsl:for-each select="./dct:references">
                           <xsl:value-of select="."/>
                           <xsl:text>&#x2714;</xsl:text>
                           <xsl:value-of select="@scheme"/>
                           <xsl:text>&#x2715;</xsl:text>
                        </xsl:for-each>
                     </References>
               
                     <Types>
                        <xsl:for-each select="./dc:type">
                           <xsl:value-of select="."/>
                           <xsl:text>&#x2714;</xsl:text>
                           <xsl:value-of select="@scheme"/>
                           <xsl:text>&#x2715;</xsl:text>
                        </xsl:for-each>
                     </Types>
                  </Record>
               </xsl:for-each>
            </Records>
         </xsl:otherwise>
      </xsl:choose>
   </xsl:template>
</xsl:stylesheet>
-->
