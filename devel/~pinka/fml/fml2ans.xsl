<?xml version="1.0" encoding="ASCII"?>
<xsl:stylesheet version="1.1"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
>
<!-- $Id$ -->
<!-- 
  01.2007 on SXSL
  03.2008 on XSL
-->

<xsl:import href="meta/stop-error.xsl"/>

<xsl:output
  encoding="Windows-1251"
  indent="yes"
  method="text"
/>


<xsl:template match="*">
  <xsl:call-template name="stop-error"/>
</xsl:template>


<!-- spf4 specific -->

<xsl:template match="f:again[not(node())]">
  <xsl:text> [ LATEST NAME> BRANCH, ] </xsl:text>
</xsl:template>
<xsl:template match="f:lit">
  <xsl:text>[ </xsl:text>
    <xsl:apply-templates />
  <xsl:text> LIT, ] </xsl:text>
</xsl:template>
<xsl:template match="f:slit">
  <xsl:text>[ </xsl:text>
    <xsl:apply-templates />
  <xsl:text> SLIT, ] </xsl:text>
</xsl:template>
<xsl:template match="f:exec">
  <xsl:text>[ </xsl:text>
    <xsl:apply-templates />
  <xsl:text> COMPILE, ] </xsl:text>
</xsl:template>

<!--  -->


<xsl:template match="f:def">  
  <xsl:text>: </xsl:text>
  <xsl:value-of select="@name"/><xsl:text> </xsl:text>
  <xsl:if test="@ds">
    <xsl:text>( </xsl:text>
      <xsl:value-of select="normalize-space(@ds)"/>
    <xsl:text> ) </xsl:text>
  </xsl:if>
  <xsl:apply-templates/>
  <xsl:text>;</xsl:text>
  <xsl:text> </xsl:text><!-- bug-around for msxsl -->
</xsl:template>

<xsl:template match="f:cell">
  <xsl:text>VARIABLE </xsl:text>
  <xsl:value-of select="@name"/>
  <xsl:if test="node()">
    <xsl:text> </xsl:text>
    <xsl:apply-templates />
    <xsl:value-of select="concat(' ', @name, ' !' )"/>
  </xsl:if>
</xsl:template>

<xsl:template match="f:const">
  <xsl:if test="node()">
    <xsl:text> </xsl:text>
    <xsl:apply-templates />
    <xsl:text> </xsl:text>
  </xsl:if>
  <xsl:text>CONSTANT </xsl:text>
  <xsl:value-of select="@name"/>
</xsl:template>

<xsl:template match="f:exit">
  <xsl:text>EXIT </xsl:text>
</xsl:template>

<xsl:template match="f:recurse">
  <xsl:text>RECURSE </xsl:text>
</xsl:template>

<xsl:template match="f:if" name="if">
  <xsl:text>IF </xsl:text>
    <xsl:apply-templates />
  <xsl:text>THEN </xsl:text>
</xsl:template>

<xsl:template match="f:unless">
  <xsl:text>0= </xsl:text><xsl:call-template name="if"/>
</xsl:template>

<xsl:template match="f:repeat">
  <xsl:text>BEGIN </xsl:text>
    <xsl:apply-templates />
  <xsl:text>AGAIN </xsl:text>
  <xsl:for-each select="f:while[not(node)]">
    <xsl:text>THEN </xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template match="f:until">
  <xsl:text>BEGIN </xsl:text>
  <xsl:apply-templates/>
  <xsl:text>UNTIL </xsl:text>
  <xsl:for-each select="f:while[not(node)]">
    <xsl:text>THEN </xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template match="f:while[not(node)]">
  <xsl:text>WHILE </xsl:text>
</xsl:template>

<xsl:template match="f:choose">
  <xsl:apply-templates/>
  <xsl:for-each select="f:when">
    <xsl:text>THEN </xsl:text>
  </xsl:for-each>
</xsl:template>

<xsl:template match="f:otherwise">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="f:when">
  <xsl:text>IF </xsl:text>
  <xsl:apply-templates/>
  <xsl:text>ELSE </xsl:text>
</xsl:template>



<xsl:template match="text()">
  <xsl:value-of select="."/>
</xsl:template>
<!--
<xsl:template match="text()[not( normalize-space(.) )]" />
-->

<xsl:template match="f:rem | f:comment | comment() ">
  <xsl:text>( </xsl:text>
    <xsl:value-of select="translate( . , '()', '[]' )"/>
  <xsl:text> ) </xsl:text>
</xsl:template>

<xsl:template match="f:g">
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="/*/f:include">
  <xsl:apply-templates select="document(@href)/*"/>
</xsl:template>

<xsl:template match="/*">
  <xsl:apply-templates/>
</xsl:template>


</xsl:stylesheet>