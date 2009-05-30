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

MODULE: xmltag

USER indent-depth
USER-VALUE plain?
USER count

: (indent) CR indent-depth @ SPACES ;
: indent plain? NOT IF (indent) THEN ;

{{ list
: attributes ( l -- )
  LAMBDA{ SPACE DUP car STYPE ." =" [CHAR] " EMIT DUP cdar XMLSAFE::STYPE [CHAR] " EMIT free } 
  free-with ;
}}

: prepare-tag ( attr-l a u -- ) indent ." <" TYPE attributes ;

EXPORT

\ open tag with attributes, close tag when backtracking
\ attributes is a list of pairs of strings
: atag ( attr-l a u --> \ <-- )
   PRO
   count 1+! \ increase tag count
   BACK 
    indent-depth 1-!
    count @ <> IF indent THEN \ test for inner tags
    " </{s}>" STYPE
   TRACKING
   count @ RESTB DROP \ remember current tags count
   2RESTB \ remember tag name
   prepare-tag [CHAR] > EMIT
   \ indent-depth KEEP
   indent-depth 1+!
   CONT ;

\ open tag, close on backtracking
: tag ( a u --> \ <-- ) PRO list::nil -ROT atag CONT ;

\ emit closed tag with attributes
: /atag ( attr-l a u -- ) prepare-tag ."  />" ;

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

\ handy shortcut for name value pair (for attributes)
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
Чтобы получить тэги на одном уровне надо ограничить область действия вложенных тэгов
 S" a" tag *> S" b" tag <*> S" c" tag <*
или
 `a tag START{ `b tag }EMERGE START{ `c tag }EMERGE
даст
 <a><b></b><c></c></a> 

Для того чтобы ограничить область захвата тэгом можно использовать START{ }EMERGE

Реализация аттрибутов возможно не очень удобная, но чаще всего при использовании
выфакторизовывается. Возможно стоит сделать спец. синтаксис.

