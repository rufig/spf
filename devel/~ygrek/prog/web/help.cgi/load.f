\ $Id$

REQUIRE as-list ~ygrek/lib/list/more.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE LIKE ~pinka/lib/like.f

MODULE: words_doc_list

: extract
  %[
  LAMBDA{ PARSE-NAME >STR %s PARSE-NAME >STR %s -1 PARSE >STR %s } EVALUATE-WITH
  ]% ;
  
: load% FileLines=> DUP STR@ extract %l ;

\ do not use %l here so that it won't be accidently deleted by FREE-LIST
\ cause ll is still owned by parent list
: umatches% { ll } ll car STR@ 2OVER ULIKE IF ll % THEN ;

EXPORT

\ file format :
\ word file stack
: words-load ( a u -- l ) %[ load% ]% ;

: words-find ( a u l -- l' l2' )
  { a u l }
  a u ['] umatches% l %[ mapcar 2DROP ]% -> l
  a u LAMBDA{ car car STR@ 2OVER LIKE 0= } l partition-this 2SWAP 2DROP ;

: words-each-> ( l --> s1 s2 s3 \ <-- )
  PRO
  list->
  car >R
  R@ cdr car 
  R@ cdr cdr car
  R> car
  CONT ;

;MODULE
