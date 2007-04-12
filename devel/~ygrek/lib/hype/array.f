
REQUIRE WL-MODULES ~day/lib/includemodule.f

: REQUIRE NEEDED ;

NEEDS ~day/hype3/hype3.f
NEEDS ~profit/lib/testing.f

10 CONSTANT RESERVE_DELTA

CLASS vector

 VAR _elemsize
 VAR _base
 VAR _count
 VAR _reserved

: elems ( n -- u ) _elemsize @ * ;

\ n - elemsize
: :setup ( n -- )
  _elemsize !
  0 _count !
  RESERVE_DELTA elems ALLOCATE THROW _base !
  RESERVE_DELTA _reserved !
;

init: ( -- )
  CELL :setup
;

dispose:
  _base @ FREE THROW
  0 _base !
  0 _count !
  0 _reserved !
;

: :size _count @ ;

: :nth ( n -- addr ) 
   DUP :size < 0= IF CR ." Index out of bounds " . :size . CR 0 SUPER returnStack. ABORT THEN
   elems _base @ + ;

: :resize ( n -- )
   DUP _reserved @ < IF _count ! EXIT THEN
   DUP RESERVE_DELTA + elems _base @ SWAP RESIZE THROW _base !
   DUP _count !
       RESERVE_DELTA + _reserved !
;

: :start _base @ ;
: :last :size 1- :nth ;

: :resize1 :size 1+ :resize ;

: :push_back ( a -- )
   :resize1
   :last _elemsize @ CMOVE
;

: :reserved _reserved @ ;

: :iterate ( addr[n] -- addr[n+1] ) _elemsize @ + ;
: :elemsize ( -- u ) _elemsize @ ;

;CLASS

/TEST

: ?ok 0= IF ABORT" failed" THEN ;

vector NEW a

10 a :resize
a :size 10 = ?ok
a :reserved 20 = ?ok
11 a :resize
a :size 11 = ?ok
a :reserved 20 = ?ok
21 a :resize
a :size 21 = ?ok
a :reserved 31 = ?ok
7 a :resize
a :size 7 = ?ok
a :reserved 31 = ?ok
a dispose


(
vector NEW a

a :start CR .
100 a :resize
a :start CR .
1000 a :resize
a :start CR .
2000 a :resize
a :start CR .
3000 a :resize
a :start CR .
4000 a :resize )
