<?xml version="1.0" encoding="ascii" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
  xmlns="http://forth.org.ru/ForthML/"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  exclude-result-prefixes="f fn"
>

<xsl:output
  encoding="UTF-8"
/>

<xsl:template name="T-WORD">
  <xsl:param name="word" select="." />
  <xsl:choose>
  <xsl:when test="fn:matches($word, '^`\S+')">
    <xsl:value-of select="$word" /><xsl:text> STATE @ TS-SLIT </xsl:text>
  </xsl:when>
  <xsl:when test="fn:matches($word, '^-?\d+$')">
    <xsl:value-of select="$word" /><xsl:text> STATE @ TS-LIT </xsl:text>
  </xsl:when>
  <xsl:when test="fn:matches($word, '^0x\w+$')">
    <xsl:value-of select="$word" /><xsl:text> STATE @ TS-LIT </xsl:text>
  </xsl:when>
  <xsl:otherwise>
    <xt-of select="{$word}"/><xsl:text> STATE @ TS-EXEC </xsl:text>
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template name="T-TEXT">
  <xsl:param name="text" select="."/>
  <xsl:variable name="text2" select="normalize-space($text)" />
  <xsl:if test="$text2">
    <xsl:analyze-string select="$text2" regex="\S+"><xsl:matching-substring>
      <xsl:call-template name="T-WORD"/>
    </xsl:matching-substring></xsl:analyze-string>
  </xsl:if>
</xsl:template>


<xsl:template match="f:*">
  <xsl:copy><xsl:copy-of select="@*"/><xsl:apply-templates/></xsl:copy>
</xsl:template>

<xsl:template match="f:direct">
  <xsl:text>STATE 1-! </xsl:text>
  <xsl:apply-templates />
  <xsl:text>STATE 1+! </xsl:text>
</xsl:template>

<xsl:template match="f:postpone">
  <xsl:text>STATE 1+! </xsl:text>
  <xsl:apply-templates />
  <xsl:text>STATE 1-! </xsl:text>
</xsl:template>

<xsl:template match="f:yield">
  <xsl:text>trans-childs </xsl:text>
</xsl:template>

<xsl:template match="text()">
  <xsl:choose><xsl:when test="ancestor::f:rule[not(@mode='0')]">
    <xsl:call-template name="T-TEXT" />
  </xsl:when><xsl:otherwise>
    <xsl:copy-of select="normalize-space(.)" /><xsl:text> </xsl:text>
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="f:exec[@name][not( node() )]" >
  <xsl:value-of select="@name"/><xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="f:get-attribute[@name][not( node() )]" >
  <xsl:text>`</xsl:text><xsl:value-of select="@name"/><xsl:text> GetAttribute STATE @ TS-SLIT</xsl:text>
</xsl:template>

<xsl:template match="f:each-node">
  <xsl:text>cnode gtR `</xsl:text><xsl:value-of select="@select"/> <xsl:text> 2gtR 2R@ FirstChildByTagName </xsl:text>
  <repeat> cnode <while/> <xsl:apply-templates /> 2R@ NextSiblingByTagName</repeat>
  <xsl:text>RDROP RDROP Rgt cnode! </xsl:text>
</xsl:template>

<xsl:template match="f:rule">
  <!-- <xsl:text>`</xsl:text><xsl:value-of select="@match"/><xsl:text> 2DROP </xsl:text> -->
  <p>
  <xsl:if test="@mode">STATE @ <xsl:value-of select="@mode"/> neq <if> FALSE <exit/></if></xsl:if>
  NodeName `<xsl:value-of select="@match"/> CEQUAL 0= <if> FALSE <exit/></if>
  <xsl:apply-templates /> TRUE
  </p>
  <xsl:if test="@name">DUP `<xsl:value-of select="@name"/> NAMING- </xsl:if>
  advice-trule-before
</xsl:template>

</xsl:stylesheet>