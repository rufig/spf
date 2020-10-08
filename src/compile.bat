@echo off
setlocal
cd /d %~dp0 && cd ..
echo Current directory is %CD%
echo Wait a bit while compiling...
echo HALT 1  | jpf375c.exe src/tc-configure-lines.f src/spf.f
endlocal
