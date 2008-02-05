<?xml version="1.0" encoding="ASCII" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="http://www.w3.org/1999/XSL/TransformAlias"
  xmlns="http://forth.org.ru/2006/SXSL/"
  xmlns:f="http://forth.org.ru/ForthML/"
  xmlns:r="http://forth.org.ru/ForthML/Rules/"
  xmlns:xi="http://forth.org.ru/2006/XML/Struct"
>
<!--
  (c) 2007 ruvim@forth.org.ru
  License: LGPL
-->

<xsl:output
  encoding="UTF-8"
/>

<xsl:namespace-alias stylesheet-prefix="x"  result-prefix="xsl" />

<xsl:include href="stop-error.xsl"/>

<xsl:template match="*" >
  <xsl:call-template name="stop-error"/>
</xsl:template>

<xsl:template match="r:rule//text()[ normalize-space(.) ]">
  <T><xsl:value-of select="normalize-space(.)"/></T>
</xsl:template>

<xsl:template match="r:direct | r:postpone | r:yield"><!-- them trans to SXSL ns  as is -->
  <xsl:element name="{name()}"><xsl:copy-of select="@*"/><xsl:apply-templates /></xsl:element>
</xsl:template>

<xsl:template match="r:get-attribute">
  <T><xsl:text>`</xsl:text><x:value-of select="@{@name}"/></T>
</xsl:template>

<xsl:template match="r:m">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="r:for-each">
  <x:for-each select="{@select}">
    <xsl:apply-templates />
  </x:for-each>
</xsl:template>

<xsl:template match="r:rule" ><!-- top-level-element only -->
  <def match="{@match}">
    <xsl:apply-templates />
  </def>
</xsl:template>

<xsl:template match="r:rule[@mode | @test]" >
  <xsl:call-template name="stop-error"/>
</xsl:template>

<xsl:template match="f:forth | r:transform ">
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="/">
  <xi:include>
    <xsl:apply-templates />
  </xi:include>
</xsl:template>

</xsl:stylesheet>