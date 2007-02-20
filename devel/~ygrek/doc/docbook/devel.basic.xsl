<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="windows-1251"/>

  <xsl:param name="htmlhelp.encoding" select="'windows-1251'"></xsl:param>
  <xsl:param name="htmlhelp.output.encoding" select="'windows-1251'"></xsl:param>
  <xsl:param name="chunker.output.encoding" select="'windows-1251'"></xsl:param>

  <xsl:param name="generate.legalnotice.link" select="1"/>
  <xsl:param name="suppress.navigation" select="0"/>
  <!--xsl:param name="process.empty.source.toc" select="1"></xsl:param-->
  <!--xsl:param name="admon.graphics" select="1"/-->
  <!--xsl:param name="admon.graphics.path">gfx/</xsl:param-->

  <!--xsl:param name="html.stylesheet" select="'simple.css'"/-->

  <xsl:param name="l10n.gentext.default.language" select="'ru'"></xsl:param>

  <xsl:template name="user.header.navigation">
    <hr></hr>
    <p>
    <a href="http://spf.sf.net">SP-Forth</a> documentation.
    </p>
    <hr></hr>
  </xsl:template>

</xsl:stylesheet>
