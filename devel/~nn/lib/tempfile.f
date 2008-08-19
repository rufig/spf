VARIABLE LAST-TICK
VARIABLE TMP-CNT
WINAPI: GetCurrentThreadId kernel32.dll
WINAPI: GetTickCount kernel32.dll
: (TempFile) ( Tick -- addr u)
  S>D
  <# 0 HOLD #S 2DROP [CHAR] . HOLD
     GetCurrentThreadId S>D #S 2DROP [CHAR] . HOLD
     TMP-CNT 1+! TMP-CNT @ S>D #S
  #> 1- ;

: TempFile ( -- addr u)
    GetTickCount DUP LAST-TICK ! (TempFile) ;

: PrevTempFile ( -- addr u )
    -1 TMP-CNT +! LAST-TICK @ (TempFile) ;
