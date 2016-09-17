<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xs="http://www.w3.org/2001/XMLSchema"
  xmlns:dccoll="http://dita-community.org/collation"
  exclude-result-prefixes="#all"
  version="2.0">
  <!-- ==============================================================
       Collation utilities
       
       Provides locale-specific implementation of general getSortKey()
       function that can be used to get the sort value for with with
       xsl:sort.
       
       Uses data provided by the CC-CEDICT project:
       
       http://www.mdbg.net/chindict/chindict.php?page=cedict
       
       Copyright (c) 2016 dita-community.org
       
       =============================================================== -->
  
  <xsl:variable name="lookupZhCn" as="element()"
    select="document('../resources/lookup-zh-cn.xml')/*"
  />
    
  <!-- Given a DITA element, returns the sort key for 
       the element.
       
       @param context The element to get the sort key for
       @param lang The @xml:lang value to get the sort key for, e.g. "zh-CN".
       @return The sort key. For elements that have no natural sort key,
       will use the first 20 characters of the element's normalize-space() value.
    -->
  <xsl:function name="dccoll:getSortKey" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:sequence select="dccoll:getSortKey($context, $lang, false())"/>
  </xsl:function>
  
  <!-- Given a DITA element, returns the sort key for 
       the element.
       
       @param context The element to get the sort key for
       @param lang The @xml:lang value to get the sort key for, e.g. "zh-CN".
       @param debug Set to true() to turn on runtime debugging.
       @return The sort key. For elements that have no natural sort key,
       will use the first 20 characters of the element's normalize-space() value.
    -->
  <xsl:function name="dccoll:getSortKey" as="xs:string">
    <xsl:param name="context" as="element()"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="debug" as="xs:boolean"/>

    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getSortKey(): Handling element <xsl:value-of 
        select="concat(name($context/..), '/', name($context))"/>, text="<xsl:value-of 
          select="substring(normalize-space($context), 1, 20)"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="sortKey">
      <xsl:apply-templates mode="dccoll:getSortKey" select="$context">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$debug"/>
        <xsl:with-param name="lang" as="xs:string" select="$lang"/>
      </xsl:apply-templates>
    </xsl:variable>
    <xsl:variable name="result" as="xs:string" select="normalize-space($sortKey)"/>
    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getSortKey(): Returning "<xsl:value-of select="$result"/>"</xsl:message>
    </xsl:if>
    <xsl:sequence select="$result"></xsl:sequence>
  </xsl:function>
  
  <xsl:template mode="dccoll:getSortKey" match="*">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes"/>
    <xsl:param name="lang" as="xs:string" select="'en-US'"/>
    
    <xsl:variable name="sortKeyBase">
      <xsl:apply-templates mode="dccoll:getSortKey_base" select=".">
        <xsl:with-param name="doDebug" as="xs:boolean" tunnel="yes" select="$doDebug"/>
      </xsl:apply-templates>
    </xsl:variable>
    
    <xsl:variable name="localeSpecificSortKey" as="xs:string"
      select="dccoll:getLocaleSpecificSortKey(normalize-space($sortKeyBase), $lang, $doDebug)"
    />
    <xsl:sequence select="$localeSpecificSortKey"/>
  </xsl:template>
  
  <xsl:function name="dccoll:getLocaleSpecificSortKey" as="xs:string">
    <xsl:param name="sortKeyBase" as="xs:string"/>
    <xsl:param name="lang" as="xs:string"/>
    <xsl:param name="debug" as="xs:boolean"/>

    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getLocaleSpecificSortKey: lang="<xsl:value-of select="$lang"/>", sortKeyBase="<xsl:value-of select="$sortKeyBase"/>"</xsl:message>
    </xsl:if>
    
    <xsl:choose>
      <xsl:when test="matches($lang, 'zh-cn', 'i')">
        <xsl:if test="$debug">
          <xsl:message> + [DEBUG] dccoll:getLocaleSpecificSortKey:   Getting zh-CN sort key...</xsl:message>
        </xsl:if>
        <xsl:sequence select="dccoll:getZhCnSortKey($sortKeyBase, $debug)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="$debug">
          <xsl:message> + [DEBUG] dccoll:getLocaleSpecificSortKey:   Getting other language sort key...</xsl:message>
        </xsl:if>
        <xsl:sequence select="$sortKeyBase"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:function>
  
  <xsl:function name="dccoll:getZhCnSortKey" as="xs:string">
    <xsl:param name="sortKeyBase" as="xs:string"/>
    <xsl:param name="debug" as="xs:boolean"/>
    
<!--    <xsl:variable name="debug" as="xs:boolean" select="$sortKeyBase = '束流关断'"/>-->

    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getZhCnSortKey: sortKeyBase="<xsl:value-of select="$sortKeyBase"/>"</xsl:message>
    </xsl:if>
    
    <xsl:variable name="sortKey" as="xs:string?" select="dccoll:lookupZhCnSortKey($sortKeyBase, $debug)"/>
    
    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getZhCnSortKey:   Returning "<xsl:value-of select="$sortKey"/>"</xsl:message>
    </xsl:if>    
    
    <xsl:if test="empty($sortKey) and not(matches($sortKeyBase, '^[a-zA-Z0-9]'))">
      <xsl:message> + [WARN] dccoll:getZhCnSortKey(): Did not find a sort key for text "<xsl:value-of select="$sortKeyBase"/>"</xsl:message>
    </xsl:if>
    
    <xsl:sequence select="($sortKey, $sortKeyBase)[1]"/>
  </xsl:function>
  
  <xsl:function name="dccoll:lookupZhCnSortKey" as="xs:string?">
    <xsl:param name="sortKeyBase" as="xs:string"/>
    <xsl:param name="debug" as="xs:boolean"/>
    
    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:getZhCnSortKey: sortKeyBase=<xsl:sequence select="$sortKeyBase"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="item" as="element()?"
      select="($lookupZhCn/item[@key = $sortKeyBase])[1]"
    />
    
    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:lookupZhCnSortKey:   item=<xsl:sequence select="$item"/></xsl:message>
    </xsl:if>
    
    <xsl:variable name="sortKey" as="xs:string?"
      select="if (exists($item)) 
      then lower-case($item/@value)
      else if (string-length($sortKeyBase) gt 1) 
              then dccoll:lookupZhCnSortKey(substring($sortKeyBase, 1, string-length($sortKeyBase) - 1), $debug) 
              else ()"
    />
    
    <xsl:if test="$debug">
      <xsl:message> + [DEBUG] dccoll:lookupZhCnSortKey:   Returning <xsl:sequence select="$sortKey"/></xsl:message>
    </xsl:if>
    
    <xsl:sequence select="$sortKey"/>
  </xsl:function>
  
  <!-- ===================================
       Get Sortkey Base
       
       Templates to construct the sort key
       for different element types.
       =================================== -->
  
  <xsl:template mode="dccoll:getSortKey_base" match="*[contains(@class, ' glossentry/glossentry ')]">
    <xsl:param name="doDebug" as="xs:boolean" tunnel="yes" select="false()"/>
    
    <xsl:variable name="sortkey"
      select="normalize-space(*[contains(@class, ' topic/title ')])"
    />
    <xsl:if test="$doDebug">
      <xsl:message> + [DEBUG] dccoll:getSortKey_base: <xsl:value-of select="concat(name(..), '/', name(.))"/>: Returning "<xsl:value-of select="$sortkey"/>"</xsl:message>
    </xsl:if>
    <xsl:sequence select="$sortkey"/>
  </xsl:template>
  
  
</xsl:stylesheet>