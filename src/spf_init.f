\ $Id$
( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

VARIABLE MAINX
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
  16 ALIGN-BYTES !
;

: USER-INIT ( n )
\ n - размер параметров, к-е Windows передает callback процедуре (в байтах)
  CREATE-HEAP
  <SET-EXC-HANDLER>
  POOL-INIT
  AT-THREAD-STARTING  
;

: ERR-EXIT ( xt -- )
  CATCH
  ?DUP IF ['] ERROR CATCH IF 4 ELSE 3 THEN HALT THEN
  \ выходим с кодом ошибки 3, если обычная ошибка при инициализации 
  \ 4 - если вложенная
;

\ один раз на процесс
: PROCESS-INIT ( n )
  ERASE-IMPORTS
  ['] NOOP       TO <PRE>
  ['] FIND1      TO FIND
  ['] ?LITERAL2  TO ?LITERAL
  ['] ?SLITERAL2 TO ?SLITERAL
  ['] OK1        TO OK
  ['] ERROR2     TO ERROR
  ['] (ABORT1")  TO (ABORT")
  ['] ACCEPT1    TO ACCEPT
  ['] TYPE1      TO TYPE
  ['] KEY1       TO KEY
  ['] LIB-PROC1  TO PROC-ERROR
  ['] LIB-ERROR1 TO LIB-ERROR

  CREATE-PROCESS-HEAP
  <SET-EXC-HANDLER>
  POOL-INIT
  ['] AT-PROCESS-STARTING ERR-EXIT
;

: USER-EXIT
  AT-THREAD-FINISHING
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

: AT-EXC-DUMP ( addr -- addr ) ... ;
\ example: ."  REGISTERS:" DUP 12 CELLS DUMP CR

: DUMP-TRACE ( up low -- )
  BEGIN 2DUP U< 0= WHILE STACK-ADDR. CELL+ REPEAT 2DROP
;
: DUMP-TRACE-SHRUNKEN ( up low -- )
  2DUP - 30 CELLS < IF DUMP-TRACE EXIT THEN
  DUP 10 CELLS + SWAP DUMP-TRACE ." [...]" CR
  DUP 15 CELLS -      DUMP-TRACE
;

: EXC-DUMP1 ( exc-info -- ) 
  IN-EXCEPTION @ IF DROP EXIT THEN
  TRUE IN-EXCEPTION !
  BASE @ >R HEX

  ." EXCEPTION! "
  DUP @ ."  CODE:" U.
  DUP 3 CELLS + @ ."  ADDRESS:" DUP U.  ."  WORD:" WordByAddr TYPE CR

  ( DispatcherContext ContextRecord EstablisherFrame ExceptionRecord  ExceptionRecord )
  DROP 2 PICK

  8 CELLS 80 + \ FLOATING_SAVE_AREA
    11 CELLS + \ сдвиг оносительно контекст к регистрам, начиная с edi
  + \ вычисление базового адреса образа регистров (~ygrek)

  AT-EXC-DUMP ( addr -- addr )

  ." USER DATA: " TlsIndex@ U. ." THREAD ID: " 36 FS@ U.
  ." HANDLER: " HANDLER @ U. CR
  ." STACK: "
  DUP 6 CELLS + @ ( ebp )
  DUP 5 CELLS + BEGIN DUP ['] @ CATCH IF DROP ELSE 8 .0 SPACE THEN CELL- 2DUP U> UNTIL 2DROP
  ." ["
  DUP 5 CELLS + @ ( eax ) 8 .0 ." ]" CR

  ." RETURN STACK:" CR
  HANDLER @ DUP 0= IF DROP R0 @ THEN ( up-border ) >R
  6 CELLS + DUP @  SWAP  4 CELLS + @ ( a1 a2 )
  \ берем ближайший снизу к up-border:
  2DUP U> IF SWAP THEN ( min max ) DUP R@ U< IF NIP ELSE DROP THEN ( low-border ) R>
  ( low-border up-border )
  2DUP U< IF 3 CELLS + R0 @ UMIN  SWAP DUMP-TRACE-SHRUNKEN ELSE 2DROP R0 @ DUP 50 CELLS - DUMP-TRACE THEN

  ." END OF EXCEPTION REPORT" CR
  R> BASE !  FALSE IN-EXCEPTION !
;
' EXC-DUMP1 (TO) <EXC-DUMP>

: (TITLE)
  ." SP-FORTH - ANS FORTH 94 for Win95/98/ME/NT/2000/XP" CR
  ." Open source project at http://spf.sf.net" CR
  ." Russian FIG at http://www.forth.org.ru ; Started by A.Cherezov" CR
  ." Version " VERSION 1000 / 0 <# # # [CHAR] . HOLD # #> TYPE
  ."  Build " VERSION 0 <# # # # #> TYPE
  ."  at " BUILD-DATE COUNT TYPE CR CR
;
: TITLE  CGI? @ 0=  ?GUI 0= AND COMMANDLINE-OPTIONS NIP 0= AND IF (TITLE) THEN ;
' TITLE ' MAINX EXECUTE !

: SPF-INI
  S" SPF4.INI" INCLUDE-PROBE
  IF  S" SPF4.INI" +ModuleDirName INCLUDE-PROBE DROP  THEN
;

\ Scattering a Colon Definition
: ... 0 BRANCH, >MARK DUP , 1 >RESOLVE ; IMMEDIATE 
: ..: '  >BODY DUP @  1 >RESOLVE ] ;
: ;..  DUP CELL+ BRANCH, >MARK SWAP ! [COMPILE] [ ; IMMEDIATE

TRUE VALUE SPF-INIT?

\ Startup
\ Точка входа при запуске:

: (INIT)
  SetOP
  HERE OP0 OpBuffSize + !
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
' INIT OVER - OVER 1+ +!
