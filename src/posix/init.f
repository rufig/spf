\ $Id$
( Инициализация USER-переменных.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Сентябрь 1999
)

: USER-INIT ( n -- )
  ALLOCATE-THREAD-MEMORY
  POOL-INIT
  AT-THREAD-STARTING 
;

: DUMP-TRACE ( context siginfo signo -- )
  BASE @ >R HEX

  ROT ( siginfo signo context )
  OVER OVER SYS_CONTEXT_EIP + @ SWAP ( addr code ) DUMP-EXCEPTION-HEADER

  SWAP ( signo ) ." [" 1 <( )) strsignal ASCIIZ> TYPE ." ] "
  SWAP ( siginfo )
  ." Code:" DUP 2 CELLS + @ . ." At:" 3 CELLS + @ ADDR.
  CR

  >R
  R@ SYS_CONTEXT_ESP + @ ( esp )
  R@ SYS_CONTEXT_EAX + @ ( eax )
  R> SYS_CONTEXT_EBP + @ ( ebp )
  DUMP-TRACE-USING-REGS
  ." END OF EXCEPTION REPORT" CR
  R> BASE !
; 

\ see http://forth.sourceforge.net/standard/dpans/dpans9.htm#9.3.5
: signum>ior ( code sig -- ior )
   DUP SYS_SIGSEGV = IF 2DROP -9 EXIT THEN
   DUP SYS_SIGILL = IF 2DROP -9 EXIT THEN
   DUP SYS_SIGBUS = IF 2DROP -23 EXIT THEN
   DUP SYS_SIGFPE = IF DROP 
    DUP SYS_FPE_INTDIV = IF DROP -10 EXIT THEN
    DUP SYS_FPE_INTOVF = IF DROP -11 EXIT THEN
    DUP SYS_FPE_FLTDIV = IF DROP -42 EXIT THEN
    DUP SYS_FPE_FLTOVF = IF DROP -43 EXIT THEN
    DUP SYS_FPE_FLTUND = IF DROP -54 EXIT THEN
    DUP SYS_FPE_FLTRES = IF DROP -41 EXIT THEN
    DUP SYS_FPE_FLTINV = IF DROP -46 EXIT THEN \ questionable
    DROP -55 EXIT 
   THEN
   256 + NEGATE 
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
    2R@ DUMP-TRACE
    2R> SWAP SYS_SIGINFO_CODE + @ SWAP signum>ior THROW ;

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

: PROCESS-INIT ( n -- )
  dl-init
  ERASE-IMPORTS
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

: PLATFORM ( -- a u ) S" Linux" ;

0 VALUE CMDLINE
0 VALUE #CMDLINE

: COMMANDLINE-OPTIONS ( -- a u ) CMDLINE #CMDLINE ;
