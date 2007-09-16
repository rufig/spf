\ $Id$
\ Очереди сообщений и обмен данными между потоками
\ сырое

REQUIRE [IF] lib/include/tools.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE #define ~af/lib/c/define.f
REQUIRE NEW-CS ~pinka/lib/multi/critical.f
REQUIRE HEAP-ID! ~pinka/spf/mem.f
\ REQUIRE compiledCode ~profit/lib/bac4th-closures.f

MODULE: multi

REQUIRE CreateList ~day/lib/staticlist.f

EXPORT

0
CELL -- .ti
CELL -- .cs
CELL -- .msgs
CONSTANT /lt

/node
CELL -- .lt
VALUE /node-lt

0
CELL -- .data
CELL -- .type
CELL -- .sender
VALUE /msg

: COPYCOUNTXED ( a u -- xcs ) DUP CELL + ALLOCATE THROW 2DUP ! DUP >R CELL + SWAP CMOVE R> ;
: COUNTX ( xcs -- a u ) DUP CELL + SWAP @ ;
: XADDR ( a u -- xcs ) DROP CELL - ;

: msg.data ( msg -- a u ) .data @ COUNTX ;
: msg.type ( msg -- n ) .type @ ;
: msg.sender ( msg -- lt ) .sender @ ;

/node
CELL -- .msgptr
VALUE /node-msg

/node-lt list: list-of-lt

HEAP-ID VALUE process-heap

: STRCOPY ( s -- s' ) STR@ >STR ;

: CREATE-THREAD ( x task -- th ti )
  0 >R RP@
  4 \ CREATE_SUSPENDED
  2SWAP 0 0 CreateThread
  R> ;

: WITH-CS ( j*x xt cs -- i*x ) >R R@ ENTER-CS EXECUTE R> LEAVE-CS ;
: WITH-HEAP ( j*x xt heap -- i*x ) ( xt: j*x -- i*x ) HEAP-ID >R HEAP-ID! EXECUTE R> HEAP-ID! ;
: WITH-GLOBAL-HEAP process-heap WITH-HEAP ;

: LTASK ( ti -- lt )
   /lt ALLOCATE THROW >R
   R@ .ti !
   NEW-CS R@ .cs !
   /node-msg CreateList R@ .msgs !
   R> ;

WINAPI: GetCurrentThreadId KERNEL32.DLL
WINAPI: OpenThread KERNEL32.DLL

#define SYNCHRONIZE               0x00100000
#define STANDARD_RIGHTS_REQUIRED  0x000F0000
#define THREAD_ALL_ACCESS         STANDARD_RIGHTS_REQUIRED SYNCHRONIZE OR 0x3FF OR

: OPEN-THREAD ( ti -- th ior ) FALSE THREAD_ALL_ACCESS OpenThread ERR ;

USER-VALUE _ti1

: search-lt-by-ti ( ti -- lt|0 )
  TO _ti1
\  S" LITERAL SWAP .lt @ .ti @ <>" compiledCode
  LAMBDA{ _ti1 SWAP .lt @ .ti @ <> } 
  list-of-lt ?ForEach
  DUP IF .lt @ THEN ;

USER-VALUE _lt1

: ?lt ( lt -- ? )
  TO _lt1
  \ S" LITERAL SWAP .lt @ <> " compiledCode
  LAMBDA{ _lt1 SWAP .lt @ <> }
  list-of-lt ?ForEach IF -1 ELSE 0 THEN ;

: current-lt GetCurrentThreadId search-lt-by-ti ;

: register ( lt -- ) list-of-lt AllocateNodeEnd .lt ! ;
: unregister ( lt -- )
    TO _lt1
    \ S" LITERAL OVER .lt @ = IF FreeNode FALSE ELSE DROP TRUE THEN" compiledCode
    LAMBDA{ _lt1 OVER .lt @ = IF FreeNode FALSE ELSE DROP TRUE THEN }
    list-of-lt ?ForEach DROP ;

: lt. ( lt -- )
  CR
  ." lt = " DUP .
  ." ti = " DUP .ti @ .
  ." cs = " DUP .cs @ .
  ." list = " DUP .msgs @ .
  DROP ;

\ ugly solution to conflict with ~ac/lib/lin/xml/xml.f
: listFirstNode .listFirstNode @ ;

: ltreceive ( -- msg )
  LAMBDA{
  current-lt
  >R
  BEGIN
   R@ .cs @ ENTER-CS
   R@ .msgs @ listFirstNode
   R@ .cs @ LEAVE-CS
   DUP 0=
  WHILE
   DROP
   10 PAUSE
  REPEAT
   R@ .cs @ ENTER-CS
   DUP .msgptr @
   SWAP FreeNode
   R> .cs @ LEAVE-CS
   } WITH-GLOBAL-HEAP ;

: FREE-MSG ( msg -- )
  LAMBDA{
    DUP .data @ FREE THROW
        FREE THROW
  } WITH-GLOBAL-HEAP ;

: ltsend ( a u n lt -- )
\  DUP ?lt 0= IF DROP DROP 2DROP EXIT THEN
  DUP 0= IF 2DROP 2DROP EXIT THEN
  LAMBDA{
  >R
    R@ .cs @ ENTER-CS
    R@ .msgs @ AllocateNodeEnd >R
    /msg ALLOCATE THROW
    DUP R> .msgptr !
    ( a u n msg )
    >R
      R@ .type !
      COPYCOUNTXED R@ .data !
      current-lt R@ .sender !
    RDROP
  R> ( lt )
  .cs @ LEAVE-CS
  } WITH-GLOBAL-HEAP ;

: STRltsend ( s n lt -- )
   2>R DUP STR@ 2R> ltsend STRFREE ;

: ltcreate ( param xt -- lt )
    LAMBDA{ TASK CREATE-THREAD LTASK DUP >R register RESUME R> } WITH-GLOBAL-HEAP ;

\ doesnt work!
: ltkill ( lt -- )
    LAMBDA{ DUP .ti @ STOP unregister } WITH-GLOBAL-HEAP ;

: print-list-of-lt ( -- ) LAMBDA{ .lt @ lt. } list-of-lt ForEach ;
: size-list-of-lt ( -- n ) list-of-lt listSize ;
: msgbox-size ( lt -- n ) .msgs @ ?DUP IF listSize ELSE 0 THEN ;
: my-msgbox-size ( -- n ) current-lt msgbox-size ;

;MODULE

\EOF
