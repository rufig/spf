\ $Id$
\ one-dimensional array

\ S" ~day/lib/memreport.f" INCLUDED
REQUIRE ACCERT-LEVEL lib/ext/debug/accert.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: vector_impl

0
CELL -- .ptr
CELL -- .size
CELL -- .msize
CELL -- .cell
CELL -- .flag
CONSTANT /SIZE

: static? ( v -- ? ) .flag @ 1 AND 0<> ;
: erase ( v -- ) /SIZE ERASE ;
: cells ( n v -- n' ) .cell @ * ;

10 CONSTANT delta

: .msize! ( n v -- ) SWAP delta + SWAP .msize ! ;

: init ( n flag v -- v )
   >R
   R@ erase
   R@ .flag !
   R@ .cell !
   R> ;

EXPORT

: vptr ( v -- a ) .ptr @ ;

: vresize ( n v -- )
  \ .resize @ EXECUTE
  ACCERT2( CR ." resize=" OVER . )
   DUP vptr 0=
   IF 
    ACCERT2( CR ." NEW" )
     2DUP .msize! 2DUP SWAP delta + OVER cells ALLOCATE THROW SWAP .ptr ! 
   ELSE
    ACCERT2( CR ." RESIZE" )
     2DUP .msize @ > IF 
       ACCERT2( CR ." really resize" )
       2DUP .msize! 
       ACCERT2( CR ." go " )
       2DUP SWAP delta + OVER cells SWAP vptr 
       SWAP RESIZE THROW 
       OVER .ptr ! 
     THEN
   THEN
   ACCERT2( CR DUP . OVER . )
   .size ! 
   ACCERT2( CR ." resize done" )
   ;

\ static 
: svector ( n -- v )
   1 HERE /SIZE ALLOT init ;

\ dynamic
: vector ( n -- v )
   0 /SIZE ALLOCATE THROW init ;

: vsize .size @ ;

: v[]  ( n v -- a ) >R DUP 1+ R@ vsize > IF RDROP CR . ." Index out of" ABORT THEN R@ cells R> vptr + ;

: ~vector ( v -- )
  DUP vptr FREE THROW
  DUP static? IF erase EXIT THEN
  DUP erase
  FREE THROW ;

;MODULE

/TEST

: =? <> IF ABORT" dsds" THEN ;

\ countMem DROP 0 =?

0 VALUE a
: test1
 10 a vresize
 a vsize 10 =?
 a vector_impl::.msize @ 20 =?
 11 a vresize
 a vsize 11 =?
 a vector_impl::.msize @ 20 =?
 21 a vresize
 a vsize 21 =?
 a vector_impl::.msize @ 31 =?
 7 a vresize
 a vsize 7 =?
 a vector_impl::.msize @ 31 =?
 a ~vector
 ;

10 vector TO a
test1

10 svector TO a
test1

\ countMem DROP 0 =?

CR .( Test passed)
