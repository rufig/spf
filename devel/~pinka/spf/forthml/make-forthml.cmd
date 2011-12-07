@echo off
FOR %%I IN ( %0 ) DO pushd %%~dI%%~pI..\..\..\..\
rem -- pushd to the sp-forth root directory
spf4.exe ~pinka/spf/forthml/index.f  ~pinka/lib/win/directory.f S" forthml.exe" SAVE BYE
popd
