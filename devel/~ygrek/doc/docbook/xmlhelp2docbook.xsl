<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <xsl:output encoding="windows-1251" method="xml" indent="yes"/>

  <xsl:template match="forthsourcecode">
  <xsl:for-each select="module">          <!-- „«п Є ¦¤®Ј® д ©« -->
  <section>                               <!-- ђ §¤Ґ«-->
    <xsl:attribute name="id">
      <xsl:value-of select="generate-id()"/>
    </xsl:attribute>
    <title>
      <xsl:value-of select="@name"/>      <!-- €¬п д ©« -->
    </title>

    <section id="toc-section">
      <para>{DESCRIPTION}</para>          <!-- ЋЇЁб ­ЁҐ (Ї®¤бв ў«пҐвбп б­ аг¦Ё)-->
      <toc id="toc"/>                     <!-- ЋЈ« ў«Ґ­ЁҐ-->
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
        <xsl:for-each select="comment">  <!-- Љ®¬¬Ґ­в аЁЁ-->
          <xsl:value-of select="."/>
           <xsl:if test="not (position()=last())">
               <sbr/>                    <!-- ЏҐаҐў®¤ бва®ЄЁ (Єа®¬Ґ Ї®б«Ґ¤­Ґ©)-->
          </xsl:if>
        </xsl:for-each>
      </para>
    </section>
    </xsl:if>
    </xsl:for-each>

  </section>
  </xsl:for-each>
  </xsl:template>
</xsl:stylesheet>
