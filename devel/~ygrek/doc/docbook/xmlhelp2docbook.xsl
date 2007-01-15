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
      <!--para>{DESCRIPTION}</para-->          <!-- ЋЇЁб ­ЁҐ (Ї®¤бв ў«пҐвбп б­ аг¦Ё)-->
      <para>                              <!-- ЋЇЁб ­ЁҐ (Ё§ «ЁЎл)-->
      <xsl:for-each select="comment">
        <xsl:value-of select="."/>
        <xsl:if test="not (position()=last())">
            <sbr/>                    <!-- ЏҐаҐў®¤ бва®ЄЁ (Єа®¬Ґ Ї®б«Ґ¤­Ґ©)-->
        </xsl:if>
      </xsl:for-each>
      </para>
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
        <primaryie>
          <xsl:value-of select="@name"/>  <!-- €­¤ҐЄб Ї® Ё¬Ґ­Ё б«®ў -->
        </primaryie>
      </indexterm>
      <para>
        <emphasis>
        <xsl:value-of select="@params"/>  <!-- ‘вҐЄ®ў п ­®в жЁп-->
        </emphasis>
      </para>
      <xsl:variable name="FirstComment">
        <xsl:value-of select="comment"/>
      </xsl:variable>

      <para>
      <xsl:choose>
        <xsl:when test="string-length($FirstComment)!=0">

          <xsl:for-each select="comment">  <!-- Љ®¬¬Ґ­в аЁЁ-->
            <xsl:value-of select="."/>
             <xsl:if test="not (position()=last())">
                 <sbr/>                    <!-- ЏҐаҐў®¤ бва®ЄЁ (Єа®¬Ґ Ї®б«Ґ¤­Ґ©)-->
            </xsl:if>
          </xsl:for-each>

        </xsl:when>
        <xsl:otherwise>

          <xsl:call-template name="allstack">
            <xsl:with-param name = "S" >
              <xsl:value-of select="@params" />
            </xsl:with-param>
          </xsl:call-template>

        </xsl:otherwise>
      </xsl:choose>
      </para>
    </section>
    </xsl:if>
    </xsl:for-each>

  </section>
  </xsl:for-each>
  </xsl:template>


  <xsl:template name = "allstack" >
    <xsl:param name = "S"/>

    <variablelist>

    <xsl:call-template name = "allstack-norm" >
       <xsl:with-param name = "S" >
         <xsl:value-of select="normalize-space($S)" />
       </xsl:with-param>
    </xsl:call-template>

    </variablelist>

  </xsl:template>

  <xsl:template name = "allstack-norm" >
      <xsl:param name = "S"/>

      <xsl:variable name="Word">
        <xsl:value-of select="substring-before($S,' ')"/>
      </xsl:variable>

      <xsl:if test="string-length($Word)>0">

         <xsl:if test="$Word != '|' and $Word != '\' and $Word != '--'">

            <xsl:if test="$Word!='(' and $Word!='{'">

                <varlistentry>                      <!-- ЋЇЁб ­ЁҐ Ї а ¬Ґва®ў - и Ў«®­ -->
                  <term>
                    <xsl:value-of select="$Word"/>
                  </term>
                  <listitem>
                  <simpara>
                  <xsl:text> </xsl:text>
                  </simpara>
                  </listitem>
                </varlistentry>

            </xsl:if>

            <xsl:call-template name = "allstack-norm" >
              <xsl:with-param name = "S" >
                 <xsl:value-of select="substring-after($S,' ')" />
              </xsl:with-param>
            </xsl:call-template>

         </xsl:if>

      </xsl:if>

  </xsl:template>

</xsl:stylesheet>
