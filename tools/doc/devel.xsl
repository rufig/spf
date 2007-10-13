<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<xsl:output encoding="utf-8" method="html" doctype-public="-//W3C//DTD HTML 4.01 Transitional//EN"/>

<!-- $Id$ -->
<!--
 Script for converting devel.xml to HTML 
 Expects string params :
 lang = en | ru
 usage = web | local
-->

<xsl:param name="usage">local</xsl:param>
<xsl:param name="lang">en</xsl:param>

<!-- main -->
<xsl:template match="spf_devel">
    <html>
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf8"/>
        <xsl:choose>
            <xsl:when test="$lang='en'">
            <title>SP-Forth: additional libraries</title>
            </xsl:when>
            <xsl:when test="$lang='ru'">
            <title>SP-Forth: дополнительные библиотеки</title>
            </xsl:when>
        </xsl:choose>
        <style type="text/css">
            body {background:white;}
            * {font-family: arial, verdana, sans-serif}
            code {font-family: 'Lucida Console', 'Courier New', monospace}
            pre, code { background : #EEEEF4}
            img.icon { vertical-align:bottom; margin-left:0.5em; margin-right:0.2em; border:0; }
        </style>
    </head>
    <body>
    
    <!-- SF logo -->
    <xsl:if test="$usage='web'">
        <a href="http://sourceforge.net">
        <img src="http://sourceforge.net/sflogo.php?group_id=17919" border="0" alt="SourceForge Logo"/>
        </a>
    </xsl:if>

    <div align="center">
    <table width="800">
    <tr><td align="left">
    
    <h1>
    <a href="readme.{$lang}.html">SP-Forth</a>
    <xsl:choose>
        <xsl:when test="$lang='en'"><xsl:text>: Additional libraries</xsl:text></xsl:when>
        <xsl:when test="$lang='ru'"><xsl:text>: Дополнительные библиотеки</xsl:text></xsl:when>
    </xsl:choose>
    </h1>
    
    <p><small><xsl:value-of select="meta/date"/></small></p>

    <p><em>
    <xsl:choose>
        <xsl:when test="$lang='en'">
        <xsl:text>REQUIRE is a forth word, which loads library; unnecessary text is commented out, so you can use this list as a forth code to include libs :)</xsl:text>
        </xsl:when>
        <xsl:when test="$lang='ru'">
        <xsl:text>REQUIRE это слово подключающее либу, всё лишнее закомментировано, так что можно использовать этот список как форт код при подключении либ :)</xsl:text>
        </xsl:when>
    </xsl:choose>
    </em></p>
    
    <hr/>

    <p>
    <xsl:choose>
        <xsl:when test="$lang='en'">
            <xsl:text>[</xsl:text>
	        <a href="devel.ru.html">Russian</a>
    	    <xsl:text>] [</xsl:text>
    	    <a href="devel.en.html">English</a>
    	    <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:when test="$lang='ru'">
            <xsl:text>[</xsl:text>
            <a href="devel.en.html">Английский</a>
            <xsl:text>] [</xsl:text>
            <a href="devel.ru.html">Русский</a>
            <xsl:text>]</xsl:text>
        </xsl:when>
    </xsl:choose>
    </p>

    <hr />

    <!-- Create index of entries -->
    <p>
    <xsl:for-each select="section">
        <xsl:text>[</xsl:text>
        <a href="#{@id}">
            <xsl:for-each select="name">
                <xsl:call-template name="lang"/>
            </xsl:for-each>
        </a>
        <xsl:text>] </xsl:text>
    </xsl:for-each>
    </p>

    <hr />

    <!-- sections -->
    <xsl:for-each select="section">
        <a id="{@id}"/>
        <xsl:element name="h3">
            <xsl:for-each select="name">
                <xsl:call-template name="lang"/>
            </xsl:for-each>
        </xsl:element>
        <xsl:element name="ul">
            <xsl:apply-templates select="lib | other"/>
        </xsl:element>
    </xsl:for-each>
    
    <!-- footer with copyrights -->
    
    <hr />
    
    <p><em>
    <xsl:choose>
        <xsl:when test="$lang='en'">
        <xsl:text>Used icons from </xsl:text>
        </xsl:when>
        <xsl:when test="$lang='ru'">
        <xsl:text>Использованы иконки </xsl:text>
        </xsl:when>
    </xsl:choose>
    <a href="http://tango.freedesktop.org/Tango_Icon_Library">Tango project</a>
    </em></p>

    </td></tr>
    </table>
    </div>
    </body>
    </html>
</xsl:template>

<xsl:template match="key">
  <xsl:value-of select="."/>
  <xsl:text> </xsl:text>
</xsl:template>

<xsl:template match="comment">
  <xsl:text> \ </xsl:text>
  <xsl:call-template name="lang"/>
</xsl:template>

<!-- each lib entry -->
<xsl:template match="lib">
  <xsl:element name="li">
      <xsl:text>REQUIRE </xsl:text>
      <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<!-- other entry -->
<xsl:template match="other">
  <xsl:element name="li">
      <xsl:text>\ </xsl:text>
    <xsl:apply-templates />
  </xsl:element>
</xsl:template>

<!-- links -->
<xsl:template match="link">
 <!-- show link only for matching @lang or if no @lang at all -->
  <xsl:if test="@lang=$lang or string(@lang)=''">
    <xsl:element name="a">
      <xsl:attribute name="href">
        <xsl:call-template name="addr-resolution"><xsl:with-param name='adr' select='@href'/></xsl:call-template>
      </xsl:attribute>
      <img src="images/{@rel}.png" class="icon"/>
      <xsl:apply-templates />
      <xsl:if test="normalize-space()=''">
        <xsl:choose>
          <xsl:when test="@rel='doc'">
            <xsl:choose>
              <xsl:when test="$lang='en'"><xsl:text>documentation</xsl:text></xsl:when>
              <xsl:when test="$lang='ru'"><xsl:text>документация</xsl:text></xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@rel='wrap'">
            <xsl:choose>
              <xsl:when test="$lang='en'"><xsl:text>library</xsl:text></xsl:when>
              <xsl:when test="$lang='ru'"><xsl:text>библиотека</xsl:text></xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="@rel='example'">
            <xsl:choose>
              <xsl:when test="$lang='en'"><xsl:text>example</xsl:text></xsl:when>
              <xsl:when test="$lang='ru'"><xsl:text>пример</xsl:text></xsl:when>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
  </xsl:element>
</xsl:if>
</xsl:template>

<!-- select <en> or <ru> depending on $lang param -->
<xsl:template name="lang">
  <xsl:apply-templates select="(*[name() = $lang] | en )[last()]/node() " />
</xsl:template>

<!-- convert links -->
<xsl:template match="src">
    <xsl:element name='a'>
      <xsl:attribute name='href'>
        <xsl:call-template name="addr-resolution"><xsl:with-param name='adr' select='.'/></xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="."/>
    </xsl:element>
</xsl:template>

<!-- convert links' addresses -->
<xsl:template name="addr-resolution">
<xsl:param name='adr'/>
<xsl:choose>
    <xsl:when test="starts-with($adr, 'http://') or starts-with($adr, 'ftp://')">
        <xsl:value-of select="$adr"/>
    </xsl:when>
    <xsl:when test="$usage='web'">
        <xsl:value-of select="concat('http://forth.org.ru/',$adr)"/>
    </xsl:when>
    <xsl:when test="starts-with($adr, '~')"><xsl:value-of select="concat('../devel/',$adr)"/></xsl:when>
    <xsl:otherwise><xsl:value-of select="concat('../',$adr)"/></xsl:otherwise>
</xsl:choose>
</xsl:template>

</xsl:stylesheet>
