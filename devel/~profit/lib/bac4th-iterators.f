REQUIRE /TEST ~profit/lib/testing.f
REQUIRE CONT ~profit/lib/bac4th.f

: iterateByBytes ( addr u <--> caddr ) PRO      OVER + SWAP ?DO I CONT DROP     LOOP ;
: iterateByWords ( addr u <--> waddr ) PRO      OVER + SWAP ?DO I CONT DROP     2 +LOOP ;
: iterateByCells ( addr u <--> addr ) PRO       OVER + SWAP ?DO I CONT DROP     CELL +LOOP ;

: iterateByByteValues ( addr u <--> caddr ) PRO OVER + SWAP ?DO I C@ CONT DROP  LOOP ;
: iterateByWordValues ( addr u <--> waddr ) 2* PRO OVER + SWAP ?DO I W@ CONT DROP  2 +LOOP ;
: iterateByCellValues ( addr u <--> addr ) CELLS PRO  OVER + SWAP ?DO I @ CONT DROP   CELL +LOOP ;

/TEST
: r S" abc" iterateByByteValues DUP EMIT ." _"  ;
r