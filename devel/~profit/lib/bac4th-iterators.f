REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE LOCAL ~profit/lib/static.f

: iterateBy  ( addr u step --> addr \ addr <-- addr ) PRO LOCAL step step !
OVER + SWAP ?DO
I CONT DROP
step @ +LOOP ;

: iterateByBytes ( addr u <--> caddr ) PRO 1 iterateBy CONT ;
: iterateByWords ( addr u <--> waddr ) PRO 2 iterateBy CONT ;
: iterateByCells ( addr u <--> addr )  PRO CELL iterateBy CONT ;
: iterateByDCells ( addr u <--> qaddr ) PRO 2 CELLS iterateBy CONT ;

: iterateByByteValues ( addr n <--> caddr ) PRO      iterateByBytes C@ CONT ;
: iterateByWordValues ( addr n <--> waddr ) PRO 2*   iterateByWords W@ CONT ;
: iterateByCellValues ( addr n <--> addr )  PRO CELLS iterateByCells @ CONT ;

/TEST
: r S" abc" iterateByByteValues DUP EMIT ." _"  ;
r