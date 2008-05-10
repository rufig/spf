\ $Id$
( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

: USER-INIT ( n -- )
\ n - размер параметров, к-е Windows передает callback процедуре (в байтах)
  CREATE-HEAP
  <SET-EXC-HANDLER>
  POOL-INIT
  AT-THREAD-STARTING  
;

\ один раз на процесс
: PROCESS-INIT ( n -- )
  ERASE-IMPORTS
  CREATE-PROCESS-HEAP
  <SET-EXC-HANDLER>
  POOL-INIT
  ['] AT-PROCESS-STARTING ERR-EXIT
;

\ ранее неустановленные вектора
' NOOP         ' <PRE>      TC-VECT!
' FIND1        ' FIND       TC-VECT!
' ?LITERAL2    ' ?LITERAL   TC-VECT!
' ?SLITERAL2   ' ?SLITERAL  TC-VECT!
' OK1          ' OK         TC-VECT!
' ERROR2       ' ERROR      TC-VECT!
' (ABORT1")    ' (ABORT")   TC-VECT!
' PROC-ERROR1  ' PROC-ERROR TC-VECT!
' LIB-ERROR1   ' LIB-ERROR  TC-VECT!
\ другие уже установлены

: USER-EXIT
  AT-THREAD-FINISHING
  DESTROY-HEAP
\  TlsIndex@ FREE DROP
;

VARIABLE IN-EXCEPTION

: AT-EXC-DUMP ( addr -- addr ) ... ;
\ example: ..: AT-EXC-DUMP ." REGISTERS:" DUP 12 CELLS DUMP CR ;..

: EXC-DUMP1 ( exc-info -- )
  IN-EXCEPTION @ IF DROP EXIT THEN
  TRUE IN-EXCEPTION !
  BASE @ >R HEX

  ." EXCEPTION! "
  DUP @ ."  CODE:" U.
  DUP 3 CELLS + @ ."  ADDRESS:" DUP ADDR.  ."  WORD:" WordByAddr TYPE CR

  ( DispatcherContext ContextRecord EstablisherFrame ExceptionRecord  ExceptionRecord )
  DROP 2 PICK

  8 CELLS 80 + \ FLOATING_SAVE_AREA
    11 CELLS + \ сдвиг оносительно контекст к регистрам, начиная с edi
  + \ вычисление базового адреса образа регистров (~ygrek)

  AT-EXC-DUMP ( addr -- addr )

  ." USER DATA: " TlsIndex@ ADDR. ." THREAD ID: " 36 FS@ ADDR.
  ." HANDLER: " HANDLER @ ADDR. CR
  >R
  R@ 10 CELLS + @ ( esp )
  R@ 5 CELLS + @ ( eax )
  R> 6 CELLS + @ ( ebp )
  DUMP-TRACE-USING-REGS

  ." END OF EXCEPTION REPORT" CR
  R> BASE !  FALSE IN-EXCEPTION !
;
' EXC-DUMP1 ' <EXC-DUMP> TC-VECT!

: PLATFORM ( -- a u ) S" Win95/98/Me/NT/2k/XP/Vista" ;

