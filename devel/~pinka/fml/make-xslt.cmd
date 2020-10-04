@if not exist tmp mkdir tmp

@set throw=@IF ERRORLEVEL 1 EXIT /B %%ERRORLEVEL%%
@set stct=../engine-xml/struct.xsl
@set sxsl=../engine-xml/sxsl.xsl
@set xtrans=call saxonhe-xslt
@set xtrans2=call saxonhe-xslt

    %xtrans%  src/rules-common.f.xml     meta/rules2sxsl.xsl     >tmp/rules-common.sxsl.xml
    %throw%
    @rem           index-xslt.struct.sxsl.xml refer to tmp/index-common-rules.sxsl.xml
    %xtrans%  meta/index-xslt.sxsl.xml   %stct%                  >tmp/forthml.sxsl.xml
    %throw%
    %xtrans%  tmp/forthml.sxsl.xml       %sxsl%                  >forthml.xsl

@exit /B
