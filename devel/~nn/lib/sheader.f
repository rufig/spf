\ USER LAST-CFA
\ CREATE SH-BUF 64 ALLOT
REQUIRE [IF] lib/include/tools.f
0 [IF]
: SHEADER ( addr u -- )
  HERE 0 , ( cfa )
\  DUP LAST-CFA !
  0 C,     ( flags )
  ROT ROT WARNING @
  IF 2DUP SFIND
     IF DROP 2DUP TYPE ."  isn't unique" CR
     ELSE 2DROP THEN
  THEN
  CURRENT @ +SWORD
  ALIGN
  HERE SWAP ! ( заполнили cfa )
;
: SCREATE ( S" name" -- )
  SHEADER
  HERE DOES>A ! ( для DOES )
  ['] _CREATE-CODE COMPILE,
;
[THEN]

: SCREATE ( S" name" -- )
  CREATED
;
