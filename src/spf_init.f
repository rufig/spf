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
  CREATE-PROCESS-HEAP
  <SET-EXC-HANDLER>
  POOL-INIT
  ['] AT-PROCESS-STARTING ERR-EXIT
;

\ ранее неустановленные вектора
' NOOP          (TO) <PRE>
' FIND1         (TO) FIND
' ?LITERAL2     (TO) ?LITERAL
' ?SLITERAL2    (TO) ?SLITERAL
' OK1           (TO) OK
' ERROR2        (TO) ERROR
' (ABORT1")     (TO) (ABORT")
' PROC-ERROR1   (TO) PROC-ERROR
' LIB-ERROR1    (TO) LIB-ERROR
\ другие уже установлены


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
\ example: ..: AT-EXC-DUMP ." REGISTERS:" DUP 12 CELLS DUMP CR ;..

: DUMP-TRACE ( addr-h addr-l -- ) \ bottom top --
  BEGIN 2DUP U< 0= WHILE STACK-ADDR. CELL+ REPEAT 2DROP
;

12 VALUE TRACE-HEAD-SIZE
15 VALUE TRACE-TAIL-SIZE

: DUMP-TRACE-SHRUNKEN ( addr-h addr-l -- ) \ bottom top --
  2DUP -  TRACE-HEAD-SIZE TRACE-TAIL-SIZE + 5 + CELLS
  U< IF DUMP-TRACE EXIT THEN
  DUP TRACE-HEAD-SIZE CELLS + SWAP DUMP-TRACE ." [...]" CR
  DUP TRACE-TAIL-SIZE CELLS - DUMP-TRACE
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
  10 CELLS + @ ( esp )  R0 @ 
  
  2DUP U<
  IF ( top bottom )
    2DUP HANDLER @ WITHIN IF
      >R HANDLER @ SWAP DUMP-TRACE-SHRUNKEN
      HANDLER @ CELL+ R> 
    THEN
    2DUP  TRACE-HEAD-SIZE TRACE-TAIL-SIZE + CELLS - 10 CELLS -
    U< IF 10 CELLS - THEN \ skip early bottom
    SWAP DUMP-TRACE-SHRUNKEN
  ELSE ( esp bottom ) 
    NIP DUP 50 CELLS - DUMP-TRACE 
    \ при несогласованности предпочтение отдается R0
  THEN

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
