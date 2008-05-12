<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
<xsl:output method="text"/>

  <xsl:template match="section">
    <xsl:for-each select="lib">
    <xsl:value-of select="src"/>
    <xsl:text>
</xsl:text>  
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="spf_devel">
    <xsl:apply-templates select="section"/>
  </xsl:template>

</xsl:stylesheet>
