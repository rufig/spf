\
\
\

REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE x.mask:= ~mlg/SrcLib/bitfield.f
REQUIRE arr{ ~profit/lib/bac4th-sequence.f

: mask ( n mask -- n' ) 0 -ROT x.mask:= ;

: combs=> ( mask --> n \ <-- n ) PRO
0 SWAP BEGIN ( counter mask )
2DUP mask CONT
OVER <> WHILE
SWAP 1+ SWAP
REPEAT 2DROP ;

\
: combs ( mask -- addr u )
arr{ combs=> }arr TUCK HEAP-COPY SWAP ;

\EOF
: combs. combs=> DUP . ;

BASE @ 2 BASE !

1001 combs.
1001 combs>arr DUMP
BASE !