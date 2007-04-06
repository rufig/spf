<?xml version="1.0" encoding="ascii" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:x="http://www.w3.org/1999/XSL/TransformAlias"
  xmlns:m="http://forth.org.ru/2006/SXSL/"
  xmlns:f="http://forth.org.ru/ForthML/"
  exclude-result-prefixes="m"
>
<!--
  \ Dec.2006
  $Id$
  (c) 2006-2007 ruvim@forth.org.ru
  License: LGPL
-->

<xsl:output
  encoding="UTF-8"
/>

<xsl:namespace-alias stylesheet-prefix="x"  result-prefix="xsl" />

<xsl:template name="stop-error" >
  <xsl:param name="yield-nodes" select="/.." />
  <xsl:param name="message">SXSL, Semantic undefined</xsl:param>
  <xsl:message terminate = "yes">
    <xsl:value-of select="$message"/><xsl:text>, context: </xsl:text>
    <xsl:value-of select="name()" /><xsl:text> | </xsl:text>
    <xsl:for-each select="$yield-nodes | .. ">
      <xsl:value-of select="name()" /><xsl:text> | </xsl:text>
    </xsl:for-each>
    <xsl:text>
</xsl:text>
    <xsl:copy-of select="." />
  </xsl:message>
</xsl:template>

<xsl:template match="*" >
  <xsl:param name="yield" select="/.." />
  <xsl:param name="yield-nodes" select="/.." />

  <xsl:copy>
  <xsl:copy-of select="@*" />
  <xsl:choose><xsl:when test="*">
      <xsl:apply-templates>
        <xsl:with-param name="yield" select="$yield" />
        <xsl:with-param name="yield-nodes" select="$yield-nodes" />
      </xsl:apply-templates>
  </xsl:when><xsl:when test="node()">
      <xsl:copy-of select="node()" />
  </xsl:when></xsl:choose>
  </xsl:copy>
</xsl:template>

<xsl:template match="/*/text()" mode="off" />

<xsl:template match="/*/m:var" >
  <x:variable name="{@name}" select="{@select}" />
</xsl:template>

<xsl:template name="params" >
  <xsl:for-each select="/*/m:var[@name]">
    <x:param name="{@name}" select="${@name}" />
  </xsl:for-each>
</xsl:template>

<xsl:template name="with-params" >
  <xsl:param name="yield-nodes" select="/.." />
  
  <xsl:variable name="sets" select="ancestor::m:set | $yield-nodes/ancestor::m:set " />

  <xsl:variable name="explisits" select="xsl:with-param" />

  <xsl:for-each select="/*/m:var[@name]">
    <xsl:choose><xsl:when test="$sets[@name = current()/@name]">
      <x:with-param name="{@name}" select="${@name}_" />
    </xsl:when><xsl:when test="$explisits[@name = current()/@name]">
      <!-- nothing -->
    </xsl:when><xsl:otherwise>
      <x:with-param name="{@name}" select="${@name}" />
    </xsl:otherwise></xsl:choose>
  </xsl:for-each>
</xsl:template>

<xsl:template match="m:set" >
  <xsl:param name="yield" select="/.." />
  <xsl:param name="yield-nodes" select="/.." />

  <xsl:variable name="id" select="generate-id(.)" />

  <x:variable name="set_{@name}_{$id}">
    <x:variable name="{@name}_" select="{@select}" />
    <xsl:apply-templates>
      <xsl:with-param name="yield" select="$yield" />
      <xsl:with-param name="yield-nodes" select="$yield-nodes" />
    </xsl:apply-templates>
  </x:variable><x:copy-of select="$set_{@name}_{$id}" />
</xsl:template>

<xsl:template name="mcall" >
  <xsl:param name="yield-nodes" select="/.." />

  <xsl:variable name="id" select="generate-id(.)" />
    <x:variable name="_{local-name()}_{$id}">

      <xsl:for-each select="/*/m:var[@name = $yield-nodes/ancestor::m:set/@name ]">
        <x:variable name="{@name}" select="${@name}_" />
      </xsl:for-each>
      <!-- ^ only for XSLT 2.0 processors, one's of XSLT 1.0 are not allowing name dups here -->

    <xsl:variable name="sub" select="/*/m:def[@name = local-name( current() ) ][last()]" />
    <xsl:if test="not($sub)"><xsl:call-template name="stop-error"/></xsl:if>
    <xsl:apply-templates select="$sub/node()">
      <xsl:with-param name="yield" select="current()" />
      <xsl:with-param name="yield-nodes" select="$yield-nodes" />
    </xsl:apply-templates>

  </x:variable><x:copy-of select="$_{local-name()}_{$id}" />

</xsl:template>

<xsl:template match="m:*" name="m.any">
  <xsl:param name="yield" select="/.." />
  <xsl:param name="yield-nodes" select="/.." />

  <xsl:choose><xsl:when test="node()">
    <xsl:if test="$yield"><xsl:call-template name="stop-error"><xsl:with-param name="message">SXSL, nesting substitute is not supported</xsl:with-param><xsl:with-param name="yield-nodes" select="$yield-nodes | $yield" /></xsl:call-template></xsl:if>
    <xsl:call-template name="mcall">
      <xsl:with-param name="yield-nodes" select="$yield-nodes " />
    </xsl:call-template>
  </xsl:when><xsl:otherwise>
    <x:call-template name="{local-name()}">
      <xsl:call-template name="with-params">
        <xsl:with-param name="yield-nodes" select="$yield-nodes " />
      </xsl:call-template>
    </x:call-template>
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="m:yield" name="m.yield">
  <xsl:param name="yield" select="/.." />
  <xsl:param name="yield-nodes" select="/.." />

  <xsl:choose><xsl:when test="$yield/self::text()">
      <xsl:value-of select="$yield" />

  </xsl:when><xsl:when test="$yield">

    <xsl:apply-templates select="$yield/node()" >
      <xsl:with-param name="yield-nodes" select="$yield-nodes | current()" />
    </xsl:apply-templates>

  </xsl:when><xsl:otherwise>

      <x:apply-templates>
        <xsl:call-template name="with-params">
          <xsl:with-param name="yield-nodes" select="$yield-nodes" />
        </xsl:call-template>
      </x:apply-templates>

  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="m:apply-templates | m:call-template">
  <xsl:param name="yield" select="/.." />
  <xsl:param name="yield-nodes" select="/.." />
  <xsl:element name="xsl:{local-name()}"><xsl:copy-of select="@name | @select | @mode" />
    <xsl:call-template name="with-params">
      <xsl:with-param name="yield-nodes" select="$yield-nodes" />
    </xsl:call-template>
    <xsl:apply-templates>
      <xsl:with-param name="yield" select="$yield" />
      <xsl:with-param name="yield-nodes" select="$yield-nodes" />
    </xsl:apply-templates>
  </xsl:element>
</xsl:template>

<xsl:template match="m:def"><!-- top-level-element only -->
  <x:template><xsl:copy-of select="@*" />
    <xsl:call-template name="params" />
    <xsl:apply-templates />
  </x:template>
</xsl:template>

<xsl:template match="m:def[@virtual]" /><!-- don't export to xsl:stylesheet -->

</xsl:stylesheet>