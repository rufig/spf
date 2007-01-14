<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <xsl:output encoding="windows-1251" method="xml" indent="yes"/>

  <xsl:template match="forthsourcecode">
  <xsl:for-each select="module">          <!-- „«п Є ¦¤®Ј® д ©« -->
  <chapter>                               <!-- ђ §¤Ґ«-->
    <xsl:attribute name="id">
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    <title>
      <xsl:value-of select="@name"/>      <!-- €¬п д ©« -->
    </title>

    <section id="toc-section">            <!-- ЋЈ« ў«Ґ­ЁҐ-->
      <para>{DESCRIPTION}</para>
      <toc id="toc"/>
    </section>

    <xsl:for-each select="colon">         <!-- „«п Є ¦¤®Ј® ®ЇаҐ¤Ґ«Ґ­Ёп зҐаҐ§ ¤ў®Ґв®зЁҐ-->
    <xsl:if test="@vocabulary='FORTH'">   <!-- ’®«мЄ® вҐ зв® нЄбЇ®авЁаговбп ў ®ЎйЁ© б«®ў ам-->
    <section>
      <xsl:attribute name="id">
        <xsl:value-of select="generate-id()"/>
      </xsl:attribute>
      <title>
        <xsl:value-of select="@name"/>    <!-- €¬п б«®ў -->
      </title>
      <indexterm type="word">
        <primary>
          <xsl:value-of select="@name"/>  <!-- €­¤ҐЄб Ї® Ё¬Ґ­Ё б«®ў -->
        </primary>
      </indexterm>
      <para>
        <emphasis>
        <xsl:value-of select="@params"/>  <!-- ‘вҐЄ®ў п ­®в жЁп-->
        </emphasis>
      </para>
      <para>
        <xsl:value-of select="comment"/>  <!-- Љ®¬¬Ґ­в аЁЁ-->
      </para>
    </section>
    </xsl:if>
    </xsl:for-each>

  </chapter>
  </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
