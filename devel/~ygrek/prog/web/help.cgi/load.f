\ $Id$

REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE LIKE ~pinka/lib/like.f

MODULE: words_doc_list

: extract
  %[
  LAMBDA{ PARSE-NAME >STR % PARSE-NAME >STR % -1 PARSE >STR % } EVALUATE-WITH
  ]% ;
  
: load% FileLines=> DUP STR@ extract % ;

: umatches% { ll } ll list::car STR@ 2OVER ULIKE IF ll % THEN ;

EXPORT

\ file format :
\ word file stack
: words-load ( a u -- l ) %[ load% ]% ;

: words-find ( a u l -- l' l2' )
  { a u l }
  a u l ['] umatches% %[ list::iter 2DROP ]% -> l
  a u l LAMBDA{ list::car STR@ 2OVER LIKE 0= } list::partition 2SWAP 2DROP ;

: exact% { ll } ll list::car STR@ 2OVER CEQUAL IF ll % THEN ;
: words-exact ( a u l -- l' ) ['] exact% %[ list::iter 2DROP ]% ;

{{ list
: words-each-> ( l --> s1 s2 s3 \ <-- )
  PRO
  each->
  >R
  R@ cdr car 
  R@ cdr cdr car
  R> car
  CONT ;
}}

: words-free ( l -- ) LAMBDA{ ['] STRFREE list::free-with } list::free-with ;

;MODULE
