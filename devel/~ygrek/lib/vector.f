\ $Id$
\ 
\ std::vector :)
\ Динамический буфер
\ Использует глобальную память процесса

MODULE: yz \ импортирует слишком много всего - конфликт возможен - предотвращаем
REQUIRE MGETMEM ~yz/lib/gmem.f
;MODULE
REQUIRE ACCERT( lib/ext/debug/accert.f

MODULE: std:vector

3 ACCERT-LEVEL !

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

: MRESIZE
  SWAP 8 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapReAlloc
  DUP IF 0 ELSE -300 THEN THROW ;

EXPORT

: vptr ( v -- a ) .ptr @ ;

: vresize ( n v -- )
  \ .resize @ EXECUTE
  ACCERT2( CR ." resize=" OVER . )
   DUP vptr 0=
   IF 
    ACCERT2( CR ." NEW" )
     2DUP .msize! 2DUP SWAP delta + OVER cells yz::MGETMEM SWAP .ptr ! 
   ELSE
    ACCERT2( CR ." RESIZE" )
     2DUP .msize @ > IF 
       2DUP .msize! 
       2DUP SWAP delta + OVER cells SWAP vptr SWAP MRESIZE OVER .ptr ! THEN
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
   0 /SIZE yz::MGETMEM init ;

: vsize .size @ ;

: v[]  ( n v -- a ) >R DUP 1+ R@ vsize > IF RDROP CR . ." Index out of" ABORT THEN R@ cells R> vptr + ;

: ~vector ( v -- )
  DUP vptr yz::MFREE 0= IF -9 THROW THEN
  DUP static? IF erase EXIT THEN
  DUP erase
  yz::MFREE 0= IF -9 THROW THEN ;

;MODULE

\EOF

\ REQUIRE test ~ygrek/lib/test.f
 : ? 0= IF ABORT" dsds" THEN ;

\ MemReport

\ test{
0 VALUE a
: test1
 10 a resize
 a vsize 10 = ?
 a std:vector::.msize @ 20 = ?
 11 a resize
 a vsize 11 = ?
 a std:vector::.msize @ 20 = ?
 21 a resize
 a vsize 21 = ?
 a std:vector::.msize @ 31 = ?
 7 a resize
 a vsize 7 = ?
 a std:vector::.msize @ 31 = ?
 a ~vector
 ;

10 vector TO a
test1

10 svector TO a
test1
\ }test

\ MemReport