\ $Id$
\ Дополнительные операции над строками с использованием регулярных выражений

REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f

: re_search { a u re -- a1 u1 }
  a u
  u 0 ?DO
   2DUP re re_sub ?DUP IF NIP UNLOOP EXIT THEN
   1 /STRING
  LOOP ;

\ a1 u1 - not-matched part
\ a2 u2 - matched part
: re_divide-> ( a u re --> a2 u2 a1 u1 \ <-- )
  PRO { a u re | s m n }
  BEGIN
   a u re re_search -> m -> s
   m
  WHILE
   s a - -> n
   s m a n CONT
   ( a___n______u )
   ( ----s__m---- )
   a u n m + /STRING -> u -> a
   u 0= IF EXIT THEN
  REPEAT
  0 0 a u CONT ;

: re_search-> PRO re_divide-> 2DROP CONT ;
: re_split-> PRO re_divide-> 2SWAP 2DROP CONT ;

\ : re_out re_divide-> TYPE CR TYPE CR ;
\ S" 1fqwe7e677ew8ew77re8fd090fdf" RE" \d+" re_out

0 [IF]
: re_search1-> ( a u re --> a u \ <-- )
  PRO { a u re | a1 m }
  BEGIN
   a u re re_search -> m -> a1
   m
  WHILE
   a1 m CONT
   a1 u a1 a - - m /STRING -> u -> a
  REPEAT ;

: re_split1-> ( a u re --> a u \ <-- )
  PRO { a u re | n m }
  BEGIN
   a u re re_search
   DUP
  WHILE
   >R a - DUP R> + -> m -> n
   ( a---------u )
   ( a---n__m--u )
   a n CONT
   m u = IF EXIT THEN
   a u m /STRING -> u -> a
  REPEAT
  2DROP
  a u CONT ;
[THEN]

\ возвращает список строк
\ освобождать так: ['] STRFREE list::free-with
: re_search_all ( a u re -- list ) %[ START{ re_search-> >STR % }EMERGE ]% ;

: re_split ( a u re -- list ) %[ START{ re_split-> >STR % }EMERGE ]% ;


: str-replace-matches ( s -- )
   10 0 DO
    DUP I " \{n}" I get-group >STR replace-str-
   LOOP 
   DROP ;

0 [IF]
USER-VALUE r_re
USER-VALUE r_

\ st is STRFREE'd
: re_replace { a u re st | s -- s }
    a u re 
    START{ 
     re_divide->
     s STR+
     re re_match? DROP
     st STR@ >STR DUP str-replace-matches 
                      s S+
     }EMERGE
    IF
     
     st STR@ s STR!
    THEN
    st STRFREE
;
[THEN]


: stre_split STREGEX=> re_split ;
: stre_search STREGEX=> re_search ;

\ : re_search_bwd

: "TYPE" [CHAR] " EMIT TYPE [CHAR] " EMIT ;

: re_match_result
   groups-total 0 ?DO I " {n} : " STYPE I get-group "TYPE" CR LOOP ;

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES re_search_all

S" 12 34 56 78 90" RE" \d+" re_search_all VALUE l
(( l :NONAME STR@ NUMBER 0= ABORT" not a number" ; list::iter -> 12 34 56 78 90 ))
l ' STRFREE list::free-with

END-TESTCASES
