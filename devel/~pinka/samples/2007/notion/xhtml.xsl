<?xml version="1.0" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns="http://www.w3.org/1999/xhtml"
>
<xsl:output
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  omit-xml-declaration="yes"
/>

<xsl:template match="*">
  <xsl:element name="{name()}"><xsl:apply-templates/></xsl:element>
</xsl:template>

<xsl:template match="title">
  <h3><a name="{../@id}"><xsl:apply-templates/></a></h3>
</xsl:template>

<xsl:template match="chapter">
  <div><xsl:apply-templates/></div>
</xsl:template>

<xsl:template match="book">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/">
<html><head>
<style>
  h3 { margin-top: 2em; }
  body { padding: 1em; padding-right: 3em; padding-bottom: 25em;}
  p { margin: 0; margin-top: 0.5em; }
</style>
</head><body>
  <xsl:apply-templates/>
</body>
</html>
</xsl:template>

</xsl:stylesheet>
