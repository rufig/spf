REQUIRE /CHAR  ~pinka\samples\2005\ext\size.f 
REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] CHAR- [IF]
: CHAR- /CHAR - ;
[THEN]

: TAIL ( a u -- a1 u1 )
  DUP IF SWAP CHAR+ SWAP CHAR- EXIT THEN
  DROP 0
;
: HEAD ( a u -- a u1 )
  IF /CHAR EXIT THEN 0
;
: HEAD|TAIL ( a u -- a /char a2 u2 )
  2DUP HEAD 2SWAP TAIL
;
: TAIL|HEAD ( a u -- a2 u2 a /char )
  2DUP TAIL 2SWAP HEAD
;
