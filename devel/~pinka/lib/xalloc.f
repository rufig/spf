REQUIRE [UNDEFINED] lib/include/tools.f

\ 31.01.2009
\ from: model/data/asset.f.xml

[UNDEFINED] XCOUNT [IF]
: XCOUNT ( xaddr -- a u ) 
  DUP 0= IF  0 EXIT THEN 
  DUP CELL+ SWAP @
;
[THEN]

: (XUPDATE) ( a u xaddr -- ) 
  2DUP ! CELL+ SWAP 2DUP + 0! MOVE
;
: XALLOC ( a u -- xaddr ) 
  DUP CELL+ CELL+ ALLOCATE THROW (  [ a u addr ]  ) 
  DUP >R (XUPDATE) R>
;


: XUPDATED ( a u xaddr -- xaddr2 ) 
  DUP 0= IF  DROP XALLOC EXIT THEN 
  OVER CELL+ CELL+ RESIZE THROW (  [ a u addr-x2 ]  ) 
  DUP >R (XUPDATE) R>
;
: XENCLOSED ( a u xaddr -- xaddr2 ) 
  DUP 0= IF  DROP XALLOC EXIT THEN 
  2DUP @ + (  [ a u xaddr u+u1 ]  ) 
  CELL+ CELL+ RESIZE THROW (  [ a u xaddr2 ]  ) 
  DUP XCOUNT + -ROT (  [ a a2 u xaddr2 ]  ) 
  2DUP +! >R 2DUP + 0! MOVE R>
;
