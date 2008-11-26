<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <xsl:output encoding="windows-1251" method="text"/>

  <xsl:template match="forthsourcecode">
  <xsl:for-each select="module">          <!-- Для каждого файла-->

    <xsl:for-each select="colon">         <!-- Для каждого определения через двоеточие-->
    <xsl:if test="@vocabulary='FORTH'">   <!-- Только те что экспортируются в общий словарь-->

      <xsl:value-of select="@name"/>    <!-- Имя слова-->
      <xsl:text> </xsl:text>
      <xsl:value-of select="../@name"/>  <!-- Имя файла-->
      <xsl:text> </xsl:text>
      <xsl:value-of select="@params"/>  <!-- Стековая нотация-->
      <xsl:text>&#xA;</xsl:text>

    </xsl:if>
    </xsl:for-each>

  </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>

