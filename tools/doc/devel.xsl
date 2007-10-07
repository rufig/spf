<?xml version='1.0' encoding="utf-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >
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
<xsl:element name='title'>
<xsl:call-template name='lang'>
<xsl:with-param name='node'>
<en><xsl:text>SP-Forth: additional libraries</xsl:text></en>
<ru><xsl:text>SP-Forth: дополнительные библиотеки</xsl:text></ru>
</xsl:with-param></xsl:call-template></xsl:element>
        <style type="text/css">
        <xsl:text>body {background:white;}
* {font-family: arial, verdana, sans-serif}
code {font-family: 'Lucida Console', 'Courier New', monospace}
pre, code { background : #EEEEF4}</xsl:text>
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
<xsl:call-template name='lang'>
<xsl:with-param name='node'>
<en><xsl:text>: Additional libraries</xsl:text></en>
<ru><xsl:text>: Дополнительные библиотеки</xsl:text></ru>
</xsl:with-param></xsl:call-template>
    </h1>
    
    <p><small><xsl:value-of select="meta/date"/></small></p>

    <p><em>
<xsl:call-template name='lang'>
<xsl:with-param name='node'>
<en><xsl:text>REQUIRE is a forth word, which loads library; unnecessary text is commented out, so you can use this list as a forth code to include libs :)</xsl:text></en>
<ru><xsl:text>REQUIRE это слово подключающее либу, всё лишнее закомментировано, так что можно использовать этот список как форт код при подключении либ :)</xsl:text></ru>
</xsl:with-param></xsl:call-template>
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
<xsl:call-template name='lang'>
<xsl:with-param name='node'>
<en><xsl:text>Used icons from </xsl:text></en><ru><xsl:text>Использованы иконки </xsl:text></ru>
</xsl:with-param></xsl:call-template>
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
  <xsl:element name="a">
    <xsl:copy-of select='@href' />
  <xsl:element name="img">
  <xsl:attribute name="style">vertical-align:bottom; margin-left:0.5em;</xsl:attribute>
  <xsl:attribute name="src">
    <xsl:choose>
      <xsl:when test="@rel='doc'">images/doc.png</xsl:when>
      <xsl:when test="@rel='wrap'">images/wrap.png</xsl:when>
      <xsl:when test="@rel='example'">images/example.png</xsl:when>
    </xsl:choose></xsl:attribute>
  </xsl:element>
    <xsl:apply-templates />
    <xsl:if test='string-length(translate(normalize-space()," ",""))=0'>
<xsl:call-template name='lang'>
<xsl:with-param name='node'>
    <xsl:choose>
      <xsl:when test="@rel='doc'"><ru>документация</ru><en>documentation</en></xsl:when>
      <xsl:when test="@rel='wrap'"><ru>библиотека</ru><en>library</en></xsl:when>
      <xsl:when test="@rel='example'"><ru>пример</ru><en>example</en></xsl:when>
    </xsl:choose>
</xsl:with-param>
</xsl:call-template>
    </xsl:if>
  </xsl:element>
</xsl:template>

<!-- select <en> or <ru> depending on $lang param -->
<xsl:template name="lang">
<xsl:param name='node' select='.' />
  <xsl:apply-templates select="($node/*[name() = $lang] | en )[last()]/node() " />
</xsl:template>

<!-- convert links -->
<xsl:template match="src">
  <xsl:choose><xsl:when test="$usage='web'">
    <a href="http://forth.org.ru/{.}"><xsl:value-of select="."/></a>
  </xsl:when><xsl:when test="starts-with(., '~')">
    <a href="../devel/{.}"><xsl:value-of select="."/></a>
  </xsl:when><xsl:otherwise>
    <a href="../{.}"><xsl:value-of select="."/></a>
  </xsl:otherwise></xsl:choose>
</xsl:template>

</xsl:stylesheet>