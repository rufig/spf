<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
>

<xsl:import href="fml2ans.xsl"/>

<xsl:template name="output-xml">
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

<xsl:template name="stop-error">
  <xsl:call-template name="output-xml"/>
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

<xsl:template match="f:develop">
  <xsl:value-of select="wordlist"/>
  <xsl:text> ALSO! GET-CURRENT >CS DEFINITIONS </xsl:text>
  <xsl:apply-templates/>
  <xsl:text> CS> SET-CURRENT PREVIOUS </xsl:text>
</xsl:template>

<xsl:template match="f:wid">
  <xsl:text> WORDLIST ALSO! GET-CURRENT >CS DEFINITIONS </xsl:text>
  <xsl:apply-templates/>
  <xsl:text> CS> SET-CURRENT CONTEXT @ PREVIOUS </xsl:text>
</xsl:template>

<xsl:template match="f:g[ @* ]">
  <xsl:call-template name="output-xml"/>
</xsl:template>

<xsl:template match="f:xt-of">
  <xsl:text> ['] </xsl:text>
  <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="f:alias" name="f.alias">
  <xsl:apply-templates />
  <xsl:text> `</xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:text> NAMING- </xsl:text>
</xsl:template>

<xsl:template match="f:alias[ @word ]">
  <xsl:text> ['] </xsl:text>
  <xsl:value-of select="@word"/>
  <xsl:call-template name="f.alias"/>
</xsl:template>

<xsl:template match="f:def//f:def">
  <xsl:call-template name="output-xml"/>
</xsl:template>

<xsl:template match="f:def//f:const">
  <xsl:apply-templates/>
  <xsl:text> MAKE-LIT `</xsl:text><xsl:value-of select="@name"/> 
  <xsl:text> NAMING- </xsl:text>
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