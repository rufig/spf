\ $Id$
( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

VARIABLE MAINX
ALIGN-BYTES-CONSTANT CONSTANT ALIGN-BYTES-CONSTANT
TC-USER-HERE ALIGNED ' USER-OFFS EXECUTE !

: AT-THREAD-STARTING ( -- ) ...  ;
: AT-PROCESS-STARTING ( -- ) ... AT-THREAD-STARTING ;

: POOL-INIT ( n -- )
  SP@  + CELL+ S0 !
  RP@ R0 !
  DECIMAL
  ATIB TO TIB
  0 TO SOURCE-ID
  0 TO SOURCE-ID-XT
  S-O TO CONTEXT FORTH DEFINITIONS
  POSTPONE [
  HANDLER 0!
  CURSTR 0!
  CURFILE 0!
  INCLUDE-DEPTH 0!
  TRUE WARNING !
  12 C-SMUDGE !
  ALIGN-BYTES-CONSTANT ALIGN-BYTES !
  INIT-MACROOPT-LIGHT
;


: ERR-EXIT ( xt -- )
  CATCH
  ?DUP IF ['] ERROR CATCH IF 4 ELSE 3 THEN HALT THEN
  \ выходим с кодом ошибки 3, если обычная ошибка при инициализации 
  \ 4 - если вложенная
;


TARGET-POSIX [IF]
  S" src/posix/init.f" INCLUDED
[ELSE]
  S" src/win/spf_win_init.f" INCLUDED
[THEN]


' USER-INIT ' FORTH-INSTANCE>  TC-VECT!
' USER-EXIT ' <FORTH-INSTANCE  TC-VECT!
' QUIT      ' <MAIN>           TC-VECT!


: (TITLE)
  ." SP-FORTH - ANS FORTH 94 for " PLATFORM TYPE CR
  ." Open source project at http://spf.sf.net" CR
  ." Russian FIG at http://www.forth.org.ru ; Started by A.Cherezov" CR
  ." Version " VERSION 1000 / 0 <# # # [CHAR] . HOLD # #> TYPE
  ."  Build " VERSION 0 <# # # # #> TYPE
  ."  at " BUILD-DATE COUNT TYPE CR CR
;
: TITLE  CGI? @ 0=  ?GUI 0= AND COMMANDLINE-OPTIONS NIP 0= AND IF (TITLE) THEN ;
' TITLE ' MAINX TC-ADDR!

: SPF-INI
  S" spf4.ini" INCLUDE-PROBE
  IF  S" spf4.ini" +ModuleDirName INCLUDE-PROBE DROP  THEN
;

\ Scattering a Colon Definition
: ... 0 BRANCH, >MARK DUP , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

TRUE VALUE SPF-INIT?

\ Startup
\ Точка входа при запуске:

TARGET-POSIX [IF]
: (INIT) ( env argv argc -- )
  TO ARGC TO ARGV
  HERE 
  ARGC 1 ?DO
   ARGV I CELLS + @ ASCIIZ> S, BL C,
  LOOP
  HERE OVER - TO #CMDLINE TO CMDLINE
  0 C,
[ELSE]
: (INIT)
[THEN]
  SetOP
  HERE OP0 OpBuffSize + !
  NATIVE-LINES
  0 TO H-STDLOG
  CONSOLE-HANDLES
  ['] CGI-OPTIONS ERR-EXIT
  MAINX @ ?DUP IF ERR-EXIT THEN
  SPF-INIT?
  IF
    ['] SPF-INI ERR-EXIT
    ['] OPTIONS CATCH ERROR \ продолжить не смотря на ошибку
  THEN
  CGI? @ 0= POST? @ OR IF ['] <MAIN> ERR-EXIT THEN
  BYE
;

' PROCESS-INIT TO TC-FORTH-INSTANCE>
' (INIT) PROCESSPROC: INIT

TARGET-POSIX 0 = [IF]
' INIT OVER - OVER 1+ +!
[THEN]
