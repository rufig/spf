REQUIRE CHAR-UPPERCASE ~ac/lib/string/uppercase.f

: COMPARE-CHAR-U ( c1 c2 --  -1|0|1 )
  2DUP = IF 2DROP 0 EXIT THEN
  CHAR-UPPERCASE SWAP CHAR-UPPERCASE -
  DUP 0= IF EXIT THEN
  0< IF 1 EXIT THEN -1
  \ n is minus-one (-1) if the character c1 has a lesser numeric value than the character c2
  \ and one (1) otherwise.
;
: COMPARE-U ( addr1 u1 addr2 u2 -- flag )
  ROT 2DUP - >R UMIN
  0 ?DO 2DUP
  C@ SWAP C@ SWAP
  COMPARE-CHAR-U DUP IF NIP NIP UNLOOP RDROP EXIT THEN DROP
  SWAP CHAR+ SWAP CHAR+
  LOOP 2DROP R>
  DUP 0= IF EXIT THEN
  0< IF 1 EXIT THEN -1
  \ n is minus-one (-1) if u1 is less than u2 and one (1) otherwise
;
