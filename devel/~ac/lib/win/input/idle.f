REQUIRE WinNT? ~ac/lib/win/winver.f 

WINAPI: GetLastInputInfo USER32.DLL
WINAPI: GetTickCount KERNEL32.DLL

USER _GLII 8 USER-ALLOT

: GetIdleTime ( -- ticks )
  WinNT? 0= IF 0 EXIT THEN
  8 _GLII !
  _GLII GetLastInputInfo DROP _GLII CELL+ @
  GetTickCount SWAP -
;
\EOF

: TEST
  BEGIN  
    GetIdleTime .
    100 PAUSE
  AGAIN
;