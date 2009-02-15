\ $Id$
\
\ Вывод XML тегов бэктрекингом
\
\ На прямом ходу выводится открывающий тэг, при откате - закрывающий.

REQUIRE PRO ~profit/lib/bac4th.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE XMLSAFE ~ygrek/lib/xmlsafe.f

\ : << POSTPONE START{ ; IMMEDIATE
\ : >> POSTPONE }EMERGE ; IMMEDIATE
\ : quote [CHAR] " EMIT ;
\ : enquote-> PRO quote CONT quote ;

MODULE: xmltag

USER indent
USER-VALUE plain?

: do_indent CR indent @ SPACES ;

{{ list
: attributes ( l -- )
  LAMBDA{ SPACE DUP car STYPE ." =" [CHAR] " EMIT DUP cdar XMLSAFE::STYPE [CHAR] " EMIT free } 
  free-with ;
}}

: prepare-tag ( attr-l a u -- ) plain? NOT IF do_indent THEN ." <" TYPE attributes ;

EXPORT

\ open tag with attributes, close tag when backtracking
: atag ( attr-l a u --> \ <-- )
   PRO
   BACK " </{s}>" STYPE TRACKING
   2RESTB
   prepare-tag [CHAR] > EMIT
   indent KEEP
   indent 1+!
   CONT ;

\ open tag, close on backtracking
: tag ( a u --> \ <-- ) PRO list::nil -ROT atag CONT ;

\ emit closed tag with attributes
: /atag ( attr-l a u -- ) prepare-tag ." />" ;

\ emit closed tag
: /tag ( a u -- ) list::nil -ROT /atag ;

\ disable indentation for all subsequent tags
\ enable at backtracking
: plaintags ( <--> )  PRO TRUE TO plain? CONT FALSE TO plain? ;

;MODULE

: PARSE-SLITERAL PARSE-NAME POSTPONE SLITERAL ;

: atag: PARSE-SLITERAL POSTPONE atag ; IMMEDIATE
: tag: PARSE-SLITERAL POSTPONE tag ; IMMEDIATE
: /atag: PARSE-SLITERAL POSTPONE /atag ; IMMEDIATE
: /tag: PARSE-SLITERAL POSTPONE /tag ; IMMEDIATE

\ handy shortcut for name value pair
\ `value `name $$
: $$ %[ >STR % >STR % ]% % ;

/TEST \ Example

0 VALUE counter

: inner=> PRO 
   3 0 DO
   counter " inner{n}" DUP STR@ CONT STRFREE
   counter 1+ TO counter 
   LOOP
;

: sub=> PRO S" sub1" CONT S" sub2" CONT ;

: test1
   S" start" tag
     sub=> tag inner=> tag " {counter DUP *}" STYPE ;

REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f

: test2
   `html tag
   START{
     `head tag
     `title tag
     S" hello world!" TYPE
   }EMERGE
   `body tag
   %[ S" para" S" class" $$ ]% `div atag
   `p tag
   S" Test" TYPE ;

test1
CR
test2
CR
plaintags CR test2

\EOF

Запись S" a" tag S" b" tag S" c" tag сгенерирует вложенные тэги 
 <a><b><c></c></b></a>
Чтобы получить тэги на одном уровне их надо перебирать с помощью *> <*> <* или PRO CONT 
 S" a" tag PRO S" b" tag CONT S" c" CONT
или
 S" a" tag *> S" b" tag <*> S" c" <*
даст
 <a><b></b><c></c></a> 

Для того чтобы ограничить область захвата тегом можно использовать START{ }EMERGE
