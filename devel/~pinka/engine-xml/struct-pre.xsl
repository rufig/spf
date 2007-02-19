<?xml version="1.0" encoding="windows-1251" ?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:xi="http://forth.org.ru/2006/XML/Struct"
>
<!--
  \ 16.Jun.2006
  $Id$

  (c) 2006-2007 ruvim@forth.org.ru
  License: LGPL
-->

<xsl:output
  encoding="UTF-8"
  omit-xml-declaration="no"
  indent="no"
/>

<xsl:strip-space elements = " xi:* " />
<xsl:preserve-space elements = " xsl:text " />

<xsl:template match="*" >
  <xsl:choose><xsl:when test="*">
    <xsl:copy><xsl:copy-of select="@*" />
      <xsl:apply-templates />
    </xsl:copy>
  </xsl:when><xsl:otherwise>
    <xsl:copy-of select="." />
    <!-- чтобы не было закрывающих тегов, когда исходно закрывается сразу -->
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="xsl:text" >
  <xsl:copy-of select="." />
</xsl:template>

<xsl:template name="put-instruct">
  <xsl:processing-instruction name="xml-stylesheet">
    <xsl:text>type="text/xsl" </xsl:text>
    <xsl:text>href="</xsl:text>
    <xsl:variable name='s1' select="substring-after(.,'href')" />
    <xsl:variable name='s2' select="substring-after($s1,'=')" />
    <xsl:variable name='q'><!-- ' = #39 , " = #34 -->
      <xsl:variable name='q' >'</xsl:variable>
      <xsl:choose><xsl:when test="starts-with(normalize-space($s2), $q)">
        <xsl:text>'</xsl:text>
      </xsl:when><xsl:otherwise>
        <xsl:text>"</xsl:text>
      </xsl:otherwise></xsl:choose>
    </xsl:variable>
    <xsl:variable name='s3' select="substring-after($s1,$q)" />
    <xsl:variable name='s4' select="substring-before($s3, $q)" />
    <xsl:if test="contains($s4, '/')">
      <xsl:value-of select="substring-before($s4, 'struct-pre.xsl')" />
    </xsl:if>
    <xsl:text>struct.xsl</xsl:text>
    <xsl:text>"</xsl:text>
  </xsl:processing-instruction>
</xsl:template>

<xsl:template match="/" >
  <xsl:for-each select="processing-instruction('xml-stylesheet')" >
    <xsl:call-template name="put-instruct" />
  </xsl:for-each>
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="/" mode = "child" >
  <xsl:apply-templates/>
</xsl:template>

<xsl:template match="xi:model[@href][not(starts-with(@href,'#'))]" >
  <xsl:copy>
    <xsl:copy-of select="attribute::*[name(.)!='href']" />
    <xsl:apply-templates select="document( @href )" mode="child" />
  </xsl:copy>
</xsl:template>

<xsl:template match="xi:include[not(@href) and not(@name)]" >
  <xsl:apply-templates />
</xsl:template>

<xsl:template match="xi:include[@href][not(starts-with(@href,'#'))]" >
  <xsl:choose><xsl:when test="@unwrap='yes'">
    <xsl:apply-templates select="document( @href )/*/node()" />
  </xsl:when><xsl:otherwise>
    <xsl:apply-templates select="document( @href )" mode="child" />
  </xsl:otherwise></xsl:choose>
</xsl:template>

</xsl:stylesheet>