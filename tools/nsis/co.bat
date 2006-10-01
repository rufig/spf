SETLOCAL
SET SPF_CVS_PATH=D:\WORK\FORTH\spf4-pub
SET SPF_TC=D:\WORK\FORTH\spf4\jpf375c.exe
REM can be "y" or anyting else
SET SPF_NET_COPY="n"

REM -----------------------------------------

REM if exist spf goto exit
REM rmdir /S /Q spf

mkdir spf
cd spf

if %SPF_NET_COPY%=="y" goto net_copy

REM From the local working copy
for %%A in (CVS,devel,lib,src,docs,samples,spf4root) do xcopy /S /Q /I /Y %SPF_CVS_PATH%\%%A %%A
if ERRORLEVEL 1 goto exit
goto copy_done

REM From the network CVS repository
:net_copy
for %%A in (devel,lib,src,docs,samples,spf4root) do cmd/c cvs -z3 -d:pserver:anonymous@spf.cvs.sourceforge.net:/cvsroot/spf co -P %%A
if ERRORLEVEL 1 goto exit
goto copy_done

:copy_done
rmdir /S /Q spf4root\CVS
move spf4root\* .
rmdir spf4root
copy %SPF_TC% .
cd src
cmd/c compile.bat
goto exit

:exit
