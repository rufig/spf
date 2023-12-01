\ 2012
\ Memory allocation on the return stack with automatic deallocation on exit.

\ The word `RBUF ( u1\0 -- a-addr u1 ; R: -- i*x nest-sys )`
\ returns an allocated memory region ( a-addr u1 ).
\ The memory region is freed when the word in which `RBUF` was called completes.
\ An arbitrary number of memory regions can be requested.


: (FREE-RBUF)
  R> RFREE
;
: RBUF ( u1\0 -- a-addr1 u1 ; R: -- i*x nest-sys.free-rbuf )
  \ Only for compilation.
  \ An ambiguous condition exists if the first input parameter is 0.
  R>
  OVER CELL+ 1- >CELLS DUP RALLOT SWAP >R  ( u r a )
  ['] (FREE-RBUF) >R
  SWAP >R
  SWAP
;
: RDROP-BUF ( -- ; R: i*x nest-sys.free-rbuf -- )
  \ Only for compilation.
  \ Run-Time semantics:
  \   Deallocate the last memory region allocated by `RBUF`
  \   among the regions not yet deallocated.
  R> RDROP R> RFREE >R
;

: RCARBON ( sd1 -- sd2 ; R: -- i*x nest-sys )
  \ Only for compilation.
  \ Run-Time semantics:
  \   A character string sd2 is a copy of sd1;
  \   sd2 is followed by a null-character in memory;
  \   sd2 is deallocated when the caller completes.
  R>
  OVER CHAR+ CELL+ 1- >CELLS DUP RALLOT SWAP >R  ( u r a )
  ['] (FREE-RBUF) >R
  SWAP >R ( addr u a )
  SWAP ( addr a u )
  2DUP 2>R MOVE 2R> 2DUP + 0 SWAP C!
;

: ENSURE-ASCIIZ-R ( sd1 -- sd1  |  sd1 -- sd2 ; R: -- i*x nest-sys )
  \ Only for compilation.
  \ Run-Time semantics:
  \   - If sd1 is a null-reference string ( 0 0 ), then sd1 is returned.
  \   - If it is confirmed that sd1 is followed by a null-character in memory,
  \     then sd1 is returned.
  \   - Otherwise, sd2, which is a copy of sd1, is returned;
  \     sd2 is followed by a null-character in memory;
  \     sd2 is deallocated when the caller completes.
  OVER 0= IF EXIT THEN
  2DUP + C@ 0= IF EXIT THEN
  R> -ROT RCARBON ROT >R
;

