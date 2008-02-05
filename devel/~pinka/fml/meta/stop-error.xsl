<?xml version="1.0" encoding="ASCII" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

<xsl:template name="stop-error" >
  <xsl:message terminate = "yes">
    <xsl:text>Semantic undefined for: </xsl:text>
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text><xsl:value-of select="name()" />
    </xsl:for-each><xsl:text>
</xsl:text>
    <xsl:copy-of select="." />
  </xsl:message>
</xsl:template>

</xsl:stylesheet>