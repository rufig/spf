<?xml version='1.0' encoding="windows-1251"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0" >

<!--
$Id$
Данные о погоде от http://informer.gismeteo.ru
-->

<xsl:output method="text" encoding="windows-1251"/>

<xsl:template match = "/MMWEATHER/REPORT" >
<xsl:choose>
<xsl:when test="@type='frc3'">
  <xsl:apply-templates select="//FORECAST[1]"/>
</xsl:when>
<xsl:otherwise>Недоступно</xsl:otherwise>
</xsl:choose>
</xsl:template>

<xsl:template match="FORECAST">
<xsl:text>на </xsl:text>
<xsl:call-template name="tod_str">
  <xsl:with-param name="A"><xsl:value-of select="@tod"/></xsl:with-param>
</xsl:call-template>
<xsl:text> </xsl:text>
<xsl:call-template name="weekday_str">
  <xsl:with-param name="A"><xsl:value-of select="@weekday"/></xsl:with-param>
</xsl:call-template>
<xsl:text>, </xsl:text>
<xsl:value-of select="@day"/>/<xsl:value-of select="@month"/>/<xsl:value-of select="@year"/>
<xsl:text> - </xsl:text>

<xsl:text>температура </xsl:text>
<xsl:for-each select="TEMPERATURE">
<xsl:call-template name="maxmin"/>
</xsl:for-each>
<xsl:text> °C </xsl:text>

<xsl:text>давление </xsl:text>
<xsl:for-each select="PRESSURE">
<xsl:call-template name="average"/>
</xsl:for-each>
<xsl:text> мм рт. ст. </xsl:text>
<xsl:text> </xsl:text>

<xsl:text>ветер </xsl:text>
<xsl:for-each select="WIND">
<xsl:call-template name="wind_str">
  <xsl:with-param name="A"><xsl:value-of select="@direction"/></xsl:with-param>
</xsl:call-template>
<xsl:text> </xsl:text>
<xsl:call-template name="average"/>
</xsl:for-each>
<xsl:text> м/с </xsl:text>

<xsl:text>влажность </xsl:text>
<xsl:for-each select="RELWET">
<xsl:call-template name="average"/>
</xsl:for-each>
<xsl:text>% </xsl:text>

<xsl:call-template name="cloudiness_str">
  <xsl:with-param name="A"><xsl:value-of select="PHENOMENA/@cloudiness"/></xsl:with-param>
  <xsl:with-param name="R"><xsl:value-of select="PHENOMENA/@rpower"/></xsl:with-param>
  <xsl:with-param name="S"><xsl:value-of select="PHENOMENA/@spower"/></xsl:with-param>
</xsl:call-template>
<xsl:text> </xsl:text>

<xsl:call-template name="precipitation_str">
  <xsl:with-param name="A"><xsl:value-of select="PHENOMENA/@precipitation"/></xsl:with-param>
</xsl:call-template>

</xsl:template>

  <xsl:template name="maxmin">
   <xsl:value-of select="@min"/>
   <xsl:text>..</xsl:text>
   <xsl:value-of select="@max"/>
  </xsl:template>

  <xsl:template name="average">
   <xsl:variable name="A"><xsl:value-of select="@min"/></xsl:variable>
   <xsl:variable name="B"><xsl:value-of select="@max"/></xsl:variable>
   <xsl:value-of select="(number($A)+number($B)) div 2"/>
  </xsl:template>

  <xsl:template name="weekday_str">
    <xsl:param name="A"/>
    <xsl:choose>
     <xsl:when test="$A=1">Вс</xsl:when>
     <xsl:when test="$A=2">Пн</xsl:when>
     <xsl:when test="$A=3">Вт</xsl:when>
     <xsl:when test="$A=4">Ср</xsl:when>
     <xsl:when test="$A=5">Чт</xsl:when>
     <xsl:when test="$A=6">Пт</xsl:when>
     <xsl:when test="$A=7">Сб</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="cloudiness_str">
    <xsl:param name="A"/>
    <xsl:choose>
     <xsl:when test="$A=0">ясно</xsl:when>
     <xsl:when test="$A=1">малооблачно</xsl:when>
     <xsl:when test="$A=2">облачно</xsl:when>
     <xsl:when test="$A=3">пасмурно</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="tod_str">
    <xsl:param name="A"/>
    <xsl:choose>
     <xsl:when test="$A=0">ночь</xsl:when>
     <xsl:when test="$A=1">утро</xsl:when>
     <xsl:when test="$A=2">день</xsl:when>
     <xsl:when test="$A=3">вечер</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="precipitation_str">
    <xsl:param name="A"/>
    <xsl:param name="R"/>
    <xsl:param name="S"/>
    <xsl:choose>
     <xsl:when test="$A=4"><xsl:if test="$R=0">возможен </xsl:if>дождь</xsl:when>
     <xsl:when test="$A=5"><xsl:if test="$R=0">возможен </xsl:if>ливень</xsl:when>
     <xsl:when test="$A=6 or $A=7"><xsl:if test="$R=0">возможен </xsl:if>снег</xsl:when>
     <xsl:when test="$A=8"><xsl:if test="$S=0">возможна </xsl:if>гроза</xsl:when>
     <xsl:when test="$A=9">неизвестно</xsl:when>
     <xsl:when test="$A=10">без осадков</xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="wind_str">
    <xsl:param name="A"/>
    <xsl:choose>
     <xsl:when test="$A=0">сев</xsl:when>
     <xsl:when test="$A=1">сев-вост</xsl:when>
     <xsl:when test="$A=2">вост</xsl:when>
     <xsl:when test="$A=3">юго-вост</xsl:when>
     <xsl:when test="$A=4">южн</xsl:when>
     <xsl:when test="$A=5">юго-зап</xsl:when>
     <xsl:when test="$A=6">зап</xsl:when>
     <xsl:when test="$A=7">сев-зап</xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>
