\ $Id$
\
\ Разбор даты в виде S" Tue, 19 Dec 2006 19:55:16 +0300"
\ 
\ target: RFC-822


REQUIRE /STRING lib/include/string.f
REQUIRE W-DATEA ~ac/lib/win/date/date-int.f
REQUIRE { lib/ext/locals.f
REQUIRE PARSE-NAME lib/include/common.f
REQUIRE /GIVE ~ygrek/lib/parse.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE Date>Num ~ygrek/lib/spec/unixdate.f

: ?IsFoundInCountedStringArray { a u arr total -- n ? }
   arr
   total 0 DO
    DUP COUNT a u COMPARE 0= IF DROP I TRUE UNLOOP EXIT THEN
    DUP COUNT NIP + 1+
   LOOP
   DROP
   0 FALSE ;

: ?DayOfWeek ( a u -- ? ) W-DATEA @ 7 ?IsFoundInCountedStringArray NIP ;
: MonthName ( a u -- n ? ) M-DATEA @ 12 ?IsFoundInCountedStringArray ;
: ?MonthName ( a u -- ? ) MonthName NIP ;

: MUST ( ? n -- ) SWAP IF DROP ELSE 4623000 + THROW THEN ;

: (parse-date) { | d m y hh mm ss +z -- ss mm hh d m y }
   PARSE-NAME
   DUP 4 = 1 MUST
   3 /GIVE ?DayOfWeek 2 MUST
   S" ," COMPARE 0= 3 MUST

   PARSE-NAME
   NUMBER 4 MUST TO d

   PARSE-NAME
   MonthName 5 MUST 1+ TO m

   PARSE-NAME
   DUP 4 = 6 MUST
       NUMBER 7 MUST TO y

   [CHAR] : PARSE 
   DUP 2 = 8 MUST
       NUMBER 9 MUST TO hh

   [CHAR] : PARSE 
   DUP 2 = 10 MUST
       NUMBER 11 MUST TO mm

   PARSE-NAME
   DUP 2 = 12 MUST
       NUMBER 13 MUST TO ss

   PARSE-NAME
   2DUP S" GMT" COMPARE 0=
   IF
     2DROP
     0 TO +z
   ELSE
     DUP 5 = 14 MUST
     1 /GIVE 2SWAP
     2 /GIVE 2SWAP S" 00" COMPARE 0= 15 MUST
     NUMBER 16 MUST TO +z
     2DUP S" +" COMPARE 0= IF 2DROP +z NEGATE TO +z ELSE S" -" COMPARE 0= 17 MUST THEN
   THEN

   \ учтём timezone
   ss mm hh d m y Date>Num ( stamp ) 
   +z 60 * 60 * + \ прибавили смещение (+z в часах)
   Num>Date ;
   

: parse-date ( a u -- ss mm hh d m y -1 | 0 )
   ['] (parse-date) ['] EVALUATE-WITH CATCH IF DROP 2DROP 0 ELSE TRUE THEN ;

/TEST

: TEST
  CR
  2DUP CR ."  Original : " TYPE 
  parse-date 0= ABORT" failed"
  <# DateTime#GMT 0 0 #> CR ." Converted : " TYPE
;

S" Tue, 19 Dec 2006 19:55:16 +0300" TEST
S" Tue, 19 Dec 2006 19:55:16 -0800" TEST
S" Tue, 19 Dec 2006 19:55:16 GMT" TEST

CR CR .( Test jump over New Year)
S" Tue, 31 Dec 2001 23:55:16 -0200" TEST
S" Wed, 31 Dec 2002 23:55:16 -0200" TEST
S" Thu, 31 Dec 2003 23:55:16 -0200" TEST
S" Sat, 31 Dec 2004 23:55:16 -0200" TEST
S" Sun, 31 Dec 2005 23:55:16 -0200" TEST
S" Mon, 31 Dec 2006 23:55:16 -0200" TEST
