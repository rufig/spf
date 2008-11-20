<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
  <xsl:output encoding="windows-1251" method="xml" indent="yes"/>

  <xsl:template match="forthsourcecode">
  <xsl:for-each select="module">          <!-- Для каждого файла-->
  <section>                               <!-- Раздел-->
    <xsl:attribute name="id">
      <xsl:value-of select="@name"/>
    </xsl:attribute>

    <title>
      <xsl:value-of select="@name"/>      <!-- Имя файла-->
    </title>

    <section id="toc-section">
      <title>
      Описание
      </title>
      <xsl:call-template name="print-comments"/>
    </section>

    <xsl:for-each select="colon">         <!-- Для каждого определения через двоеточие-->
    <xsl:if test="@vocabulary='FORTH'">   <!-- Только те что экспортируются в общий словарь-->

    <section>
      <xsl:attribute name="id">
        <xsl:value-of select="concat(../@name,'/',@name)"/>
      </xsl:attribute>

      <indexterm type="word">
        <primary>
          <xsl:value-of select="@name"/>  <!-- Индекс по имени слова-->
        </primary>
        <!--primaryie>
          <xsl:value-of select="parent::module/@name"/>
        </primaryie-->
      </indexterm>

      <title>
        <xsl:value-of select="@name"/>    <!-- Имя слова-->
      </title>

      <para>
        <xsl:value-of select="@params"/>  <!-- Стековая нотация-->
      </para>

      <xsl:variable name="FirstComment">
        <xsl:value-of select="comment"/>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="string-length($FirstComment)!=0">
            <para>
              <xsl:call-template name="print-comments"/>
            </para>
        </xsl:when>
        <xsl:otherwise>
          <simpara><xsl:text> </xsl:text></simpara>

          <xsl:if test="$xmlhelp.allstack!=0">
          <xsl:call-template name="allstack">
            <xsl:with-param name = "S" >
              <xsl:value-of select="@params" />
            </xsl:with-param>
          </xsl:call-template>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>

    </section>
    </xsl:if>
    </xsl:for-each>

  </section>
  </xsl:for-each>
  </xsl:template>

  <!-- *********************************************************** -->

  <xsl:template name="print-comments">
      <xsl:for-each select="comment">          <!-- Описание (из либы)-->
        <xsl:value-of select="."/>
        <xsl:if test="position()!=last()">
          <sbr/>                             <!-- THIS BREAKS VALIDATION !!! -->
        </xsl:if>
      </xsl:for-each>
  </xsl:template>


  <!-- *********************************************************** -->

  <!-- Подготавливает шаблоны для описания параметров -->

  <xsl:template name = "allstack" >
    <xsl:param name = "S"/>

    <xsl:call-template name = "allstack-norm-try" >
       <xsl:with-param name = "S" >
         <xsl:value-of select="normalize-space($S)" />
       </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <!-- *********************************************************** -->

  <!-- Функция проверяет что у нас есть параметры которые следает описать
       и в случае успеха вызывает allstak-norm
  -->

  <xsl:template name = "allstack-norm-try" >
      <xsl:param name = "S"/>

      <xsl:variable name="Word">
        <xsl:value-of select="substring-before($S,' ')"/>
      </xsl:variable>

      <xsl:if test="string-length($Word)>0">

         <xsl:if test="$Word != '|' and $Word != '\' and $Word != '--'">

          <xsl:choose>

            <xsl:when test="$Word!='(' and $Word!='{'">

            <!-- There are stack parameters so we can safely instantiate variablelist -->

               <variablelist>

               <xsl:call-template name = "allstack-norm" >
                  <xsl:with-param name = "S" >
                    <xsl:value-of select="$S" />
                  </xsl:with-param>
               </xsl:call-template>

               </variablelist>

            </xsl:when>

            <xsl:otherwise>

            <!-- Else try till we become sure that we get a valid stack parameter-->

              <xsl:call-template name = "allstack-norm-try" >
                <xsl:with-param name = "S" >
                   <xsl:value-of select="substring-after($S,' ')" />
                </xsl:with-param>
              </xsl:call-template>

            </xsl:otherwise>

          </xsl:choose>

      </xsl:if>

    </xsl:if>

  </xsl:template>


  <!-- *********************************************************** -->

  <xsl:template name = "allstack-norm" >
      <xsl:param name = "S"/>

      <xsl:variable name="Word">
        <xsl:value-of select="substring-before($S,' ')"/>
      </xsl:variable>

      <xsl:if test="string-length($Word)>0">

         <xsl:if test="$Word != '|' and $Word != '\' and $Word != '--'">

            <xsl:if test="$Word!='(' and $Word!='{'">

                <varlistentry>                      <!-- Описание параметров - шаблон -->
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

  <!-- *********************************************************** -->

</xsl:stylesheet>
