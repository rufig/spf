: .S
 ." STACK: "
  DEPTH 15 AND DUP
  IF DUP 0 DO DUP PICK U. 1- LOOP DROP
  ELSE DROP ." <EMPTY>" THEN CR
;

S" calc/fpnum.f" INCLUDED

.( =====================================================) CR
OBJECT PNUM N
10 S" 128.624" N <STR
\ N SHOW
.( 1. ) 10 N >STR TYPE CR
.( 2. ) 2 N >STR TYPE CR
.( 3. ) 16 N >STR TYPE CR
10 S" 128.625" N <STR
\ N SHOW
.( 1. ) 10 N >STR TYPE CR
.( 2. ) 2 N >STR TYPE CR
.( 3. ) 16 N >STR TYPE CR
10 S" 128.626" N <STR
\ N SHOW
.( 1. ) 10 N >STR TYPE CR
.( 2. ) 2 N >STR TYPE CR
.( 3. ) 16 N >STR TYPE CR
|CLASS

: QWE 17 2 DO I . ." ) " 0 1 I UM/ HEX U. CR DECIMAL LOOP ;