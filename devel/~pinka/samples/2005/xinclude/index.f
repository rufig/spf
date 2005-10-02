\ 02.Oct.2005 ruvim@forth.org.ru
\ $Id$

REQUIRE [IF] lib\include\tools.f

REQUIRE XML_READ_DOC ~ac\lib\lin\xml\xml.f 

\ REQUIRE XML_DOC ~ac\lib\ns\xml.f

0 [IF]
: XML_FREE_DOC ( doc -- )
  1 xmlFreeDoc DROP
  0 xmlCleanupParser DROP
;
[THEN]

3 CONSTANT XML_ELEMENT_TEXT

: ?ASCIIZ> ( addrz -- addr u )
  DUP IF ASCIIZ> ELSE 0 THEN
;

\ ----------------------------------

: cdr ( node1 -- node2 | 0 )
  x.next @
;
: car ( o -- node | 0 )
  x.children @
;
: acar ( o -- node | 0 )
  x.properties @
;

: content ( node -- a u )
  x.content @ ?ASCIIZ>
;
: name ( node -- a u )
  x.name @ ?ASCIIZ>
;

\ ----------------------

: apply ( node1 xt -- node2 )
  OVER >R EXECUTE R> cdr
;
: map ( node xt -- )
  >R BEGIN DUP WHILE R@ apply REPEAT DROP RDROP
;

\ -----------------------------

: (search-name) ( a u n1 -- node true | false )
  BEGIN DUP WHILE >R
    2DUP R@ name COMPARE 0= IF
    2DROP R> TRUE EXIT THEN
    R> cdr
  REPEAT
  DROP 2DROP FALSE
;
: search-attr ( a u o -- node true | false )
  acar (search-name)
;
: take-attr ( node a u -- a1 u1 )
  ROT search-attr IF car content EXIT THEN 0.
;
: search-name ( a u o -- node true | false )
  car (search-name)
;
: select ( o a u -- node true | false )
  ROT search-name
;

\ ----------------------------------

: ExactWord ( i*x  a u  wid  -- j*x )
  SEARCH-WORDLIST IF EXECUTE ELSE ABORT THEN
;

\ ----------------------------------

VOCABULARY rules
ALSO rules  GET-CURRENT
CONTEXT @ CONSTANT rules-wid

: apply-rules ( node -- )
  DUP name rules-wid ExactWord
;
: apply-templates ( node -- )
  car ['] apply-rules map
;

\ ----------------------------------
DEFINITIONS

\ ( o -- )

: comment  \ i.e. <!-- text of comment -->
  \ content TYPE CR
  DROP
;
: text \ i.e. text()
  content EVALUATE
;

: root
  apply-templates
;
: def
  DUP S" name" take-attr
  SHEADER ] HIDE
    apply-templates
  POSTPONE ;
;
\ <decide><if> ... </if><else> ... </else></decide>
: decide ( o -- )
  DUP >R S" if" select 0= IF RDROP EXIT THEN
  >R POSTPONE IF  R> apply-templates
  R> S" else" select IF >R POSTPONE ELSE R> apply-templates THEN
  POSTPONE THEN
;
: t ( o -- )  \ <t> some text </t> ( -- a u )
  car content POSTPONE SLITERAL
;
: emit ( o -- )
  t S" TYPE" EVALUATE
;

PREVIOUS SET-CURRENT
\ ----------------------------------

: xinclude ( a u -- )
  XML_READ_DOC DUP >R
  XML_DOC_ROOT apply-templates
  R> DROP \ XML_FREE_DOC
;

\EOF  \ example:
S" test1.f.xml" xinclude
test
0  DUP . test2
-2 DUP . test3
