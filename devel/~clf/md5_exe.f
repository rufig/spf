md5-ts.f

: MD5EXE
  GetCommandLineA ASCIIZ>
  TIB SWAP C/L MIN DUP #TIB ! MOVE >IN 0!
  TIB C@ [CHAR] " = IF [CHAR] " ELSE BL THEN
  WORD DROP \ טלÿ ןנמדנאללû
  NextWord ?DUP IF MD5 TYPE CR BYE THEN
  ." Usage:" CR
  ."       md5.exe string" CR
  BYE
;
' MD5EXE MAINX ! S" md5.exe" SAVE BYE
