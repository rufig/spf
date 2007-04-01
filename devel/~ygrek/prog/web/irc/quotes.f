\ цитатник для бота

REQUIRE STR@ ~ac/lib/str4.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE InsertNodeEnd ~day/lib/staticlist.f
REQUIRE GENRAND ~ygrek/lib/neilbawd/mersenne.f
REQUIRE UPPERCASE ~ac/lib/string/uppercase.f
REQUIRE ULIKE ~pinka/lib/like.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE ATTACH ~pinka/samples/2005/lib/append-file.f

' ANSI>OEM TO ANSI><OEM

MODULE: quotes

WINAPI: GetTickCount KERNEL32.DLL

GetTickCount SGENRAND

0 VALUE quotes

/node 
CELL -- .val
CONSTANT /quote

EXPORT

0 0 2VALUE quotes-file 

DEFINITIONS

\ HERE S" quotes.txt" S", COUNT 2TO quotes-file
: aaa S" quotes.txt" ; aaa 2TO quotes-file

: List=> ( list -- ) R> SWAP ForEach ;
: >STR ( a u -- s ) "" >R R@ STR+ R> ;
: add-quote ( s -- ) quotes AllocateNodeEnd .val ! ;
: dump-quotes ( -- )
   \ очистить файл
   quotes-file R/W CREATE-FILE THROW CLOSE-FILE THROW 
   \ записать весь список
   LAMBDA{ .val @ STR@ quotes-file ATTACH-LINE-CATCH DROP } quotes ForEach ;

0 0 2VALUE author
0 0 2VALUE text

: (parse)
   PARSE-NAME 2TO author
   SkipDelimiters
   -1 PARSE 2TO text ;

0 VALUE search_list
0 0 2VALUE searched
  
EXPORT

: quotes-total quotes 0= IF 0 EXIT THEN
     quotes listSize ;

: load-quotes
  \ S" loading quotes" ECHO
  \ quotes 0= IF S" Creating new list" ECHO /quote CreateList TO quotes ELSE S" Freeing" ECHO quotes FreeList THEN
  S" REMINDER! BUG - MEMORY LEAK!" ECHO
  /quote CreateList TO quotes
  START{
   quotes-file FileLines=>
   DUP
   STR@
   \ 2DUP TYPE CR
   ['] (parse) EVALUATE-WITH
   author text " {s} [{s}]" add-quote
  }EMERGE 
  quotes listSize 0= IF
   " no quotes at all." add-quote \ всегда есть один элемент в списке!
  THEN 
  quotes listSize quotes-file " Quotes reloaded from '{s}'. Total {n}" DUP STR@ TYPE CR STRFREE ;

: type-quotes 
    quotes 0= IF EXIT THEN
    quotes List=> .val @ STR@ CR TYPE ;

: list-random-quote ( list -- node )
    DUP listSize 
    GENRANDMAX
    SWAP list[] ;

: random-quote ( -- s )
    quotes 0= IF " quotes not loaded." EXIT THEN
    quotes list-random-quote
    ?DUP 0= IF " cant find quote" ELSE .val @ THEN ;

: quote[] ( n -- s ) quotes 0= IF DROP " quotes not loaded." EXIT THEN
   quotes list[] 
   ?DUP 0= IF " cannot find quote" ELSE .val @ THEN ;

: search-quote ( a u -- s )
   2TO searched
   quotes 0= IF " no quotes loaded." EXIT THEN
   search_list 0= IF /quote CreateList TO search_list ELSE search_list FreeList THEN
   LAMBDA{ 
     .val @ DUP STR@ 
     searched " *{s}*" STR@
     ULIKE IF search_list AllocateNodeEnd .val ! ELSE DROP THEN 
   }  quotes ForEach
   search_list list-random-quote ?DUP 0= IF " cannot find quote" ELSE .val @ THEN ;

: register-quote ( quote-au author-au -- )
   " {s} {s}" DUP STR@ quotes-file ATTACH-LINE-CATCH DROP STRFREE 
   load-quotes ;

;MODULE

\ load-quotes
\ S" форт" search-quote STR@ TYPE
