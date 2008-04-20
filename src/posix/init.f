\ $Id$
( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

: USER-INIT
  ALLOCATE-THREAD-MEMORY
  POOL-INIT
  AT-THREAD-STARTING 
;

\ till we have nested exceptions correct
: STACK-ADDR. ( addr -- addr )
      DUP U. ." :  " DUP @ DUP U. WordByAddr TYPE CR
;

CR .( FIXME reuse windows DUMP-TRACE code)
: DUMP-TRACE ( context siginfo signo -- )
  HEX
  CR ." ----------------------------------------------------------------" CR
  ." [" 1 <( )) strsignal ASCIIZ> TYPE ." ]  Code:"
  DUP 2 CELLS + @ . >R
  ."  Address:" DUP 19 CELLS + @ DUP 8 .0
  ."   Word:" WordByAddr TYPE CR
  ." At:" R> 3 CELLS + @ 8 .0 ."  UserData:" TlsIndex@ 8 .0 
  ."  ThreadID:" (()) pthread_self 8 .0 ."  Handler:" HANDLER @ 8 .0 CR
  ." Stack: " 
  DUP 11 CELLS + @ ( ebp)
  5 0 DO
    DUP 4 I - CELLS + @ 8 .0 SPACE
  LOOP DROP
  DUP 16 CELLS + @ ( eax) 8 .0 CR
  ." Return stack:" CR 
  12 CELLS + @ ( esp)
  8 0 DO
     DUP I CELLS + STACK-ADDR. DROP
  LOOP DROP
  ." ----------------------------------------------------------------" CR
; 

\ Signal handler that THROWs forth exception
\ Usable for synchronous signals
\ If it exits normally -- kernel will restore context
\ and the offending instruction will be executed again and again
\ So we use THROW to change execution flow
\ But HANDLER is USER and thus depends on EDI (in current implementation) which
\ is overwritten, so we restore it from the ctxt.uc_mcontext.edi
\ Stack pointers are restored by THROW
\ EAX is an exception code
: (errsignal) ( ctxt siginfo num -- x )
    2>R 
    DUP SYS_CONTEXT_EDI + @ TlsIndex!
    2R> DUMP-TRACE
    0xC0000005 THROW ;

' (errsignal) 3 TC-CALLBACK: errsignal

CREATE sigact
' errsignal >VIRT ,   \ обработчик сигнала
SYS_SIZEOF_SIGSET ALLOT \ маска блокировки
SYS_SA_RESTART SYS_SA_SIGINFO + SYS_SA_NODEFER + ,
0  ,   \ sa_restarter

CR .( FIXME test return result of sigaction)
: set-errsignal-handler
   \ clear blocking mask
   (( sigact CELL+ )) sigemptyset DROP \ 0 = ?
   (( SYS_SIGILL  sigact 0 )) sigaction DROP \ 0 = ?
   (( SYS_SIGBUS  sigact 0 )) sigaction DROP
   (( SYS_SIGFPE  sigact 0 )) sigaction DROP
   (( SYS_SIGSEGV sigact 0 )) sigaction DROP
;

: PROCESS-INIT ( n )
  dl-init
  ERASE-IMPORTS
  ['] NOOP       TO <PRE>
  ['] FIND1      TO FIND
  ['] ?LITERAL2  TO ?LITERAL
  ['] ?SLITERAL2 TO ?SLITERAL
  ['] OK1        TO OK
  ['] ERROR2     TO ERROR
  ['] (ABORT1")  TO (ABORT")
  ['] dl-no-symbol  TO symbol-not-found-error
  ['] dl-no-library TO library-not-found-error
  ['] dl-no-symbol  TO symbol-not-found-error
  ['] dl-no-library TO library-not-found-error
  ALLOCATE-THREAD-MEMORY
  POOL-INIT
  set-errsignal-handler
  ['] AT-PROCESS-STARTING ERR-EXIT
;

: USER-EXIT
  AT-THREAD-FINISHING
  FREE-THREAD-MEMORY
;


: PLATFORM S" Linux" ;

: COMMANDLINE-OPTIONS 0 0 ; \ FIXME 
