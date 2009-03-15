<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
>

<xsl:template match="*">
  <xsl:apply-templates select="*"/>
</xsl:template>

<xsl:template match="/*/f:def">
  <def><xsl:copy-of select="@*"/>
    <p>-</p>
  </def>
</xsl:template>

<xsl:template match="/">
  <book>
    <xsl:apply-templates select="*"/>
  </book>  
</xsl:template>

<xsl:output
  encoding="Windows-1251"
  indent="yes"
/>

</xsl:stylesheet>
