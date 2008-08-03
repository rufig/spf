@echo off
IF "%1" == "" echo usage: fml2ans-ext.cmd some/path/name.f.xml & exit /B

set throw=IF ERRORLEVEL 1 EXIT /B %%ERRORLEVEL%%
FOR %%I IN ( %0 ) DO set own_location=%%~dpI

msxsl %1 "%own_location%fml2ans-ext.xsl" > %tmp%\fml2ans-lastresult.f & %throw%
start notepad %tmp%\fml2ans-lastresult.f

exit /B
rem saxon на выходе дает UNIX-строки (0xA), которые notepad не переваривает.
rem -- поэтому тут msxsl
