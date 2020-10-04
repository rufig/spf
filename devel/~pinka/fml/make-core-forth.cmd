@set throw=@IF ERRORLEVEL 1 EXIT /B %%ERRORLEVEL%%
@set stct=../engine-xml/struct.xsl
@set sxsl=../engine-xml/sxsl.xsl
@set xtrans=call saxonhe-xslt
@set xtrans2=call saxonhe-xslt
@rem @set xtrans=msxsl

@rem ( r:* ) --> ( f:* r:m0 r:m )

@rem %xtrans%  meta/trules-step1.sxsl.xml %stct% >z.xml
@rem exit /B

     %xtrans%  meta/trules-step1.sxsl.xml %stct%  | %xtrans%   - %sxsl%    >tmp/trules-step1.xsl
     %throw%
     %xtrans%  meta/core-forth.f.xml      %stct%  | %xtrans2%  - tmp/trules-step1.xsl  >tmp/rules-step1.xml
     %throw%

@rem ( f:* ) --> ( r:* )
     %xtrans%   meta/trules-step2.sxsl.xml %sxsl%                 >tmp/trules-step2.xsl
     %throw%
     %xtrans2%  tmp/rules-step1.xml        tmp/trules-step2.xsl   >tmp/rules-step2.xml
     %throw%

@rem ( r:* text() ) --> ( plainForth )
     %xtrans%   meta/trules-step3.sxsl.xml %stct% | %xtrans%   - %sxsl%                >tmp/trules-step3.xsl
     %throw%
     %xtrans2%  tmp/rules-step2.xml        tmp/trules-step3.xsl   >tmp/rules-step3.f
     %throw%
     @copy tmp\rules-step3.f forthml-core.auto.f >nul

@exit /B
