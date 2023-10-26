@echo off
setlocal
cd /d %~dp0 && cd ..
echo Current directory is %CD%
set hostforth=jpf375c.exe
if not exist "%hostforth%" (
  echo "%hostforth%" is not exist, downloading...
  echo ^
    $hostforth = '%hostforth%'; ^
    $url = "https://github.com/rufig/spf4-cvs-archive/releases/download/v1.0/${hostforth}" ; ^
    $expectedHash = '1B1A244C615F8838ECD1BCD8A1F7907BAE60664E'; ^
    (new-object System.Net.WebClient ^).DownloadFile( $url, $hostforth ^); ^
    if ( (Get-FileHash -Algorithm SHA1 $hostforth ^).Hash -eq $expectedHash ^) ^
      { Write-Host "Hash matches: ${hostforth}" } ^
    else ^
      { Write-Host "Hash does not match: ${hostforth}" ; Remove-Item -LiteralPath $hostforth; exit 2 } ^
  | powershell -Command -
)
if %ERRORLEVEL% neq 0  exit /b %ERRORLEVEL%
echo Wait a bit while compiling...
echo 1 HALT  | %hostforth% src/tc-configure-lines.f src/spf.f
endlocal
