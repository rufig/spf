<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
>

<xsl:import href="fml2ans.xsl"/>

<xsl:template name="stop-error">
  <xsl:value-of select="concat('&lt;', name() )"/>
    <xsl:for-each select="@*">
      <xsl:value-of select="concat(' ', name(), '=&quot;', ., '&quot;' )"/>
    </xsl:for-each>
    <xsl:choose><xsl:when test="node()">
      <xsl:value-of select=" '&gt;' "/>
      <xsl:apply-templates/>
      <xsl:value-of select="concat('&lt;/', name(), '&gt;' )"/>
    </xsl:when><xsl:otherwise>
      <xsl:value-of select=" '/&gt;' "/>
    </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="f:wordlist">
  <xsl:text>&#xA;&#xA;MODULE: </xsl:text><xsl:value-of select="@name"/><xsl:text>-voc &#xA;</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>;MODULE &#xA;</xsl:text>
</xsl:template>

<xsl:template match="f:export">
  <xsl:text>EXPORT</xsl:text>
  <xsl:apply-templates/>
  <xsl:text>DEFINITIONS</xsl:text>
</xsl:template>

<xsl:template match="f:alias">
  <xsl:value-of select="concat(': ', @name, ' ', @word, ' ;' )"/>
</xsl:template>

<xsl:template match="f:include[ parent::f:wordlist | parent::f:export | parent::f:forth | parent::f:g ]" mode="off">
  <xsl:value-of select="concat('( ----- include ', @href, ' )&#xA;' )"/>
  <xsl:apply-templates select="document(@href)/*"/>
  <xsl:value-of select="concat('( ----- end of include ', @href, ' )&#xA;' )"/>
</xsl:template>

<xsl:template match="/">
  <xsl:text>( This rusult is for humans only, not for machine ;)</xsl:text>
  <xsl:apply-templates/>
</xsl:template>

<xsl:output
  encoding="Windows-1251"
  indent="yes"
  method="text"
/>

</xsl:stylesheet>