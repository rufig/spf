( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

VARIABLE MAINX
TC-USER-HERE ' USER-OFFS EXECUTE !

VECT <FLOAT-INIT>
' NOOP (TO) <FLOAT-INIT>

: USER-INIT
  ERASED-CNT @ 0=
  IF ( один раз на задачу )
     ERASE-IMPORTS
     ERASED-CNT 1+!
     CONSOLE-HANDLES
     ['] NOOP       TO <PRE>
     ['] FIND1      TO FIND
     ['] ?LITERAL2  TO ?LITERAL
     ['] ?SLITERAL2 TO ?SLITERAL
     ['] OK1        TO OK
     ['] ERROR2     TO ERROR
     ['] (ABORT1")  TO (ABORT")
  THEN
  CREATE-HEAP
\  USER-OFFS @ 1024 + ALLOCATE DROP TlsIndex!
  EXC-HANDLER 0!
  SP@ S0 !
  RP@ R0 !
  DECIMAL
  ATIB TO TIB
  0 TO SOURCE-ID
  1 ALIGN-BYTES !
  S-O TO CONTEXT FORTH DEFINITIONS
  POSTPONE [
  HANDLER 0!
  CURSTR 0!
  CURFILE 0!
  TRUE WARNING !
  12 C-SMUDGE !
  <FLOAT-INIT>
;

: USER-EXIT
  DESTROY-HEAP
\  TlsIndex@ FREE DROP
;

' USER-INIT (TO) FORTH-INSTANCE>
' USER-EXIT (TO) <FORTH-INSTANCE
' QUIT      (TO) <MAIN>

VARIABLE IN-EXCEPTION

: STACK-ADDR. ( addr -- addr )
      DUP U. ." :  "
      DUP ['] @ CATCH 
      IF DROP 
      ELSE DUP U. WordByAddr TYPE CR THEN
;
: EXC-DUMP1 ( exc-info -- )
  IN-EXCEPTION @ IF DROP EXIT THEN
  TRUE IN-EXCEPTION !
  BASE @ SWAP
  HEX
  ." EXCEPTION! " 
  DUP @ ."  CODE:" U. 
  DUP 3 CELLS + @ ."  ADDRESS:" DUP U. ."  WORD:" WordByAddr TYPE SPACE
  ."  REGISTERS:"
  DUP 4 CELLS + @ CELLS + \ может быть указано смещение структуры на 2 CELLS
  176 + DUP 12 CELLS DUMP CR
  ." USER DATA: " TlsIndex@ U.
  ." HANDLER: " HANDLER @ U.
  ." RETURN STACK:" CR
  6 CELLS + DUP @ \ DUP 65000 > IF NIP ELSE DROP CELL+ CELL+ @ THEN
  DUP HANDLER @ U< IF NIP ELSE DROP 4 CELLS + @ THEN
  DUP HANDLER @ U<
  IF
    25 >R
    BEGIN
      DUP HANDLER @ CELL+ U< R@ 0 > AND
    WHILE
      STACK-ADDR.
      CELL+ R> 1- >R
    REPEAT DROP RDROP
  ELSE
    DROP
    50 0 DO 
      R0 @ I 1+ CELLS - STACK-ADDR. DROP
    LOOP
  THEN
  BASE !
  FALSE IN-EXCEPTION !
;
' EXC-DUMP1 (TO) <EXC-DUMP>

: TITLE
  CGI? @ 0= ?GUI 0= AND
  IF
    ." SP-Forth 3.76 (06.Sep.2002) ANS FORTH 94 for Win95/98/NT/2000/XP/.NET" CR
    ." Copyright (C) 1992-2002  A.Cherezov  http://www.forth.org.ru/" CR CR
  THEN
;
' TITLE ' MAINX EXECUTE !

: SPF-INI
  S" SPF.INI" INCLUDE-PROBE
  IF  S" SPF.INI" +ModuleDirName INCLUDE-PROBE DROP  THEN
;
: ERR-EXIT ( xt -- )
  CATCH
  ?DUP IF ['] ERROR CATCH IF 4 ELSE 3 THEN HALT THEN
  \ выходим с кодом ошибки 3, если обычная ошибка при инициализации 
  \ 4 - если вложенная
;

TRUE VALUE SPF-INIT?

\ Startup
\ Точка входа при запуске:

: (INIT)
  SPF-INIT?
  IF
    ['] CGI-OPTIONS ERR-EXIT
    MAINX @ ?DUP IF ERR-EXIT THEN
    ['] SPF-INI     ERR-EXIT
    ['] OPTIONS     ERR-EXIT
  THEN
  CGI? @ 0= POST? @ OR IF ['] <MAIN> ERR-EXIT THEN
  BYE
;
' (INIT) WNDPROC: INIT
' INIT OVER - OVER 1+ +!
