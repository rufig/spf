@echo off
set target=forthml.exe
FOR %%I IN ( %0 ) DO pushd %%~dI%%~pI..\..\..\..\
rem -- pushd to the sp-forth root directory
echo creating: %CD%\%target%
spf4.exe ~pinka/spf/forthml/index.f  S" %target%" SAVE BYE
popd
