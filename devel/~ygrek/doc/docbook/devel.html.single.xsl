<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="http://docbook.sourceforge.net/release/xsl/current/html/docbook.xsl"/>

  <xsl:include href="devel.basic.xsl"/>

  <xsl:param name="toc.section.depth" select="4"/>

  <!-- Создавать оглавление для указанных разделов только -->
  <xsl:param name="generate.toc">
  chapter nop
  section nop
  </xsl:param>


</xsl:stylesheet>
