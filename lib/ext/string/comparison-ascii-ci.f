\ 2020-02-05 ruv
\ 2023-11-12 ruv

\ ASCII Case-Insensitive Collation
\ Ordinal-Case-Insensitive (OCI) comparison operations


WORDLIST CONSTANT string-ascii-ci    LATEST-NAME NAME>CSTRING  string-ascii-ci FIX-WID-CSTRING

GET-CURRENT  string-ascii-ci PUSH-ORDER DEFINITIONS

: eq-char ( char char -- flag )
  OVER XOR DUP 0= IF 2DROP TRUE EXIT THEN ( c1 x )
  DUP 32 ( %100000 ) <> IF 2DROP FALSE EXIT THEN
  OR  [CHAR] a  [ CHAR z 1+ LIT, ]  WITHIN
;

: ne-char ( char char -- flag )
  OVER XOR DUP 0= IF 2DROP FALSE EXIT THEN ( c1 x )
  DUP 32 ( %100000 ) <> IF 2DROP TRUE EXIT THEN
  OR  [CHAR] a  [ CHAR z 1+ LIT, ]  WITHIN  0=
;

: equals ( sd.txt2 sd.txt1 -- flag )
  ROT OVER <> IF ( a2 a1 u1 ) DROP 2DROP FALSE EXIT THEN
  OVER + ( a2 a1 a1z ) >R
  BEGIN DUP R@ U< WHILE
    2DUP C@ SWAP C@ ( a2 a1 c1 c2 )
    OVER XOR DUP IF ( a1 a2 c1 x )
      DUP 0x20 ( %100000 ) <> IF 2DROP 2DROP FALSE RDROP EXIT THEN
      OR  [CHAR] a  [ CHAR z 1+ LIT, ] WITHIN 0= IF 2DROP FALSE RDROP EXIT THEN
    ELSE ( a1 a2 c1 x )
      2DROP
    THEN
    SWAP CHAR+ SWAP CHAR+ \ faster than "CHAR+ SWAP CHAR+"
  REPEAT RDROP 2DROP TRUE
;

DROP-ORDER SET-CURRENT
