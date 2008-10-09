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

  DUP 3 CELLS + @ OVER @ ( addr num ) DUMP-EXCEPTION-HEADER 

  ( DispatcherContext ContextRecord EstablisherFrame ExceptionRecord  ExceptionRecord )
  DROP 2 PICK

  8 CELLS 80 + \ FLOATING_SAVE_AREA
    11 CELLS + \ сдвиг оносительно контекст к регистрам, начиная с edi
  + \ вычисление базового адреса образа регистров (~ygrek)

  AT-EXC-DUMP ( addr -- addr )

  >R
  R@ 10 CELLS + @ ( esp )
  R@ 5 CELLS + @ ( eax )
  R> 6 CELLS + @ ( ebp )
  DUMP-TRACE-USING-REGS

  ." END OF EXCEPTION REPORT" CR
  FALSE IN-EXCEPTION !
;
' EXC-DUMP1 ' <EXC-DUMP> TC-VECT!

: PLATFORM ( -- a u ) S" Win95/98/Me/NT/2k/XP/Vista" ;

