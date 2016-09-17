<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:local="urn:ns:local-functions"
  xmlns:dccoll="http://dita-community.org/collation"
  exclude-result-prefixes="#all"
  version="2.0">
  
  <!-- ===========================================
       Simple glossary sort transform to test
       collation utilities.
       
       Input is a DITA map.
       
       Looks for a topicref with a navtitle of "Glossary"
       and sorts all of its child topicrefs that 
       point to glossary entry topics.
       
       Output is a single HTML file reflecting the sorted 
       glossary.
       =========================================== -->
  
  <xsl:import href="../../xsl/collation-utils.xsl"/>
  
  <xsl:template match="/">
        
    <html>
      <head>
        <title><xsl:value-of select="*/*[contains(@class, ' topic/title ')]"/></title>
      </head>
      <body>
        <xsl:apply-templates/>
      </body>
    </html>
    
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/map ')]">
    <div>
      <xsl:apply-templates>
        <xsl:with-param name="lang" as="xs:string" tunnel="yes" select="@xml:lang"/>
      </xsl:apply-templates>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/topicref ')][@format = ('ditamap')]" priority="10">
    
    <xsl:variable name="targetDoc" as="document-node()?"
      select="document(@href, .)"
    />
    <xsl:apply-templates select="$targetDoc/*/*[contains(@class, ' map/topicref ')]"/>
    
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/topicref ')][not(@href)][*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]]" priority="10">
    <div class="{name(.)}">
      <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
      <xsl:apply-templates select="*[contains(@class, ' map/topicref ')]"/>
    </div>
  </xsl:template>
  
  <xsl:template priority="20"
    match="*[contains(@class, ' map/topicref ')][not(@href)]
    [matches(*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')], 'glossary', 'i')]"
    
    >
    <xsl:param name="lang" as="xs:string" tunnel="yes" select="'en-US'"/>
    <div class="glossary">
      <xsl:apply-templates select="*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')]"/>
      <xsl:for-each select="*[contains(@class, ' map/topicref ')]">
        <xsl:sort select="local:getSortKeyForTopicref(., $lang)"/>
        <xsl:apply-templates select="."/>
      </xsl:for-each>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/navtitle ')]">
    <xsl:variable name="level"
      select="count(ancestor::*[contains(@class, ' map/topicref ')][not(@format = ('ditamap'))])"
    />
    <xsl:element name="h{$level}">
      <xsl:apply-templates/>
    </xsl:element>    
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' map/topicref ')][@href][not(@format) or @format = ('dita')]">
    <xsl:variable name="targetDoc" as="document-node()?"
      select="document(@href, .)"
    />
    <xsl:apply-templates select="$targetDoc/*"/>
    
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]">
    <div class="{name(.)}" id="@id">
      <xsl:apply-templates/>
    </div>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' topic/title ')]">
    <h2><xsl:apply-templates/></h2>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossterm ')]" priority="10">
    <h2><xsl:apply-templates/> (<xsl:value-of select="dccoll:getSortKey(., 'zh-CN')"/>)</h2>
  </xsl:template>
  
  <xsl:template match="*[contains(@class, ' glossentry/glossdef ')][not(*[contains(@class, ' topic/p ')])]">
    <div class="{name(.)}">
      <p><xsl:apply-templates/></p>
    </div>
  </xsl:template>
  
  
  <xsl:template match="*[contains(@class, ' topic/topic ')]//*" priority="-1">
    <xsl:apply-templates/>
  </xsl:template>
  
  <xsl:function name="local:getSortKeyForTopicref" as="xs:string">
    <xsl:param name="topicref" as="element()"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:sequence select="local:getSortKeyForTopicref($topicref, $lang, false())"/>
  </xsl:function>
  
  <xsl:function name="local:getSortKeyForTopicref" as="xs:string">
    <xsl:param name="topicref" as="element()"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="debug" as="xs:boolean"/>
      
    <xsl:variable name="targetDoc" as="document-node()?"
    select="if ($topicref/@href) then document($topicref/@href, $topicref) else ()"
    />
    <xsl:choose>
      <xsl:when test="exists($targetDoc)">
        <xsl:sequence select="dccoll:getSortKey($targetDoc/*, $lang, $debug)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:sequence select="normalize-space(($topicref/*[contains(@class, ' map/topicmeta ')]/*[contains(@class, ' topic/navtitle ')], $topicref/@href, name($topicref))[1])"/>
      </xsl:otherwise>
    </xsl:choose>
    
  </xsl:function>
  
</xsl:stylesheet>