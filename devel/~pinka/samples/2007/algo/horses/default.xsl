<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:f="http://forth.org.ru/ForthML/"
  xmlns:r="http://forth.org.ru/ForthML/Rules/"
  xmlns="http://www.w3.org/1999/xhtml"
  xmlns:htm="http://www.w3.org/1999/xhtml"
>
<!-- May.2007 ruvim@forth.org.ru -->

<xsl:output
  doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
  doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
  omit-xml-declaration="yes"
  indent="no"
/>

<xsl:template match="@*" mode="value">
  <span class="text"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="@name" mode="value">
  <span class="name"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="@ds" mode="value">
  <span class="st"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="@href" mode="value">
  <span class="ref"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="@match" mode="value">
  <span class="name"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template name="put-attributes">
  <xsl:for-each select="@*">
    <xsl:text> </xsl:text>
    <xsl:value-of select="name()"/>
    <b><xsl:text>="</xsl:text></b>
    <xsl:apply-templates select="." mode="value"/>
    <b><xsl:text>"</xsl:text></b>
  </xsl:for-each>
</xsl:template>

<xsl:template match="*" mode="name-of">
  <span class="elem"><xsl:value-of select="name()"/></span>
</xsl:template>

<xsl:template match="r:*" mode="name-of">
  <span class="elem r"><xsl:value-of select="name()"/></span>
</xsl:template>


<xsl:template match="f:g" mode="name-of">
  <span class="elem g"><xsl:value-of select="name()"/></span>
</xsl:template>

<xsl:template match="f:exit | f:again | f:recurse " mode="name-of">
  <span class="elem e"><xsl:value-of select="name()"/></span>
</xsl:template>


<xsl:template name="element">
  <b><xsl:text>&lt;</xsl:text></b>
  <xsl:apply-templates select="." mode="name-of"/>
  <xsl:call-template name="put-attributes"/>
  <b><xsl:text>/&gt;</xsl:text></b>
</xsl:template>

<xsl:template name="element-big">
  <b><xsl:text>&lt;</xsl:text></b>
  <xsl:apply-templates select="." mode="name-of"/><span class="a">
  <xsl:call-template name="put-attributes"/>
  <b><xsl:text>&gt;</xsl:text></b>
    <xsl:apply-templates mode="render" />
  <b><xsl:text>&lt;/</xsl:text></b>
  <xsl:apply-templates select="." mode="name-of"/>
  <b><xsl:text>&gt;</xsl:text></b></span>
</xsl:template>

<xsl:template match="text()" mode="render">
  <span class="f"><xsl:value-of select="."/></span>
</xsl:template>

<xsl:template match="f:comment/text() | f:rem/text() " mode="render">
  <xsl:value-of select="."/>
</xsl:template>

<xsl:template match="*" mode="render">
  <xsl:choose><xsl:when test="node()">
    <xsl:call-template name="element-big"/>
  </xsl:when><xsl:otherwise>
    <xsl:call-template name="element"/>
  </xsl:otherwise></xsl:choose>
</xsl:template>

<xsl:template match="htm:*" mode="render">
  <xsl:copy-of select="." />
</xsl:template>

<xsl:template match="f:comment" mode="render">
  <span class="comment">
  <xsl:call-template name="element-big"/>
  </span>
</xsl:template>

<xsl:template match="f:text | f:emit | f:emit-line" mode="render">
  <span class="text">
  <xsl:call-template name="element-big"/>
  </span>
</xsl:template>

<xsl:template match="f:rem" mode="render">
  <span class="rem">
  <xsl:call-template name="element-big"/>
  </span>
</xsl:template>

<xsl:template match="/" >
  <html><head>
    <style>
      div#src { white-space: pre; font-family: monospace; padding-left: 1em; }
      .comment { font-family: "Verdana" ; color: DarkBlue; }
      .text { color: green; }
      .rem  { font-style: italic; color: CadetBlue; }
      .name { color: DarkRed; font-weight: bolder; font-size: 115%;}
      .elem { color: blue; }
      .st   { color: brown; }
      .f    { font-weight: bold; }
      .ref  { color: navy; }
          b { color: DarkGray; }
    .elem.g { color: DarkCyan ; }
    .elem.e { color: OrangeRed; }
    .elem.r { color: Purple; }

    .elem:active , .elem:active + .a { background-color: yellow; }
    /* Note: E:active + F selector doesn't work up to IE10 at least */
    </style>
  </head><body>
    <div style="color: gray; float: right; width: 15em; text-align: right;"><p>Best viewed with CSS2 compatible browsers :)</p></div>
    <div id="src"><xsl:apply-templates mode="render" /></div>
  </body></html>
</xsl:template>

</xsl:stylesheet>