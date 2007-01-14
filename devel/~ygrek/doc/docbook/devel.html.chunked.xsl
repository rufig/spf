<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:import href="html/chunk.xsl"/>

  <xsl:include href="devel.basic.xsl"/>

  <xsl:param name="base.dir" select="'chunks\'"></xsl:param>

  <xsl:param name="root.filename" select="'devel'"></xsl:param>

  <!--xsl:param name="toc.section.depth" select="1"/-->
  <xsl:param name="toc.max.depth">1</xsl:param>
  <xsl:param name="generate.toc">
  book toc
  chapter toc
  section nop
  </xsl:param>



</xsl:stylesheet>
