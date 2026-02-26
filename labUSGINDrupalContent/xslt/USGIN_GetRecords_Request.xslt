<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output method="xml" indent="no" encoding="UTF-8" omit-xml-declaration="yes"/>

<xsl:template match="/">
   <xsl:element name="csw:GetRecords" use-attribute-sets="GetRecordsAttributes" xmlns:csw="http://www.opengis.net/cat/csw/2.0.2"
                                                                                xmlns:ogc="http://www.opengis.net/ogc"
                                                                                xmlns:dc="http://purl.org/dc/elements/1.1/"
                                                                                xmlns:gml="http://www.opengis.net/gml">
   
      <!--<csw:Query typeNames="csw:Record">-->
      <csw:Query typeNames="gmd:MD_Metadata">
         <csw:ElementSetName>full</csw:ElementSetName>
         <csw:Constraint version="1.0.0">
            <ogc:Filter xmlns="http://www.opengis.net/ogc">
               <ogc:And>
                  <!--
                  CSW Client must retrieve the following information to
                  define the search the user specifies in the User Interface:
                  'KeyWord' corresponds to the search term the user inputs,
                  'LiveDataMap' corresponds to if the user specifies "Live Data and
                  Maps Only", and 'Envelope' specifies the bounding box for a search
                  based on the current extent of the ArcMap window. The 'tmpltDate'
                  corresponds to searching a catalog via the Geoportal, in the
                  Additional Options, Modified Date search on the Search page.
                  -->
                  <!-- Key Word search -->
                  <xsl:apply-templates select="/GetRecords/KeyWord"/>
                  <!-- LiveDataOrMaps search -->
                  <xsl:apply-templates select="/GetRecords/LiveDataMap"/>
                  <!-- Envelope search, e.g. ogc:BBOX -->
                  <xsl:apply-templates select="/GetRecords/Envelope"/>
                  <!-- Date Range Search -->
                  <xsl:call-template name="tmpltDate"/>
               </ogc:And>
            </ogc:Filter>
         </csw:Constraint>
      </csw:Query>
   </xsl:element>
</xsl:template>

<!--
key word search : This template is used to pass the search
term to the catalog service. The PropertyName 'AnyText' is
variable, depending on what your catalog service accepts. 'AnyText'
will search all fields, irrespective of which XML element. If you
wanted to search only the title or abstract, you could change this
PropertyName parameter accordingly. The 'PropertyIsLike' elements
(wildCard="" escape= "" singleChar="") are specific to the CSW
specification your catalog service follows. 
-->
<xsl:template match="/GetRecords/KeyWord" xmlns:ogc="http://www.opengis.net/ogc">
   <xsl:if test="normalize-space(.)!=''">
      <ogc:PropertyIsLike wildCard="" escape="" singleChar="">
      <ogc:PropertyName>AnyText</ogc:PropertyName>
      <ogc:Literal>
         <xsl:value-of select="."/>
      </ogc:Literal>
      </ogc:PropertyIsLike>
   </xsl:if>
</xsl:template>

<!-- 
LiveDataOrMaps search: This template is used to pass the
requirement to retrieve only live data/map records from the catalog
service. The PropertyName 'Format' depends on the parameter your
catalog service accepts to define the type of resource the
resulting record describes. The Literal element "liveData" can be
changed to indicate the term your service may use to retrieve live
data records.
-->
<xsl:template match="/GetRecords/LiveDataMap" xmlns:ogc="http://www.opengis.net/ogc">
   <xsl:if test="translate(normalize-space(./text()),'true','TRUE') ='TRUE'">
      <ogc:PropertyIsEqualTo>
         <ogc:PropertyName>apiso:ServiceType</ogc:PropertyName>
         <ogc:Literal>WMS</ogc:Literal>
      </ogc:PropertyIsEqualTo>
   </xsl:if>
</xsl:template>
<!--
<xsl:template match="/GetRecords/LiveDataMap" xmlns:ogc="http://www.opengis.net/ogc">
   <xsl:if test="translate(normalize-space(./text()),'true','TRUE') ='TRUE'">
      <ogc:PropertyIsEqualTo>
         <ogc:PropertyName>Format</ogc:PropertyName>
         <ogc:Literal>liveData</ogc:Literal>
      </ogc:PropertyIsEqualTo>
   </xsl:if>
</xsl:template>
-->
<!--
Envelope search: This template is used to define a bounding
box for resulting records returned from the catalog service if the
"Use Current Extent" option is selected (ArcMap CSW Client only).
Resulting records must fall within this bounding box. Do not change
the PropertyName, Box, or coordinates elements.-->
<xsl:template match="/GetRecords/Envelope" xmlns:ogc="http://www.opengis.net/ogc">
   <!-- generate BBOX query if minx, miny, maxx, maxy are provided -->
   <xsl:if test="./MinX and ./MinY and ./MaxX and ./MaxY">
      <ogc:BBOX xmlns:gml="http://www.opengis.net/gml">
         <ogc:PropertyName>Geometry</ogc:PropertyName>
         <gml:Box srsName="http://www.opengis.net/gml/srs/epsg.xml#4326">
            <gml:coordinates>
               <xsl:value-of select="MinX"/>,<xsl:value-of select="MinY"/>,<xsl:value-of select="MaxX"/>,<xsl:value-of select="MaxY"/>
            </gml:coordinates>
         </gml:Box>
      </ogc:BBOX>
   </xsl:if>
</xsl:template>

<!--
tmpltDate: This template is used to define the date range
for when resulting records returned from the catalog service were
modified. This is only used for the geoportal search, and not the
CSW Client search. This section needs to be included only if you
want to apply your custom profile to the geoportal itself as well
as the CSW Client (the custom profile would appear in the dropdown
list of profiles when a publisher user registers a CSW repository).
Do not change this section.
-->
<xsl:template name="tmpltDate" xmlns:ogc="http://www.opengis.net/ogc">
   <xsl:if test="string-length(normalize-space(/GetRecords/FromDate/text()))>0">
   <ogc:PropertyIsGreaterThanOrEqualTo>
   <ogc:PropertyName>Modified</ogc:PropertyName>
      <ogc:Literal>
         <xsl:value-of select="normalize-space(/GetRecords/FromDate/text())"/>
      </ogc:Literal>
      </ogc:PropertyIsGreaterThanOrEqualTo>
   </xsl:if>
   
   <xsl:if test="string-length(normalize-space(/GetRecords/ToDate/text()))>0">
      <ogc:PropertyIsLessThanOrEqualTo>
      <ogc:PropertyName>Modified</ogc:PropertyName>
      <ogc:Literal><xsl:value-of select="normalize-space(/GetRecords/ToDate/text())"/></ogc:Literal>
      </ogc:PropertyIsLessThanOrEqualTo>
   </xsl:if>
</xsl:template>

<xsl:attribute-set name="GetRecordsAttributes">
   <xsl:attribute name="version">2.0.2</xsl:attribute>
   <xsl:attribute name="service">CSW</xsl:attribute>
   <xsl:attribute name="resultType">RESULTS</xsl:attribute>
   <xsl:attribute name="startPosition">
      <xsl:value-of select="/GetRecords/StartPosition"/>
   </xsl:attribute>
   <xsl:attribute name="maxRecords">
      <xsl:value-of select="/GetRecords/MaxRecords"/>
   </xsl:attribute>
   <xsl:attribute name="outputSchema">http://www.isotc211.org/2005/gmd</xsl:attribute>
</xsl:attribute-set>
</xsl:stylesheet>
