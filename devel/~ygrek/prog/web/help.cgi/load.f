\ $Id$

REQUIRE [IFDEF] ~nn/lib/ifdef.f \ for ~mak/A_IF.F
REQUIRE as-list ~ygrek/lib/list/more.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE LIKE ~pinka/lib/like.f

: extract
  %[
  LAMBDA{ PARSE-NAME >STR %s PARSE-NAME >STR %s -1 PARSE >STR %s } EVALUATE-WITH
  ]% ;
  
: load% FileLines=> DUP STR@ extract %l ;

\ file format :
\ word file stack
: load ( a u -- l ) %[ load% ]% ;

() VALUE ul

\ I am lazy - l' points to elements in l - can't be FREEd
: find ( a u l -- l' )
   %[ LAMBDA{ >R R@ car STR@ 2OVER LIKE IF R> %l ELSE R@ car STR@ 2OVER ULIKE IF R> ul vcons TO ul ELSE RDROP THEN 
   THEN } SWAP mapcar 2DROP ]% ;

: each-> ( l -- )
  PRO
  BACK DROP TRACKING
  list->
  >R
  R@ car cdr car 
  R@ car cdr cdr car
  R> car car 
  CONT ;

