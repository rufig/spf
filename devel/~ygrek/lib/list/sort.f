\ $Id$
\ Сортировка списка 
\ list::sort ( node xt -- )
\ xt: ( v1 v2 -- ? ) \ задаёт порядок

\ S" ~day/lib/memreport.f" INCLUDED
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE list ~ygrek/lib/list/core.f
REQUIRE { lib/ext/locals.f

list ALSO!
GET-CURRENT DEFINITIONS

USER-VALUE list_compare

: merge ( l1 l2 -- l )  
   { l1 l2 | head start -- }
   \ l1 write l2 write CR
   l1 car l2 car list_compare EXECUTE IF l1 DUP cdr -> l1 ELSE l2 DUP cdr -> l2 THEN DUP TO start TO head
   BEGIN
    l1 empty? IF head l2 LINK-NODE start EXIT THEN
    l2 empty? IF head l1 LINK-NODE start EXIT THEN
    l1 car l2 car list_compare EXECUTE IF l1 DUP cdr -> l1 ELSE l2 DUP cdr -> l2 THEN head OVER LINK-NODE -> head
   AGAIN ;

: merge-sort ( node n -- node1 )
\   OVER write-list CR
   DUP 1 = IF DROP DUP () LINK-NODE EXIT THEN
   { | l1 n1 l2 n2 }
   2 /MOD TUCK + -> n1 -> n2
   -> l1
   l1 n1 0 ?DO cdr LOOP -> l2
   l1 n1 RECURSE
   l2 n2 RECURSE
   merge 
   \ DUP write CR 
   ;

: COPY-NODE ( n1 n2 -- ) /NODE MOVE ;

: sort1 ( l1 xt -- l2 )
\ xt: ( node[i]-car node[j]-car -- ? )
   { orig cmp }
   orig empty? IF orig EXIT THEN
   list_compare
   cmp TO list_compare
   orig orig length merge-sort SWAP
   ( list_compare ) TO list_compare ;

: sort { orig xt | lst [ /NODE ] tmp prev -- }
   orig xt sort1 -> lst
   lst orig = IF EXIT THEN
   \ Т.к. голова списка в результате сортировки переместилась, меняем содержимое
   \ ячеек так чтобы вернуть голову на место
   lst lst cdr
   BEGIN
    DUP orig <>
   WHILE
    NIP DUP cdr
   REPEAT
   DROP
   TO prev
   lst cdr orig = ( ? )
   orig tmp COPY-NODE
   lst orig COPY-NODE
   tmp lst COPY-NODE
   ( ? ) IF orig ELSE prev THEN lst LINK-NODE ;

SET-CURRENT PREVIOUS

0 CONSTANT list-sort

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE list-ext ~ygrek/lib/list/ext.f
REQUIRE GENRANDMAX  ~ygrek/lib/neilbawd/mersenne.f
REQUIRE ms@ lib/include/facil.f

TESTCASES list-sort

list ALSO!

ms@ SGENRAND

: generate ( n -- l )
   %[ 0 ?DO 1000 GENRANDMAX % LOOP ]% ;

: check { | u -- ? }
   -1 TO u
   BEGIN
    DUP empty? 0= 
   WHILE
    DUP car DUP u < IF 2DROP FALSE EXIT THEN
                TO u
    cdr
   REPEAT DROP TRUE ;

: (test) 1000 generate 
  ( DUP CR write-list) 
  DUP ['] < sort 
  ( DUP CR write-list) 
  DUP check
  SWAP free ;

: test TRUE SWAP 0 DO (test) AND LOOP ;

\ fuzz
(( 100 test -> TRUE ))

\ corner cases
(( %[ ]% ' ABORT sort -> ))
(( %[ 1 % ]% DUP ' ABORT sort %[ 1 % ]%     2DUP equal0? SWAP free SWAP free -> TRUE ))
(( %[ 1 % 2 % ]% DUP ' < sort %[ 1 % 2 % ]% 2DUP equal0? SWAP free SWAP free -> TRUE ))
(( %[ 1 % 2 % ]% DUP ' > sort %[ 2 % 1 % ]% 2DUP equal0? SWAP free SWAP free -> TRUE ))

\ test reenterability
\ artificial example
:NONAME %[ 10 0 DO 10 generate % LOOP ]% ; EXECUTE VALUE l

: sum-list ( node -- n ) 0 SWAP ['] + iter ;

\ CR l write-list

l :NONAME 
   DUP ['] < sort
   OVER ['] < sort
   sum-list SWAP
   sum-list SWAP
   < ; sort

\ CR l write-list

(( l %[ :NONAME sum-list % ; iter ]%
\  CR DUP ' . iter
   DUP check SWAP free -> TRUE ))

\ negative tests
\ l car end car l car setcar
\ 10000 l car setcar

\ CR l write-list

(( TRUE l :NONAME check AND ; iter -> TRUE ))

\ l ' free iter
\ l free

l ' free free-with
() TO l

\ MemReport

PREVIOUS

END-TESTCASES
