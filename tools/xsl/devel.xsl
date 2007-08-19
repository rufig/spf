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
        <xsl:text>body {background:white;}
* {font-family: arial, verdana, sans-serif}
code {font-family: 'Lucida Console', 'Courier New', monospace}
pre, code { background : #EEEEF4}</xsl:text>
        </style>
    </head>
    <body>
    
    <!-- SF logo -->
    <xsl:if test="$usage='sf'">
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
        <!--xsl:element name="a">
            <xsl:attribute name = "id">
                <xsl:value-of select="@id"/>
            </xsl:attribute>
        </xsl:element-->
        <xsl:element name="h3">
            <xsl:for-each select="name">
                <xsl:call-template name="lang"/>
            </xsl:for-each>
        </xsl:element>
        <xsl:element name="ul">
            <xsl:apply-templates select="lib | other"/>
        </xsl:element>
    </xsl:for-each>

    </td></tr>
    </table>
    </div>
    </body>
    </html>
</xsl:template>

<!-- each lib -->
<xsl:template match="lib">
    <xsl:element name="li">
        <xsl:text>REQUIRE </xsl:text>
        <xsl:value-of select="word"/>
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="path"/>
        <xsl:text> \ </xsl:text>
        <xsl:for-each select="comment">
            <xsl:call-template name="lang"/>
        </xsl:for-each>
    </xsl:element>
</xsl:template>

<!-- -->
<xsl:template match="other">
    <xsl:element name="li">
        <xsl:text>\ </xsl:text>
        <xsl:apply-templates select="path"/>
        <xsl:text> \ </xsl:text>
        <xsl:for-each select="comment">
            <xsl:call-template name="lang"/>
        </xsl:for-each>
    </xsl:element>
</xsl:template>

<!-- select <en> or <ru> depending on $lang param -->
<xsl:template name="lang">
    <!--xsl:value-of select="name($lang)"/-->
    <xsl:choose>
    <xsl:when test="$lang='en'">
        <xsl:value-of select="en"/>
    </xsl:when>
    <xsl:when test="$lang='ru'">
        <xsl:variable name="str"><xsl:value-of select="ru"/></xsl:variable>
        <xsl:value-of select="ru"/>
        <xsl:if test="string-length($str)=0">
            <xsl:value-of select="en"/>
        </xsl:if>
    </xsl:when>
    </xsl:choose>
</xsl:template>

<!-- convert links -->
<xsl:template match="path">
    <xsl:choose> 
    <xsl:when test="$usage='web'">
        <a href="http://forth.org.ru/{.}">
            <xsl:value-of select="."/>
        </a>
    </xsl:when>
    <xsl:when test="$usage='local'">
        <xsl:choose>
        <xsl:when test="substring(.,1,1)='~'">
            <a href="../devel/{.}">
                <xsl:value-of select="."/>
            </a>
        </xsl:when>
        <xsl:otherwise>
            <a href="../{.}">
                <xsl:value-of select="."/>
            </a>
        </xsl:otherwise>
        </xsl:choose>
    </xsl:when>
    </xsl:choose>
</xsl:template>

</xsl:stylesheet>
