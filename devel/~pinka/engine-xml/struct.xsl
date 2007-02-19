<?xml version="1.0" encoding="windows-1251" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://forth.org.ru/2006/XML/Struct"
  exclude-result-prefixes="xi"
>
<!--
  \ Apr.2006
  $Id$

  (c) 2006-2007 ruvim@forth.org.ru
  License: LGPL
-->

<xsl:output
  encoding="UTF-8"
/>

<!--<xsl:strip-space elements="xi:*" /> --> <!-- use xml:space="preserve" for -->

<xsl:template match="*" >
  <xsl:param name="links" />
  <xsl:choose><xsl:when test="*">

    <xsl:copy><xsl:copy-of select="@*"/>
      <xsl:apply-templates><xsl:with-param name="links" select="$links | xi:model"/></xsl:apply-templates>
    </xsl:copy>
  </xsl:when><xsl:otherwise>

    <xsl:copy-of select="."/>
    <!-- чтобы не было закрывающих тегов, когда исходно закрывается сразу -->
  </xsl:otherwise></xsl:choose>

  <xsl:if test="name(.) = 'div' ">
    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:if>
</xsl:template>


<xsl:template match="/" >
  <xsl:param name="links"/>
  <!-- При трансляции вложенных document там есть и "/" и параметр links  -->
  <!-- В начальном же документе параметра links нету -->
  <xsl:choose><xsl:when test="$links">
    <xsl:apply-templates><xsl:with-param name="links" select="$links | xi:model"/></xsl:apply-templates>
  </xsl:when><xsl:otherwise>
    <xsl:apply-templates><xsl:with-param name="links" select="xi:model"/></xsl:apply-templates>
  </xsl:otherwise></xsl:choose>
</xsl:template>


<xsl:template name="debug-links-param" >
  <xsl:param name="links"/>
  <xsl:for-each select="$links">
    <def name="{@name}" href="{@href}" bind="{@bind}" parse="{@parse}" childs="{count(*)}, {string-length(.)}"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template name="debug-links" >
  <xsl:param name="links"/>
  <xsl:text>&#x0D;&#x0A;</xsl:text>
  <debug-links current-node="{name(.)}" childs="{count(*)}, {string-length(.)}"><xsl:copy-of select="@name | @href" xml:space="preserve"/>
    <xsl:text>&#x0D;&#x0A;</xsl:text>

    <xsl:call-template name="debug-links-param">
      <xsl:with-param name="links" select="xi:model"/>
    </xsl:call-template>

    <links-param c="{count($links)}"><xsl:text>&#x0D;&#x0A;</xsl:text>
    <xsl:call-template name="debug-links-param">
      <xsl:with-param name="links" select="$links"/>
    </xsl:call-template>
    </links-param>

    <xsl:text>&#x0D;&#x0A;</xsl:text>
  </debug-links>
</xsl:template>
<!-- example:
  <xsl:call-template name="debug-links"><xsl:with-param name="links" select="$links"/></xsl:call-template>
-->


<xsl:template name="recurse" >
  <xsl:param name="links"/>
  <xsl:param name="link" />

  <xsl:for-each select="$link">
    <!-- ставлю текущим, чтобы при fallback исполнилось содержимое этого link -->

    <xsl:variable name="cut-links" select="$links[ count(.|$link) &gt; count( $link ) ]"/>
    <!-- из передаваемого контекста links исключаю этот $link -->

    <xsl:if test="$link/@bind = 'before' or $link/@advice='after' ">
      <xsl:call-template name="recurse">
        <xsl:with-param name="links" select="$cut-links"/>
        <xsl:with-param name="link"  select="$cut-links[@name = $link/@name][last()]"/>
      </xsl:call-template>
    </xsl:if>

    <xsl:call-template name="include">
      <xsl:with-param name="links" select="$cut-links"/>
      <xsl:with-param name="href"  select="$link/@href"/>
    </xsl:call-template>

    <xsl:if test="$link/@bind = 'after' or $link/@advice='before' ">
      <xsl:call-template name="recurse">
        <xsl:with-param name="links" select="$cut-links | xi:model"/>
        <xsl:with-param name="link"  select="$cut-links[@name = $link/@name][last()]"/>
      </xsl:call-template>
    </xsl:if>

  </xsl:for-each>

</xsl:template>

<xsl:template name="include-local" >
  <xsl:param name="links"/>
  <xsl:param name="href"/>

  <xsl:variable name="link" select="$links[@name = $href][last()]" />
  <!-- $links - линейный node-set, в котором однозначная нумерация и last() -->

  <xsl:choose><xsl:when test="$link">

    <xsl:choose><xsl:when test="not(@parse) or @parse = 'xml' ">
      <xsl:call-template name="recurse">
        <xsl:with-param name="links" select="$links"/>
        <xsl:with-param name="link"  select="$link"/>
      </xsl:call-template>

    </xsl:when><xsl:otherwise>
      <xsl:copy-of select="$link"/>
    </xsl:otherwise></xsl:choose>

  </xsl:when><xsl:otherwise>
    <!-- если нету такого link, выполняется 'fallback', по содержанию вызвавшего -->
    <xsl:choose><xsl:when test="not(@parse) or @parse = 'xml' ">
      <xsl:apply-templates ><xsl:with-param name="links" select="$links | xi:model"/></xsl:apply-templates>
    </xsl:when><xsl:otherwise>
      <xsl:copy-of select="node()"/>
    </xsl:otherwise></xsl:choose>

  </xsl:otherwise></xsl:choose>

</xsl:template>


<xsl:template name="include" >
  <xsl:param name="links"/>
  <xsl:param name="href"/>

  <xsl:choose><xsl:when test="string-length($href) = 0  or  starts-with($href, '#')">

    <xsl:call-template name="include-local">
      <xsl:with-param name="links" select="$links"/>
      <xsl:with-param name="href"  select="substring-after($href, '#')"/>
    </xsl:call-template>

  </xsl:when><xsl:otherwise>
    <xsl:choose><xsl:when test="not(@parse) or @parse = 'xml' ">
      <xsl:apply-templates select="document( $href )"><xsl:with-param name="links" select="$links"/></xsl:apply-templates>

    </xsl:when><xsl:otherwise>
      <xsl:copy-of select="document( $href )"/>
    </xsl:otherwise></xsl:choose>

  </xsl:otherwise></xsl:choose>
</xsl:template>


<xsl:template match="xi:model" />

<xsl:template match="xi:attribute" >
  <xsl:param name="links"/>

  <xsl:attribute name="{@name}">
    <xsl:call-template name="include">
      <xsl:with-param name="links" select="$links"/>
      <xsl:with-param name="href"  select="@href"/>
    </xsl:call-template>
  </xsl:attribute>
</xsl:template>

<xsl:template match="xi:include" >
  <xsl:param name="links"/>

  <xsl:call-template name="include">
    <xsl:with-param name="links" select="$links"/>
    <xsl:with-param name="href"  select="@href"/>
  </xsl:call-template>
</xsl:template>

</xsl:stylesheet>
