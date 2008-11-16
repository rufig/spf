<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
<xsl:output method="text"/>

  <xsl:template name="section">
    <xsl:for-each select="lib">
    <xsl:value-of select="concat('make source/',src,'.docbook')"/>
    <xsl:text>
</xsl:text>  
    </xsl:for-each>
  </xsl:template>

 <xsl:template match="/">
  <xsl:for-each select="spf_devel/section">
    <xsl:call-template name="section"/>
  </xsl:for-each>
 </xsl:template>

</xsl:stylesheet>
