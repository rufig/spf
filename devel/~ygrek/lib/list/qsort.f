\ $Id$
\ —ортировка списка
\ "Ѕыстра€" сортировка превращаетс€ в медленную т.к. список адресуетс€ итераци€ми

REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE list ~ygrek/lib/list/core.f

\ nth used! Dumb list iteration. 
\ Thus sorting long lists (more than 1000 elements) is really SLOW 

list ALSO!
GET-CURRENT DEFINITIONS

MODULE: detail

VECT []>[]
VECT []exch[]
VECT []<[]

S" ~pinka/samples/2003/common/QSORT.F" INCLUDED

USER-VALUE list_
USER-VALUE list_compare_xt

: 2nodes ( i j -- lsti lstj )
   list_ nth SWAP 
   list_ nth SWAP ;

: exchange ( i j -- )
   2nodes SWAP
   2DUP car SWAP car
   ( nodej nodei li lj )
   ROT setcar
   SWAP setcar ;

EXPORT

: qsort ( node xt -- )
\ xt: ( node[i]-car node[j]-car -- ? ) ? = -1 if node[i] < node[j]
   OVER empty? IF 2DROP EXIT THEN
   TO list_compare_xt
   TO list_
   LAMBDA{ 2nodes car SWAP car SWAP list_compare_xt EXECUTE } TO []<[] 
   LAMBDA{ 2nodes car SWAP car SWAP list_compare_xt EXECUTE 0= } TO []>[]
   ['] exchange TO []exch[] 
   0 list_ length 1- quick_sort ;

;MODULE

SET-CURRENT PREVIOUS

0 CONSTANT list-qsort

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE GENRANDMAX  ~ygrek/lib/neilbawd/mersenne.f
\ REQUIRE list-write ~ygrek/lib/list/write.f
REQUIRE ms@ lib/include/facil.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE { lib/ext/locals.f

TESTCASES list_qsort

list ALSO!

: generate
   ms@ SGENRAND
   lst( 
    100 0 DO
    100 GENRANDMAX %
    LOOP
   )lst ;

: do-sort ['] < qsort ;

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
\ DUP CR write
DUP do-sort 
\ DUP CR write
    check -> TRUE ))

PREVIOUS

END-TESTCASES

