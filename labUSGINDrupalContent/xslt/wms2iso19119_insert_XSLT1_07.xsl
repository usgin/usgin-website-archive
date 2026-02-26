<?xml version="1.0" encoding="UTF-8"?>
<!--***************************************************************************************************
*** WMS GetCapabilities 1.1.1 response to CSW 2.0.2 Insert Transaction transformation XSLT1 
*** For <WMT_MS_Capabilities> 1.1.1 but not yet for <WMS_Capabilities> 1.3.0
***
*** Based on deegree's wms2iso19119.xsl build 2.2.0 (http://www.deegree.org/)
*** Modified by: Wolfgang Grunberg 
***                   Arizona Geological Survey
***                   08/18/2009
***
*** Metadata is schema valid with:
***   ISO 19139/19115 Metadata - http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/metadataEntity.xsd 
***   ISO 19139/19119 Service - http://www.isotc211.org/2005/srv (http://schemas.opengis.net/iso/19139/20060504/srv/serviceMetadata.xsd)
*** 
*** NOTE: Version 1.3.0 WMS GetCapabilities requests will not be transformed correctly.
**************************************************************************************************-->
<xsl:stylesheet 
	version="1.0" 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:srv="http://www.isotc211.org/2005/srv" 
	xmlns:gmd="http://www.isotc211.org/2005/gmd" 
	xmlns:gco="http://www.isotc211.org/2005/gco" 
	xmlns:xlink="http://www.w3.org/1999/xlink" 
	exclude-result-prefixes="xlink xsl">
	<xsl:output method="xml" encoding="UTF-8" indent="yes"/>
	<!--*** PARAMETERS  ***-->
	<!-- Set required time stamp. XSLT 1 does not support current-dateTime(). -->
	<xsl:param name="DATETIME" select="'1950-01-01T01:01:01'"/>
	<!--*** VARIABLES ***-->
	<!-- Default abstract for required CSW element -->
	<xsl:variable name="DEFAULT_ABSTRACT">WMS Service</xsl:variable>
	<!-- Empty String for testing purpose -->
	<xsl:variable name="EMPTY_STRING">
		<xsl:value-of select="''"/>
	</xsl:variable>
	<!--*** TEMPLATES ***-->
	<!-- NOTE: for some reason XMLSpy's and MSXML's  XSLT parsers choke on the xmlns="http://www.opengis.net/wms"  attribute in <WMS_Capabilities> and both can't match the following template node(s). XMLSpy and MSXML will use their own default template (dumps all values) if they can't match a node to a template. -->
	<!-- <xsl:template match="WMT_MS_Capabilities | WMS_Capabilities"> Dosen't work because of the above reason. -->
	<!--<xsl:template match="/"> Returns empty elements. -->
	<!--*** TEMPLATE: WMT_MS_Capabilities (WMS GetCapabilities 1.1.1) ***-->
	<xsl:template match="WMT_MS_Capabilities">
		<!-- CSW Insert transaction  -->
		<csw:Transaction 
			service="CSW" 
			version="2.0.2" 
			xmlns:csw="http://www.opengis.net/cat/csw">
			<!-- "The <Insert> element is a container for one or more records that are to be inserted into the catalogue." -->
			<csw:Insert>
				<!-- Metadata -->
				<gmd:MD_Metadata 
					xmlns:srv="http://www.isotc211.org/2005/srv" 
					xmlns:gmd="http://www.isotc211.org/2005/gmd" 
					xmlns:gml="http://www.opengis.net/gml">
					<!-- Sadly, the CSW and GMD schema have duplicate GML refernces which lead to schema validation errors.
					xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
					xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/metadataEntity.xsd 
					http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/serviceMetadata.xsd"> -->
					<gmd:fileIdentifier>
						<gco:CharacterString>
							<xsl:value-of select="./Service/Title"/>
						</gco:CharacterString>
					</gmd:fileIdentifier>
					<!-- ISO 639-2 Bibliographic Code -->
					<gmd:language>
						<gco:CharacterString>eng</gco:CharacterString>
					</gmd:language>
					<!-- MD_CharacterSetCode: utf8, 8859part1, ucs2, ... -->
					<gmd:characterSet>
						<gmd:MD_CharacterSetCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_CharacterSetCode" codeListValue="utf8"/>
					</gmd:characterSet>
					<!-- Define if this record is a dataset (default), service, feature, software, etc. -->
					<gmd:hierarchyLevel>
						<gmd:MD_ScopeCode codeList="http://www.isotc211.org/2005/resources/Codelist/gmxCodelists.xml#MD_ScopeCode" codeListValue="service"/>
					</gmd:hierarchyLevel>
					<!-- name of the hierarchy levels for which the metadata is provided - required in deegree?-->
					<gmd:hierarchyLevelName>
						<gco:CharacterString>service</gco:CharacterString>
					</gmd:hierarchyLevelName>
					<!-- Metadata Point of Contact - REQUIRED -->
					<gmd:contact>
						<xsl:choose>
							<xsl:when test="Service/ContactInformation">
								<xsl:call-template name="wms_service_respParty"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="defaultRespParty"/>
							</xsl:otherwise>
						</xsl:choose>
					</gmd:contact>
					<!-- Metadata Date Stamp -->
					<gmd:dateStamp>
						<gco:DateTime>
							<xsl:value-of select="$DATETIME"/>
						</gco:DateTime>
					</gmd:dateStamp>
					<!-- Metadata Standard -->
					<gmd:metadataStandardName>
						<gco:CharacterString>ISO19119</gco:CharacterString>
					</gmd:metadataStandardName>
					<gmd:metadataStandardVersion>
						<gco:CharacterString>2005/PDAM 1</gco:CharacterString>
					</gmd:metadataStandardVersion>
					<!-- Basic information required to uniquely identify a resource or resources -->
					<xsl:apply-templates select="Capability/Layer/SRS"/>
					<xsl:call-template name="identification"/>
				</gmd:MD_Metadata>
			</csw:Insert>
		</csw:Transaction>
	</xsl:template>
	<!--*** TEMPLATE: WMS_Capabilities (WMS GetCapabilities 1.3.0) ***-->
	<!-- NOTE: this is currently not working! -->
	<xsl:template match="WMS_Capabilities">
		<!-- CSW Insert transaction  -->
		<csw:Transaction 
			service="CSW" 
			version="2.0.2" 
			xmlns:csw="http://www.opengis.net/cat/csw">
			<csw:Insert>
				<!-- Metadata -->
				<gmd:MD_Metadata 
					xmlns:srv="http://www.isotc211.org/2005/srv" 
					xmlns:gmd="http://www.isotc211.org/2005/gmd" 
					xmlns:gml="http://www.opengis.net/gml">
					<!-- Sadly, the CSW and GMD schema have duplicate GML refernces which lead to schema validation errors.
					xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" 
					xsi:schemaLocation="http://www.isotc211.org/2005/gmd http://schemas.opengis.net/iso/19139/20060504/gmd/metadataEntity.xsd http://www.isotc211.org/2005/srv http://schemas.opengis.net/iso/19139/20060504/srv/serviceMetadata.xsd">
					-->
					<gmd:fileIdentifier>
						<gco:CharacterString>
							<xsl:value-of select="./Service/Title"/>
						</gco:CharacterString>
					</gmd:fileIdentifier>
					<!-- ISO 639-2 Bibliographic Code -->
					<gmd:language>
						<gco:CharacterString>eng</gco:CharacterString>
					</gmd:language>
					<gmd:characterSet>
						<gmd:MD_CharacterSetCode codeList="MD_CharacterSetCode" codeListValue="utf8"/>
					</gmd:characterSet>
					<gmd:hierarchyLevel>
						<gmd:MD_ScopeCode codeList="MD_ScopeCode" codeListValue="service"/>
					</gmd:hierarchyLevel>
					<gmd:hierarchyLevelName>
						<gco:CharacterString>service</gco:CharacterString>
					</gmd:hierarchyLevelName>
					<gmd:contact>
						<xsl:choose>
							<xsl:when test="Service/ContactInformation">
								<xsl:call-template name="wms_service_respParty"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:call-template name="defaultRespParty"/>
							</xsl:otherwise>
						</xsl:choose>
					</gmd:contact>
					<gmd:dateStamp>
						<gco:DateTime>
							<xsl:value-of select="$DATETIME"/>
						</gco:DateTime>
					</gmd:dateStamp>
					<gmd:metadataStandardName>
						<gco:CharacterString>ISO19119</gco:CharacterString>
					</gmd:metadataStandardName>
					<gmd:metadataStandardVersion>
						<gco:CharacterString>2005/PDAM 1</gco:CharacterString>
					</gmd:metadataStandardVersion>
					<xsl:apply-templates select="Capability/Layer/SRS"/>
					<xsl:call-template name="identification"/>
				</gmd:MD_Metadata>
			</csw:Insert>
		</csw:Transaction>
	</xsl:template>
	<!--*** Shared Templates ***-->
	<!-- TEMPLATE: Default Responsible Party -->
	<xsl:template name="defaultRespParty">
		<!-- This is a hack! -->
		<gmd:CI_ResponsibleParty>
			<!-- Organisation Name REQUIRED by deegree and INSPIRE -->
			<gmd:organisationName>
				<gco:CharacterString>
					<xsl:value-of select="'UNKNOWN'"/>
				</gco:CharacterString>
			</gmd:organisationName>
			<!-- Electronic Mail Address REQUIRED by INSPIRE -->
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<gmd:address>
						<gmd:CI_Address>
							<gmd:electronicMailAddress>
								<gco:CharacterString>UNKNOWN</gco:CharacterString>
							</gmd:electronicMailAddress>
						</gmd:CI_Address>
					</gmd:address>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeList="CI_RoleCode" codeListValue="pointOfContact"/>
			</gmd:role>
		</gmd:CI_ResponsibleParty>
	</xsl:template>
	<!-- TEMPLATE: Responsible Party derived from service section of WMS capabilities -->
	<xsl:template name="wms_service_respParty">
		<gmd:CI_ResponsibleParty>
			<!-- Individual Name -->
			<xsl:if test="boolean(./Service/ContactInformation/ContactPersonPrimary/ContactPerson)">
				<gmd:individualName>
					<gco:CharacterString>
						<xsl:value-of select="./Service/ContactInformation/ContactPersonPrimary/ContactPerson"/>
					</gco:CharacterString>
				</gmd:individualName>
			</xsl:if>
			<!-- Organisation Name - REQUIRED by deegree and INSPIRE -->
			<xsl:if test="boolean(./Service/ContactInformation/ContactPersonPrimary/ContactOrganization)">
				<gmd:organisationName>
					<gco:CharacterString>
						<!--<xsl:value-of select="./Service/ContactInformation/ContactPersonPrimary/ContactOrganization"/>-->
						<xsl:choose>
							<xsl:when test="string((string-length(string(./Service/ContactInformation/ContactPersonPrimary/ContactOrganization)) &gt; '0')) != 'false'">
								<xsl:value-of select="string(./Service/ContactInformation/ContactPersonPrimary/ContactOrganization)"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="'UNKNOWN'"/>
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</gmd:organisationName>
			</xsl:if>
			<gmd:contactInfo>
				<gmd:CI_Contact>
					<!-- Phone/Fax -->
					<xsl:if test="normalize-space(./Service/ContactInformation/ContactVoiceTelephone) or normalize-space(./Service/ContactInformation/ContactFacsimileTelephone)">
						<gmd:phone>
							<gmd:CI_Telephone>
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactVoiceTelephone)">
									<gmd:voice>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactVoiceTelephone"/>
										</gco:CharacterString>
									</gmd:voice>
								</xsl:if>
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactFacsimileTelephone)">
									<gmd:facsimile>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactFacsimileTelephone"/>
										</gco:CharacterString>
									</gmd:facsimile>
								</xsl:if>
							</gmd:CI_Telephone>
						</gmd:phone>
					</xsl:if>
					<!-- Address -->
					<xsl:if test="boolean(./Service/ContactInformation/ContactAddress)">
						<gmd:address>
							<gmd:CI_Address>
								<!--<xsl:if test="normalize-space(./Service/ContactInformation/ContactAddress/Address)">-->
								<gmd:deliveryPoint>
									<gco:CharacterString>
										<!--<xsl:value-of select="./Service/ContactInformation/ContactAddress/Address"/>-->
										<xsl:choose>
											<xsl:when test="string((string-length(string(./Service/ContactInformation/ContactAddress/Address)) &gt; '0')) != 'false'">
												<xsl:value-of select="string(./Service/ContactInformation/ContactAddress/Address)"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="'UNKNOWN'"/>
											</xsl:otherwise>
										</xsl:choose>
									</gco:CharacterString>
								</gmd:deliveryPoint>
								<!--</xsl:if>-->
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactAddress/City)">
									<gmd:city>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactAddress/City"/>
										</gco:CharacterString>
									</gmd:city>
								</xsl:if>
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactAddress/StateOrProvince)">
									<gmd:administrativeArea>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactAddress/StateOrProvince"/>
										</gco:CharacterString>
									</gmd:administrativeArea>
								</xsl:if>
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactAddress/PostCode)">
									<gmd:postalCode>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactAddress/PostCode"/>
										</gco:CharacterString>
									</gmd:postalCode>
								</xsl:if>
								<xsl:if test="normalize-space(./Service/ContactInformation/ContactAddress/Country)">
									<gmd:country>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactAddress/Country"/>
										</gco:CharacterString>
									</gmd:country>
								</xsl:if>
								<!-- e-mail - REQUIRED by INSPIRE  -->
								<xsl:if test="boolean(./Service/ContactInformation/ContactElectronicMailAddress) and normalize-space(./Service/ContactInformation/ContactElectronicMailAddress)">
									<gmd:electronicMailAddress>
										<gco:CharacterString>
											<xsl:value-of select="./Service/ContactInformation/ContactElectronicMailAddress"/>
										</gco:CharacterString>
									</gmd:electronicMailAddress>
								</xsl:if>
							</gmd:CI_Address>
						</gmd:address>
					</xsl:if>
					<!-- Online Resource -->
					<xsl:if test="boolean(./Service/OnlineResource)">
						<gmd:onlineResource>
							<gmd:CI_OnlineResource>
								<gmd:linkage>
									<gmd:URL>
										<xsl:value-of select="./Service/OnlineResource/@xlink:href"/>
									</gmd:URL>
								</gmd:linkage>
								<gmd:protocol>
									<gco:CharacterString>HTTP</gco:CharacterString>
								</gmd:protocol>
							</gmd:CI_OnlineResource>
						</gmd:onlineResource>
					</xsl:if>
				</gmd:CI_Contact>
			</gmd:contactInfo>
			<gmd:role>
				<gmd:CI_RoleCode codeList="CI_RoleCode" codeListValue="pointOfContact"/>
			</gmd:role>
		</gmd:CI_ResponsibleParty>
	</xsl:template>
	<!-- TEMPLATE: Basic information required to uniquely identify a resource or resources -->
	<xsl:template name="identification">
		<gmd:identificationInfo>
			<srv:SV_ServiceIdentification>
				<gmd:citation>
					<gmd:CI_Citation>
						<!-- Dataset Title - REQUIRED -->
						<gmd:title>
							<gco:CharacterString>
								<xsl:value-of select="Service/Title"/>
							</gco:CharacterString>
						</gmd:title>
						<!-- Dataset Publication Date - REQUIRED by ISO -->
						<gmd:date>
							<gmd:CI_Date>
								<gmd:date>
									<gco:DateTime>
										<xsl:value-of select="$DATETIME"/>
									</gco:DateTime>
								</gmd:date>
								<gmd:dateType>
									<gmd:CI_DateTypeCode codeList="CI_DateTypeCode" codeListValue="creation"/>
								</gmd:dateType>
							</gmd:CI_Date>
						</gmd:date>
					</gmd:CI_Citation>
				</gmd:citation>
				<!-- Abstract - REQUIRED -->
				<gmd:abstract>
					<gco:CharacterString>
						<xsl:choose>
							<xsl:when test="boolean( Service/Abstract )">
								<xsl:value-of select="Service/Abstract"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="$DEFAULT_ABSTRACT"/>
							</xsl:otherwise>
						</xsl:choose>
					</gco:CharacterString>
				</gmd:abstract>
				<!-- Keywords - test if Keywordlist exists AND if Keyword string is not empty -->
				<xsl:choose>
					<!-- If there are keywords and if they are not empty -->
					<xsl:when test="boolean(Service/KeywordList) and normalize-space(Service/KeywordList/Keyword) != $EMPTY_STRING">
						<gmd:descriptiveKeywords>
							<gmd:MD_Keywords>
								<xsl:for-each select="Service/KeywordList/Keyword">
									<gmd:keyword>
										<gco:CharacterString>
											<xsl:value-of select="."/>
										</gco:CharacterString>
									</gmd:keyword>
								</xsl:for-each>
								<gmd:type>
									<gmd:MD_KeywordTypeCode>
										<xsl:attribute name="codeListValue"><xsl:value-of select="'theme'"/></xsl:attribute>
										<xsl:attribute name="codeList"><xsl:value-of select="'MD_KeywordTypeCode'"/></xsl:attribute>
									</gmd:MD_KeywordTypeCode>
								</gmd:type>
							</gmd:MD_Keywords>
						</gmd:descriptiveKeywords>
					</xsl:when>
					<!-- If the keyword string is empty add hard coded keyword -->
					<xsl:when test="normalize-space(Service/KeywordList/Keyword) = $EMPTY_STRING">
						<gmd:descriptiveKeywords>
							<gmd:MD_Keywords>
								<!--Hard coded Keyword -->
								<gmd:keyword>
									<gco:CharacterString>WMS Service</gco:CharacterString>
								</gmd:keyword>
								<gmd:type>
									<gmd:MD_KeywordTypeCode>
										<xsl:attribute name="codeListValue"><xsl:value-of select="'theme'"/></xsl:attribute>
										<xsl:attribute name="codeList"><xsl:value-of select="'MD_KeywordTypeCode'"/></xsl:attribute>
									</gmd:MD_KeywordTypeCode>
								</gmd:type>
							</gmd:MD_Keywords>
						</gmd:descriptiveKeywords>
					</xsl:when>
				</xsl:choose>
				<!--  -->
				<xsl:if test="boolean(Service/KeywordList) and normalize-space(Service/KeywordList/Keyword) != $EMPTY_STRING">
					<gmd:descriptiveKeywords>
						<gmd:MD_Keywords>
							<xsl:for-each select="Service/KeywordList/Keyword">
								<gmd:keyword>
									<gco:CharacterString>
										<xsl:value-of select="."/>
									</gco:CharacterString>
								</gmd:keyword>
							</xsl:for-each>
							<!--Hard coded Keyword -->
							<gmd:keyword>
								<gco:CharacterString>WMS Service</gco:CharacterString>
							</gmd:keyword>
							<gmd:type>
								<gmd:MD_KeywordTypeCode>
									<xsl:attribute name="codeListValue"><xsl:value-of select="'theme'"/></xsl:attribute>
									<xsl:attribute name="codeList"><xsl:value-of select="'MD_KeywordTypeCode'"/></xsl:attribute>
								</gmd:MD_KeywordTypeCode>
							</gmd:type>
						</gmd:MD_Keywords>
					</gmd:descriptiveKeywords>
				</xsl:if>
				<!-- WMS Service Information -->
				<srv:serviceType>
					<gco:LocalName>OGC:WMS</gco:LocalName>
				</srv:serviceType>
				<!-- Can't get WMT_MS_Capabilities@version property directly  -->
				<srv:serviceTypeVersion>
					<xsl:choose>
						<xsl:when test="boolean(//@version)">
							<gco:CharacterString>
								<xsl:value-of select="//@version"/>
							</gco:CharacterString>
						</xsl:when>
						<xsl:otherwise>
							<gco:CharacterString>
								1.1.1
							</gco:CharacterString>
						</xsl:otherwise>
					</xsl:choose>
				</srv:serviceTypeVersion>
				<!-- Access Properties -->
				<!-- information about the availability of the service, including: fees, planned available date and time, ordering instructions, turnaround -->
				<xsl:if test="Service/Fees">
					<srv:accessProperties>
						<gmd:MD_StandardOrderProcess>
							<gmd:fees>
								<gco:CharacterString>
									<xsl:value-of select="Service/Fees"/>
								</gco:CharacterString>
							</gmd:fees>
						</gmd:MD_StandardOrderProcess>
					</srv:accessProperties>
				</xsl:if>
				<!-- legal and security constraints on accessing the service and distributing data generated by the service -->
				<xsl:if test="Service/AccessConstraints">
					<srv:restrictions>
						<gmd:MD_LegalConstraints>
							<gmd:accessConstraints>
								<gmd:MD_RestrictionCode codeList="MD_RestrictionCode" codeListValue="otherRestrictions"/>
							</gmd:accessConstraints>
							<gmd:otherConstraints>
								<gco:CharacterString>
									<xsl:value-of select="Service/AccessConstraints"/>
								</gco:CharacterString>
							</gmd:otherConstraints>
						</gmd:MD_LegalConstraints>
					</srv:restrictions>
				</xsl:if>
				<!-- Service Extent  -->
				<xsl:apply-templates select="Capability/Layer/LatLonBoundingBox"/>
				<!-- Coupled Resources - now mandatory for deegree WMS/WFS service metadata records -->
				<!-- "further description of the data coupling in the case of tightly coupled services" -->
				<xsl:call-template name="addCoupledResource"/>
				<!-- Type of coupling between service and associated data (if exists) -->
				<srv:couplingType>
					<xsl:choose>
						<xsl:when test="Capability/UserDefinedSymbolization/@UserLayer = 1">
							<srv:SV_CouplingType codeList="SV_CouplingType" codeListValue="mixed"/>
						</xsl:when>
						<xsl:otherwise>
							<srv:SV_CouplingType codeList="SV_CouplingType" codeListValue="tight"/>
						</xsl:otherwise>
					</xsl:choose>
				</srv:couplingType>
				<xsl:call-template name="addGetCapabilitiesOpMetadata"/>
				<xsl:call-template name="addGetMapOpMetadata"/>
				<xsl:if test="boolean(Capability/Request/GetFeatureInfo)">
					<xsl:call-template name="addGetFeatureInfoOpMetadata"/>
				</xsl:if>
				<xsl:if test="boolean(Capability/Request/DescribeLayer)">
					<xsl:call-template name="addDescribeLayerOpMetadata"/>
				</xsl:if>
				<xsl:if test="boolean(Capability/Request/GetLegendGraphic)">
					<xsl:call-template name="addGetLegendGraphicOpMetadata"/>
				</xsl:if>
				<xsl:apply-templates select="Capability/Layer"/>
			</srv:SV_ServiceIdentification>
		</gmd:identificationInfo>
	</xsl:template>
	<!-- TEMPLATE: GetCapability -->
	<xsl:template name="addGetCapabilitiesOpMetadata">
		<!--
			append GetCapabilities description
		-->
		<srv:containsOperations>
			<srv:SV_OperationMetadata>
				<srv:operationName>
					<gco:CharacterString>GetCapabilities</gco:CharacterString>
				</srv:operationName>
				<xsl:apply-templates select="Capability/Request/GetCapabilities/DCPType/HTTP"/>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Service</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Version</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Request</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: GetCapabilities</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<xsl:choose>
					<xsl:when test="boolean(Capability/Request/GetCapabilities/DCPType/HTTP/*)">
						<xsl:apply-templates select="Capability/Request/GetCapabilities/DCPType/HTTP/Get/OnlineResource"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Capability/Request/GetCapabilities/DCPType/HTTP/Post/OnlineResource"/>
					</xsl:otherwise>
				</xsl:choose>
			</srv:SV_OperationMetadata>
		</srv:containsOperations>
	</xsl:template>
	<!-- TEMPLATE: GetMap -->
	<xsl:template name="addGetMapOpMetadata">
		<!--
			append GetMap description
		-->
		<srv:containsOperations>
			<srv:SV_OperationMetadata>
				<srv:operationName>
					<gco:CharacterString>GetMap</gco:CharacterString>
				</srv:operationName>
				<xsl:apply-templates select="Capability/Request/GetMap/DCPType/HTTP"/>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Version</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Request</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: GetMap</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Layers</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Styles</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>srs</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>BBOX</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>width</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>height</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Format</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>TRANSPARENT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>boolean</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>boolean</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>BGCOLOR</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>EXCEPTIONS</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>TIME</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>ELEVATION</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<xsl:choose>
					<xsl:when test="boolean(Capability/Request/GetMap/DCPType/HTTP/*)">
						<xsl:apply-templates select="Capability/Request/GetMap/DCPType/HTTP/Get/OnlineResource"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Capability/Request/GetMap/DCPType/HTTP/Post/OnlineResource"/>
					</xsl:otherwise>
				</xsl:choose>
			</srv:SV_OperationMetadata>
		</srv:containsOperations>
	</xsl:template>
	<!-- TEMPLATE: GetFeatureInfo -->
	<xsl:template name="addGetFeatureInfoOpMetadata">
		<!--
			append GetFeatureInfo description
		-->
		<srv:containsOperations>
			<srv:SV_OperationMetadata>
				<srv:operationName>
					<gco:CharacterString>GetFeatureInfo</gco:CharacterString>
				</srv:operationName>
				<xsl:apply-templates select="Capability/Request/GetFeatureInfo/DCPType/HTTP"/>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Version</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Request</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: GetFeatureInfo</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Layers</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Styles</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>srs</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>BBOX</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>width</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>height</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Format</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>TRANSPARENT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>boolean</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>boolean</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>BGCOLOR</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>EXCEPTIONS</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>TIME</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>ELEVATION</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>QUERY_LAYERS</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>INFO_FORMAT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>FEATURE_COUNT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>x</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>y</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<xsl:choose>
					<xsl:when test="boolean(Capability/Request/GetFeatureInfo/DCPType/HTTP/*)">
						<xsl:apply-templates select="Capability/Request/GetFeatureInfo/DCPType/HTTP/Get/OnlineResource"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Capability/Request/GetFeatureInfo/DCPType/HTTP/Post/OnlineResource"/>
					</xsl:otherwise>
				</xsl:choose>
			</srv:SV_OperationMetadata>
		</srv:containsOperations>
	</xsl:template>
	<!-- TEMPLATE: DescribeLayer -->
	<xsl:template name="addDescribeLayerOpMetadata">
		<!--
			append DescribeLayer description
		-->
		<srv:containsOperations>
			<srv:SV_OperationMetadata>
				<srv:operationName>
					<gco:CharacterString>DescribeLayer</gco:CharacterString>
				</srv:operationName>
				<xsl:apply-templates select="Capability/Request/DescribeLayer/DCPType/HTTP"/>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Version</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Request</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Layers</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<xsl:choose>
					<xsl:when test="boolean(Capability/Request/DescribeLayer/DCPType/HTTP/*)">
						<xsl:apply-templates select="Capability/Request/DescribeLayer/DCPType/HTTP/Get/OnlineResource"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Capability/Request/DescribeLayer/DCPType/HTTP/Post/OnlineResource"/>
					</xsl:otherwise>
				</xsl:choose>
			</srv:SV_OperationMetadata>
		</srv:containsOperations>
	</xsl:template>
	<!-- TEMPLATE: GetLegendGraphic -->
	<xsl:template name="addGetLegendGraphicOpMetadata">
		<!--
			append GetLegendGraphic description
		-->
		<srv:containsOperations>
			<srv:SV_OperationMetadata>
				<srv:operationName>
					<gco:CharacterString>GetLegendGraphic</gco:CharacterString>
				</srv:operationName>
				<xsl:apply-templates select="Capability/Request/GetLegendGraphic/DCPType/HTTP"/>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Version</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>-</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Request</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: GetLegendGraphic</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Layer</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>Style</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>FEATURETYPE</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>RULE</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>SCALE</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>scale</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>SLD</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>SLD_BODY</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>FORMAT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>mandatory</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>WIDTH</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>HEIGHT</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>integer</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>integer</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<srv:parameters>
					<srv:SV_Parameter>
						<srv:name>
							<gco:aName>
								<gco:CharacterString>EXCEPTIONS</gco:CharacterString>
							</gco:aName>
							<gco:attributeType>
								<gco:TypeName>
									<gco:aName>
										<gco:CharacterString>String</gco:CharacterString>
									</gco:aName>
								</gco:TypeName>
							</gco:attributeType>
						</srv:name>
						<srv:direction>
							<srv:SV_ParameterDirection>in</srv:SV_ParameterDirection>
						</srv:direction>
						<srv:description>
							<gco:CharacterString>fixed value: DescribeLayer</gco:CharacterString>
						</srv:description>
						<srv:optionality>
							<gco:CharacterString>optional</gco:CharacterString>
						</srv:optionality>
						<srv:repeatability>
							<gco:Boolean>false</gco:Boolean>
						</srv:repeatability>
						<srv:valueType>
							<gco:TypeName>
								<gco:aName>
									<gco:CharacterString>String</gco:CharacterString>
								</gco:aName>
							</gco:TypeName>
						</srv:valueType>
					</srv:SV_Parameter>
				</srv:parameters>
				<xsl:choose>
					<xsl:when test="boolean(Capability/Request/GetLegendGraphic/DCPType/HTTP/*)">
						<xsl:apply-templates select="Capability/Request/GetLegendGraphic/DCPType/HTTP/Get/OnlineResource"/>
					</xsl:when>
					<xsl:otherwise>
						<xsl:apply-templates select="Capability/Request/GetLegendGraphic/DCPType/HTTP/Post/OnlineResource"/>
					</xsl:otherwise>
				</xsl:choose>
			</srv:SV_OperationMetadata>
		</srv:containsOperations>
	</xsl:template>
	<!-- TEMPLATE: HTTP Get/Post -->
	<xsl:template match="HTTP">
		<xsl:if test="boolean(Get)">
			<srv:DCP>
				<srv:DCPList codeList="SV_DCPTypeCode" codeListValue="HTTPGet"/>
			</srv:DCP>
		</xsl:if>
		<xsl:if test="boolean(Post)">
			<srv:DCP>
				<srv:DCPList codeList="SV_DCPTypeCode" codeListValue="HTTPPost"/>
			</srv:DCP>
		</xsl:if>
	</xsl:template>
	<!-- TEMPLATE: Online Resources -->
	<xsl:template match="OnlineResource">
		<srv:connectPoint>
			<gmd:CI_OnlineResource>
				<gmd:linkage>
					<gmd:URL>
						<xsl:value-of select="./@xlink:href"/>
					</gmd:URL>
				</gmd:linkage>
			</gmd:CI_OnlineResource>
		</srv:connectPoint>
	</xsl:template>
	<!-- TEMPLATE: operatesOn -->
	<xsl:template match="Layer">
		<xsl:if test="boolean(Name)">
			<srv:operatesOn>
				<gmd:MD_DataIdentification>
					<gmd:citation>
						<gmd:CI_Citation>
							<gmd:title>
								<gco:CharacterString>
									<xsl:value-of select="Title"/>
								</gco:CharacterString>
							</gmd:title>
							<gmd:date>
								<!--
									date is required but there is no way to to read its value from a WMS capabilities
									document; instead use current timestamp and revision as default
								-->
								<gmd:CI_Date>
									<gmd:date>
										<gco:DateTime>
											<xsl:value-of select="$DATETIME"/>
										</gco:DateTime>
									</gmd:date>
									<gmd:dateType>
										<gmd:CI_DateTypeCode codeList="CI_DateTypeCode" codeListValue="revision"/>
									</gmd:dateType>
								</gmd:CI_Date>
							</gmd:date>
							<gmd:identifier>
								<gmd:MD_Identifier>
									<gmd:code>
										<gco:CharacterString>
											<xsl:value-of select="Name"/>
										</gco:CharacterString>
									</gmd:code>
								</gmd:MD_Identifier>
							</gmd:identifier>
						</gmd:CI_Citation>
					</gmd:citation>
					<xsl:choose>
						<xsl:when test="Abstract">
							<gmd:abstract>
								<gco:CharacterString>
									<xsl:value-of select="Abstract"/>
								</gco:CharacterString>
							</gmd:abstract>
						</xsl:when>
						<xsl:otherwise>
							<gmd:abstract>
								<gco:CharacterString>
									<!-- use layer title as default abstract -->
									<xsl:value-of select="Title"/>
								</gco:CharacterString>
							</gmd:abstract>
						</xsl:otherwise>
					</xsl:choose>
					<!-- ISO 639-2 Bibliographic Code -->
					<gmd:language>
						<gco:CharacterString>eng</gco:CharacterString>
					</gmd:language>
					<gmd:topicCategory>
						<!--
							topicCategory is required but there is no way to read its value from a WMS capabilities
							document nor to set a meaningful default
						-->
						<gmd:MD_TopicCategoryCode>environment</gmd:MD_TopicCategoryCode>
					</gmd:topicCategory>
				</gmd:MD_DataIdentification>
			</srv:operatesOn>
		</xsl:if>
		<xsl:apply-templates select="Layer"/>
	</xsl:template>
	<!-- TEMPLATE: Bounding Box  -->
	<xsl:template match="LatLonBoundingBox">
		<srv:extent>
			<gmd:EX_Extent>
				<gmd:geographicElement>
					<gmd:EX_GeographicBoundingBox>
						<gmd:westBoundLongitude>
							<gco:Decimal>
								<xsl:value-of select="./@minx"/>
							</gco:Decimal>
						</gmd:westBoundLongitude>
						<gmd:eastBoundLongitude>
							<gco:Decimal>
								<xsl:value-of select="./@maxx"/>
							</gco:Decimal>
						</gmd:eastBoundLongitude>
						<gmd:southBoundLatitude>
							<gco:Decimal>
								<xsl:value-of select="./@miny"/>
							</gco:Decimal>
						</gmd:southBoundLatitude>
						<gmd:northBoundLatitude>
							<gco:Decimal>
								<xsl:value-of select="./@maxy"/>
							</gco:Decimal>
						</gmd:northBoundLatitude>
					</gmd:EX_GeographicBoundingBox>
				</gmd:geographicElement>
			</gmd:EX_Extent>
		</srv:extent>
	</xsl:template>
	<!-- TEMPLATE: SRS -->
	<xsl:template match="SRS">
		<gmd:referenceSystemInfo>
			<gmd:MD_ReferenceSystem>
				<gmd:referenceSystemIdentifier>
					<gmd:RS_Identifier>
						<gmd:code>
							<gco:CharacterString>
								<xsl:value-of select="."/>
							</gco:CharacterString>
						</gmd:code>
					</gmd:RS_Identifier>
				</gmd:referenceSystemIdentifier>
			</gmd:MD_ReferenceSystem>
		</gmd:referenceSystemInfo>
	</xsl:template>
	<!-- TEMPLATE: Coupled Resources - now mandatory for deegree WMS/WFS service metadata records:"further description of the data coupling in the case of tightly coupled services" -->
	<!-- NOTE: This is a hack! Based on a WMS getCapabilities response, there is no good way to know which service operations apply to which layer. Also, some <Layer> tags act as containers but I assume that GetMap will operate on those anyways. -->
	<xsl:template name="addCoupledResource">
		<xsl:for-each select="//Layer">
			<xsl:if test="boolean(Name)">
				<!-- *** GetMap *** -->
				<!-- NOTE: Only retreave <Layer> tags which have a <Name> child element. -->
				<srv:coupledResource>
					<srv:SV_CoupledResource>
						<!-- Name of the service operation: GetMap, GetFeatureInfo, etc. -->
						<srv:operationName>
							<gco:CharacterString>GetMap</gco:CharacterString>
						</srv:operationName>
						<!-- Name of the identifier of a given tightly coupled dataset. -->
						<srv:identifier>
							<gco:CharacterString>
								<xsl:value-of select="Name"/>
							</gco:CharacterString>
						</srv:identifier>
						<!-- Scoped identifier of the resource in the context of the given service instance - OPTIONAL -->
						<!--<gco:ScopedName codeSpace="http://someurl">ArizonaGeologyLayer</gco:ScopedName>-->
					</srv:SV_CoupledResource>
				</srv:coupledResource>
				<!-- *** GetFeatureInfo *** -->
				<!-- NOTE: Only retreave <Layer> tags who have a queryable="1" property and a <Name> child element. -->
				<xsl:if test="@queryable = 1">
					<srv:coupledResource>
						<srv:SV_CoupledResource>
							<!-- Name of the service operation: GetMap, GetFeatureInfo, etc. -->
							<srv:operationName>
								<gco:CharacterString>GetFeatureInfo</gco:CharacterString>
							</srv:operationName>
							<!-- Name of the identifier of a given tightly coupled dataset. -->
							<srv:identifier>
								<gco:CharacterString>
									<xsl:value-of select="Name"/>
								</gco:CharacterString>
							</srv:identifier>
							<!-- Scoped identifier of the resource in the context of the given service instance - OPTIONAL -->
							<!--<gco:ScopedName codeSpace="http://someurl">ArizonaGeologyLayer</gco:ScopedName>-->
						</srv:SV_CoupledResource>
					</srv:coupledResource>
				</xsl:if>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>
