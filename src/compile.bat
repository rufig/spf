@echo off
setlocal
cd /d %~dp0 && cd ..
echo Current directory is %CD%
if not exist "jpf375c.exe" (
  echo "jpf375c.exe" is not exist, downloading...
  set url=https://github.com/rufig/spf4-cvs-archive/releases/download/v1.0/jpf375c.exe
  powershell "(new-object System.Net.WebClient).DownloadFile('%url%','./jpf375c.exe')"
)
echo Wait a bit while compiling...
echo 1 HALT  | jpf375c.exe src/tc-configure-lines.f src/spf.f
endlocal
