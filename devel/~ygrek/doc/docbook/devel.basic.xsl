<?xml version="1.0" encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
  <xsl:output method="html" encoding="windows-1251"/>

  <!-- Устанавливаем кодироку дял всех выходных форматов -->
  <xsl:param name="htmlhelp.encoding" select="'windows-1251'"></xsl:param>
  <xsl:param name="htmlhelp.output.encoding" select="'windows-1251'"></xsl:param>
  <xsl:param name="chunker.output.encoding" select="'windows-1251'"></xsl:param>

  <xsl:param name="generate.legalnotice.link" select="1"/>

  <!-- Включаем навигацию (переходы След. и Пред.) -->
  <xsl:param name="suppress.navigation" select="0"/>

  <!--xsl:param name="process.empty.source.toc" select="1"></xsl:param-->
  <!--xsl:param name="admon.graphics" select="1"/-->
  <!--xsl:param name="admon.graphics.path">gfx/</xsl:param-->

  <!--xsl:param name="html.stylesheet" select="'simple.css'"/-->

  <!-- Язык (чтобы компилятор chm выбрал правильную кодировку)-->
  <xsl:param name="l10n.gentext.default.language" select="'ru'"></xsl:param>

  <!-- Вроде как увеличивает скорость сборки немного -->
  <xsl:param name="chunk.fast" select="1"></xsl:param>

  <!-- Этот текст будет в шапке каждой страницы -->
  <xsl:template name="user.header.navigation">
    <hr></hr>
    <p>
    <a href="http://spf.sf.net">SP-Forth</a> documentation.
    </p>
    <hr></hr>
  </xsl:template>

</xsl:stylesheet>
