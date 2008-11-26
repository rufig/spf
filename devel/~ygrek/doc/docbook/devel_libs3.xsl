<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
<xsl:output method="text"/>

 <xsl:template match="/">
  <xsl:for-each select="spf_devel/section/lib">
    <xsl:value-of select="concat('xsltproc xmlhelp2words.xsl source/',src,'.xml')"/>
    <xsl:text>&#xA;</xsl:text>
  </xsl:for-each>
 </xsl:template>

</xsl:stylesheet>

