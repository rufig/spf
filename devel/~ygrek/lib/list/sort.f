\ $Id$
\ Сортировка списка 
\ list-sort ( node xt -- )
\ xt: ( node1-car node2-car -- ? ) \ задаёт порядок

REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE setcar ~ygrek/lib/list/core.f
REQUIRE { lib/ext/locals.f

\ write.f

MODULE: voc_list_sort

USER-VECT list_compare

: merge ( l1 l2 -- l )  
   { l1 l2 | head start -- }
   \ l1 write-list l2 write-list CR
   l1 car l2 car list_compare IF l1 DUP cdr -> l1 ELSE l2 DUP cdr -> l2 THEN DUP TO start TO head
   BEGIN
    l1 empty? IF head l2 LINK-NODE start EXIT THEN
    l2 empty? IF head l1 LINK-NODE start EXIT THEN
    l1 car l2 car list_compare IF l1 DUP cdr -> l1 ELSE l2 DUP cdr -> l2 THEN head OVER LINK-NODE -> head
   AGAIN
  ;

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
   \ DUP write-list CR 
   ;

EXPORT

: COPY-NODE ( n1 n2 -- ) /NODE MOVE ;

: list-sort ( node xt -- )
\ xt: ( node[i]-car node[j]-car -- ? )
   TO list_compare
   { orig | lst prev [ /NODE ] tmp }
   orig empty? IF EXIT THEN
   orig orig length merge-sort -> lst
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
   ( ? ) IF orig ELSE prev THEN lst LINK-NODE
   ;

;MODULE

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE write-list ~ygrek/lib/list/write.f
REQUIRE equal? ~ygrek/lib/list/more.f
REQUIRE GENRANDMAX  ~ygrek/lib/neilbawd/mersenne.f

TESTCASES list-sort

WINAPI: GetTickCount KERNEL32.DLL

: generate
   GetTickCount SGENRAND
   %[ 1000 0 DO 1000 GENRANDMAX % LOOP ]% ;

: check { | u -- ? }
   -1 TO u
   BEGIN
    DUP empty? 0= 
   WHILE
    DUP car DUP u < IF 2DROP FALSE EXIT THEN
                TO u
    cdr
   REPEAT DROP TRUE ;

: (test) generate ( DUP CR write-list) DUP ['] < list-sort ( DUP CR write-list) DUP check SWAP FREE-LIST ;
: test TRUE SWAP 0 DO (test) AND LOOP ;

\ fuzz
(( 100 test -> TRUE ))

\ corner cases
(( %[ ]% ' ABORT list-sort -> ))
(( %[ 1 % ]% DUP ' ABORT list-sort %[ 1 % ]%     2DUP equal? SWAP FREE-LIST SWAP FREE-LIST -> TRUE ))
(( %[ 1 % 2 % ]% DUP ' < list-sort %[ 1 % 2 % ]% 2DUP equal? SWAP FREE-LIST SWAP FREE-LIST -> TRUE ))
(( %[ 1 % 2 % ]% DUP ' > list-sort %[ 2 % 1 % ]% 2DUP equal? SWAP FREE-LIST SWAP FREE-LIST -> TRUE ))

END-TESTCASES

