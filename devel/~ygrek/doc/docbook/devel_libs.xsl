<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:xi="http://www.w3.org/2001/XInclude"
  version="1.0">
<xsl:output method="xml" version="1.0" indent="yes" encoding="windows-1251"/>

<xsl:template match="/">

<!--DOCTYPE book PUBLIC "-//OASIS//DTD DocBook XML V4.2//EN"
"http://www.oasis-open.org/docbook/xml/4.5/docbookx.dtd" []-->

<book>
  <bookinfo>
  <title>SPF devel doc</title>
  </bookinfo>

  <preface id="introduction">
    <title>Introduction</title>
    <para>
     Hello! Here's an introduction!
    </para>
  </preface>

  <index type="word" id="index"/>

  <xsl:for-each select="spf_devel/section">
    <xsl:call-template name="section"/>
  </xsl:for-each>

</book>

</xsl:template>  

<xsl:template name="section">

  <xsl:element name="chapter">
    <xsl:attribute name="id"><xsl:value-of select="@id"/></xsl:attribute>
    <title><xsl:value-of select="name/en"/></title>

    <xsl:element name="section">
      <xsl:attribute name="id"><xsl:value-of select="concat(@id,'-desc')"/></xsl:attribute>
      <title>Description</title>
      <para>some description here</para>
    </xsl:element>

    <xsl:for-each select="lib">
      <xsl:element name="xi:include">
        <xsl:attribute name="href"><xsl:value-of select="concat('source/',src,'.docbook')"/></xsl:attribute>
        <xi:fallback><para>Error: "<xsl:value-of select="src"/>" not found.</para></xi:fallback>
      </xsl:element>
    </xsl:for-each>
  </xsl:element>

</xsl:template>

</xsl:stylesheet>
