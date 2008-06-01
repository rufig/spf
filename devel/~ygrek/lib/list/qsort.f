\ $Id$
\ —ортировка списка
\ "Ѕыстра€" сортировка превращаетс€ в медленную т.к. список адресуетс€ итераци€ми

REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE setcar ~ygrek/lib/list/core.f

\ nth used! Dumb list iteration. 
\ Thus sorting long lists (more than 1000 elements) is really SLOW 

MODULE: list-quick-sort

VECT []>[]
VECT []exch[]
VECT []<[]

S" ~pinka/samples/2003/common/QSORT.F" INCLUDED

0 VALUE list_
0 VALUE list_compare_xt

: 2nodes-from-sort-list ( i j -- lsti lstj )
   list_ nth SWAP 
   list_ nth SWAP ;

: list_exchange ( i j -- )
   2nodes-from-sort-list SWAP
   2DUP car SWAP car
   ( nodej nodei li lj )
   ROT setcar
   SWAP setcar ;

EXPORT

: list-qsort ( xt node -- )
\ xt: ( node[i]-car node[j]-car -- ? ) ? = -1 if node[i] < node[j]
   DUP empty? IF 2DROP EXIT THEN
   TO list_
   TO list_compare_xt
   LAMBDA{ 2nodes-from-sort-list car SWAP car SWAP list_compare_xt EXECUTE } TO []<[] 
   LAMBDA{ 2nodes-from-sort-list car SWAP car SWAP list_compare_xt EXECUTE 0= } TO []>[]
   ['] list_exchange TO []exch[] 
   0 list_ length 1- quick_sort ;

;MODULE

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE GENRANDMAX  ~ygrek/lib/neilbawd/mersenne.f
REQUIRE write-list ~ygrek/lib/list/write.f

TESTCASES list_sort

WINAPI: GetTickCount KERNEL32.DLL

: generate
   GetTickCount SGENRAND
   lst( 
    100 0 DO
    100 GENRANDMAX %
    LOOP
   )lst ;

: sort ['] < SWAP list-qsort ;

: check { | u -- ? }
   -1 TO u
   BEGIN
    DUP empty? 0= 
   WHILE
    DUP car DUP u < IF 2DROP FALSE EXIT THEN
                TO u
    cdr
   REPEAT DROP TRUE ;

((
generate 
DUP CR write-list
DUP sort 
DUP CR write-list
    check -> TRUE ))

END-TESTCASES

