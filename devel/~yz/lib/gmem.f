\ Глобальная память, разделяемая между потоками
\ Идея реализации - А. Черезов
\ Ю. Жиловец, 17.12.2002

REQUIRE CZMOVE ~yz/lib/common.f

MODULE: GMEM

EXPORT

: MALLOCATE ( u -- u-addr/0)  8 ( HEAP_ZERO_MEMORY) GetProcessHeap HeapAlloc ;
: MFREE ( a-addr -- ?) 0 GetProcessHeap HeapFree ;

: MGETMEM ( u -- a-addr ) MALLOCATE DUP IF 0 ELSE -300 THEN THROW ;
: MFREEMEM ( a-addr -- ) MFREE ERR THROW ;

: CMGETMEM ( a n -- a2) DUP 1+ MGETMEM 2DUP C! DUP >R 1+ SWAP CMOVE R> ;
: CZMGETMEM ( a n -- a) DUP 1+ MGETMEM DUP >R CZMOVE R> ;
: ZMGETMEM ( z -- a) ASCIIZ> CZMGETMEM ;

;MODULE
