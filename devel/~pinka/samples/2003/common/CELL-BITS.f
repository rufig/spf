\ 12.Oct.2003

REQUIRE [DEFINED] lib\include\tools.f

VARIABLE CELL-BITS  \ a count of bits in the cell

: 0CELL-BITS ( -- )
  CELL-BITS 0!
  -1 BEGIN CELL-BITS 1+!  1 RSHIFT DUP 0= UNTIL DROP
;

0CELL-BITS  \ initialization

[DEFINED] AT-PROCESS-STARTING           [IF]
..: AT-PROCESS-STARTING 0CELL-BITS ;..  [THEN]

