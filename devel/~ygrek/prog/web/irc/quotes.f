\ цитатник для бота

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE scan-list ~ygrek/lib/list/all.f
REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f
REQUIRE UPPERCASE ~ac/lib/string/uppercase.f
REQUIRE re_match? ~ygrek/lib/re/re.f
REQUIRE ULIKE ~pinka/lib/like.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f
REQUIRE ms@ lib/include/facil.f

' ANSI>OEM TO ANSI><OEM

MODULE: quotes

ms@ SGENRAND

() VALUE quotes

0 VALUE search_list
0 0 2VALUE searched

" quotes.txt" VALUE s-quotes-file

: quotes-file s-quotes-file STR@ ;

: dump-quotes ( -- )
   \ очистить файл
   quotes-file EMPTY
   \ записать весь список
   LAMBDA{ STR@ quotes-file ATTACH-LINE-CATCH DROP } quotes mapcar ;

EXPORT

: quotes-file! s-quotes-file STR! ;
: quotes-total quotes length ;

\ ~ygrek/lib/debug/inter.f

: load-quotes
  \ quotes FREE-LIST
  CR ." REMINDER: BUG! MEMORY LEAK. Cant do FREE-LIST cause it is in another thread. Fix it (easy)"
  () TO quotes
  %[
  START{
   quotes-file FileLines=>
   DUP STR@
   \ 2DUP TYPE CR
   RE" (\S+)\s+(\S.*)" re_match?
   IF
    2 get-group DROP C@ 0x20 = IF ." !" THEN
    1 get-group 2 get-group " {s} [{s}]" %s
   THEN
  }EMERGE
  ]%
  TO quotes
  quotes-total quotes-file " Quotes reloaded from '{s}'. Total {n}" CR STYPE ;

: type-quotes ( -- ) quotes list-> car STR@ CR TYPE ;

DEFINITIONS

: list-random-quote ( list -- node ) DUP length GENRANDMAX SWAP nth ;
: node>s DUP empty? IF DROP " no quotes" ELSE car THEN ;

0 VALUE re

EXPORT

: random-quote ( -- s ) quotes list-random-quote node>s ;
: quote[] ( n -- s ) quotes nth node>s ;

: search-quote ( a u -- s )
   \ " .*{s}.*" DUP STR@ BUILD-REGEX TO re STRFREE
   " *{s}*" TO re
   %[ LAMBDA{ DUP STR@ re STR@ ULIKE IF % ELSE DROP THEN } quotes mapcar ]%
   DUP list-random-quote node>s SWAP FREE-LIST
   re STRFREE ;

: register-quote ( quote-au author-au -- )
   " {s} {s}" DUP STR@ quotes-file ATTACH-LINE-CATCH DROP STRFREE 
   load-quotes ;

;MODULE

/TEST

load-quotes
CR S" форт" search-quote STR@ TYPE
