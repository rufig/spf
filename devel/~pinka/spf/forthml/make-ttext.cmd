@echo off
call saxon  ttext-index.f.xml  ../../fml/forthml.xsl  >ttext-index.auto.f
echo %ERRORLEVEL%
