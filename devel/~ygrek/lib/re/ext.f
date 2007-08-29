\ $Id$
\ ƒополнительные строковые операции с регекспами

REQUIRE re_match? ~ygrek/lib/re/re.f

: re_search { a u re -- a1 u1 }
  a u
  u 0 ?DO
   2DUP re re_sub ?DUP IF NIP UNLOOP EXIT THEN
   1 /STRING
  LOOP ;

: re_search-> ( a u re --> a u \ <-- )
  PRO { a u re | a1 m -- list }
  BEGIN
   a u re re_search -> m -> a1
   m
  WHILE
   a1 m CONT
   a u m /STRING -> u -> a
  REPEAT ;

: re_split-> ( a u re --> a u \ <-- )
  PRO { a u re | n m -- list }
  BEGIN
   a u re re_search
   DUP
  WHILE
   >R a - DUP R> + -> m -> n
   ( a---------u )
   ( a---n__m--u )
   n 0 > IF a n CONT THEN
   m u = IF EXIT THEN
   a u m /STRING -> u -> a
  REPEAT
  2DROP
  a u CONT ;

: re_search_all ( a u re -- list ) %[ START{ re_search-> >STR %s }EMERGE ]% ;

: re_split ( a u re -- list ) %[ START{ re_split-> >STR %s }EMERGE ]% ;

\ : re_replace { s t re -- s1 }
\    BEGIN
\   s STR@ re re_match? ;

: stre_split STREGEX=> re_split ;
: stre_search STREGEX=> re_search ;

\ : re_search_bwd
