\ $Id$
\
\ Разбор даты в виде S" 2007-01-27T17:40:36+03:00"

\ Не знаю что за формат такой - его использует ForthWiki
\ Парсить правда проще :)

REQUIRE /STRING lib/include/string.f
REQUIRE { lib/ext/locals.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE DateTime>Num ~ygrek/lib/spec/unixdate.f

MODULE: ygrek/lib/spec/sdate2.f

: MUST ( ? n -- ) SWAP IF DROP ELSE 4624000 + THROW THEN ;

: (parse-num-unixdate) { | d m y hh mm ss +z -- ss mm hh d m y }
   [CHAR] - PARSE
   DUP 4 = 1 MUST 
   NUMBER 2 MUST TO y

   [CHAR] - PARSE
   DUP 2 = 3 MUST
   NUMBER 4 MUST TO m

   [CHAR] T PARSE
   DUP 2 = 5 MUST
   NUMBER 6 MUST TO d

   [CHAR] : PARSE
   DUP 2 = 7 MUST
   NUMBER 8 MUST TO hh

   [CHAR] : PARSE
   DUP 2 = 9 MUST
   NUMBER 10 MUST TO mm

   -1 PARSE
   2 /GIVE
   DUP 2 = 11 MUST
   NUMBER 12 MUST TO ss

   1 /GIVE 2SWAP
   2 /GIVE 2SWAP S" :00" COMPARE 0= 13 MUST
   NUMBER 14 MUST TO +z
   2DUP S" +" COMPARE 0= IF 2DROP +z NEGATE TO +z ELSE S" -" COMPARE 0= 15 MUST THEN

   \ учтём timezone
   ss mm hh d m y DateTime>Num ( stamp ) 
   +z 60 * 60 * + \ прибавили смещение (+z в часах)
   ;

EXPORT

: parse-num-unixdate ( a u -- timestamp|0 )
   ['] (parse-num-unixdate) ['] EVALUATE-WITH CATCH IF DROP 2DROP 0 THEN ;

;MODULE

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES ygrek/lib/spec/sdate2.f

(( S" 2007-01-27T17:40:36+03:00" parse-num-unixdate Num>DateTime -> 36 40 14 27 1 2007 ))

END-TESTCASES
