\ $Id$
\ Конструирование списка :
\ %[ 1 % 2 % 3 % 4 % 5 % ]%
\ %[ 10 0 DO I % LOOP ]%

REQUIRE list ~ygrek/lib/list/core.f
REQUIRE /TEST ~profit/lib/testing.f

list ALSO!
GET-CURRENT DEFINITIONS

\ -----------------------------------------------------------------------

USER-VALUE list-of-cur-lists
..: AT-THREAD-STARTING () TO list-of-cur-lists ;..
() TO list-of-cur-lists

: cur-list ( -- list ) list-of-cur-lists car ;
: cur-list! ( list -- ) list-of-cur-lists setcar ;

SET-CURRENT 

\ экспортируются

\ Добавить значение в текущий список
: % ( u -- ) cur-list cons cur-list! ;

\ начать новый список - добавлять элементы словом %
: lst( ( -- ) () list-of-cur-lists cons TO list-of-cur-lists ;

\ завершить создание списка
: )lst ( -- list ) list-of-cur-lists DUP cdr TO list-of-cur-lists DUP car SWAP FREE-NODE reverse ;

: %[ lst( ;
: ]% )lst ;

\ : ~{ lst( ;
\ : }~ )lst ;
\ : !! % ;

PREVIOUS

0 CONSTANT list-make

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES list-core

 list ALSO!

 6 () cons 5 SWAP cons 4 SWAP cons VALUE l1
 %[ 4 % 5 % 6 % ]% VALUE l2

 (( l1 length -> 3 ))
 (( 3 l1 nth empty? -> TRUE ))
 (( 3 l1 nth -> () ))
 (( 2 l1 nth car -> 6 ))
 (( 1 l1 nth car -> 5 ))
 (( 0 l1 nth car -> 4 ))
\ (( 3 l1 member? -> FALSE ))
\ (( 4 l1 member? -> TRUE ))
\ (( 5 l1 member? -> TRUE ))
\ (( 6 l1 member? -> TRUE ))
\ (( 7 l1 member? -> FALSE ))

 (( 0 l2 nth car -> 4 ))
 (( 1 l2 nth car -> 5 ))
 (( 2 l2 nth car -> 6 ))
 (( l2 length -> 3 ))

 1 l1 nth car 2 l1 nth car
 1 l1 nth setcar 2 l1 nth setcar
 (( 1 l1 nth car -> 6 ))
 (( 2 l1 nth car -> 5 ))
 (( l1 length -> 3 ))
 (( l1 car -> 4 ))

 l1 free
 l2 free

 PREVIOUS

END-TESTCASES

