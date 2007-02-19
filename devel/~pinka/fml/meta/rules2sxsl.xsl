<?xml version="1.0" encoding="ascii" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="http://www.w3.org/1999/XSL/TransformAlias"
  xmlns="http://forth.org.ru/2006/SXSL/"
  xmlns:f="http://forth.org.ru/ForthML/"
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

<xsl:template match="f:rule//text()">
  <xsl:variable name="text" select="normalize-space(.)"/>
  <xsl:if test="$text">
    <T><xsl:value-of select="$text"/></T>
  </xsl:if>
</xsl:template>

<xsl:template match="f:*">
  <xsl:choose><xsl:when test="node()">
    <xsl:element name="{name()}"><xsl:copy-of select="@*"/>
      <xsl:apply-templates />
    </xsl:element>
  </xsl:when><xsl:otherwise><!-- for msxsl -->
    <xsl:element name="{name()}"><xsl:copy-of select="@*"/></xsl:element>
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="f:get-attribute">
  <T><xsl:text>`</xsl:text><x:value-of select="@{@name}"/></T>
</xsl:template>

<xsl:template match="f:exec">
  <xsl:element name="{@name}" />
</xsl:template>

<xsl:template match="f:each-node">
  <x:for-each select="f:{@select}">
    <xsl:apply-templates />
  </x:for-each>
</xsl:template>

<xsl:template match="f:rule" ><!-- top-level-element only -->
  <def match="f:{@match}"><xsl:copy-of select="@name" />
    <xsl:apply-templates />
  </def>
</xsl:template>

<xsl:template match="f:rule[@mode]" >
  <xsl:message terminate = "yes">
    <xsl:text>'mode' is unsupported, context: </xsl:text>
    <xsl:text>
</xsl:text>
    <xsl:copy-of select="."/>
  </xsl:message>
</xsl:template>

<xsl:template match="f:forth">
  <xi:include>
    <xsl:apply-templates />
  </xi:include>
</xsl:template>

</xsl:stylesheet>