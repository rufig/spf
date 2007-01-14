<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="htmlhelp/htmlhelp.xsl"/>

  <xsl:include href="devel.basic.xsl"/>

  <xsl:param name="htmlhelp.chm" select="'devel.chm'"/>
  <xsl:param name="htmlhelp.hhp" select="'devel.hhp'"/>
  <xsl:param name="htmlhelp.hhc" select="'devel.hhc'"/>
  <xsl:param name="htmlhelp.hhk" select="'devel.hhk'"/>

  <xsl:param name="htmlhelp.hhc.binary" select="0"/>
  <xsl:param name="htmlhelp.hhc.folders.instead.books" select="0"/>

  <xsl:param name="base.dir" select="parts"></xsl:param>

  <xsl:param name="toc.section.depth" select="4"/>
  <xsl:param name="generate.toc">
  chapter nop
  section nop
  </xsl:param>


</xsl:stylesheet>
