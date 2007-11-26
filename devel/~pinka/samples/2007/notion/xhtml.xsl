<?xml version="1.0" encoding="Windows-1251"?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
>
<!-- 2007 -->
<!-- $Id$ -->

<xsl:output
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  omit-xml-declaration="yes"
/>

<xsl:template match="text()" mode="toc"/>
<xsl:template match="chapter" mode="toc">
  <li><a href="#{@id}"><xsl:value-of select="title"/></a></li>
</xsl:template>

<xsl:template match="*">
  <xsl:element name="{name()}"><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:element>
</xsl:template>

<xsl:template match="w">
  <span class="w"><xsl:apply-templates/><xsl:if test="@ds"> ( <xsl:value-of select="@ds"/> )</xsl:if></span>
</xsl:template>

<xsl:template match="title">
  <h3><a name="{../@id}"><xsl:apply-templates/></a></h3>
</xsl:template>

<xsl:template match="chapter">
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="toc">
  <div><h4>Содержание</h4>
  <ul><xsl:apply-templates mode="toc" select=".."/></ul>
  </div>
</xsl:template>

<xsl:template match="/">
<html><head>
<style>
  h3 { margin-top: 3em; }
  body { padding: 1em 5em 25em 2em; font-family: "Lucida Grande", sans-serif; line-height:150%;}
  p { margin: 0; margin-top: 0.5em; }
  ul { margin-top: 0.2em; margin-bottom: 0.2em;}
  *:target { border-bottom: 2px dotted gray;}
  .w { white-space: nowrap; font-family: monospace; font-weight: bold; color: #000066;}
</style>
</head><body>
  <xsl:apply-templates/>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
