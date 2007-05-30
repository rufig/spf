\ $Id$
\ “ипы данных в списке (строка, список, число) и упрощЄнное задание списка в виде
\ %[ 1 % " hello" %s %[ 3 % 4 % ]% %l 5 % ]%
\ %[ 10 0 DO I % LOOP ]%

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE cons ~ygrek/lib/list/core.f
REQUIRE /TEST ~profit/lib/testing.f

0 CONSTANT _extra-value \ число
1 CONSTANT _extra-list  \ список
2 CONSTANT _extra-str   \ строка

: as-value ( node -- node ) _extra-value OVER list.x2 ! ;
: as-list ( node -- node ) _extra-list OVER list.x2 ! ;
: as-str ( node -- ) _extra-str OVER list.x2 ! ;

: value? ( node -- ? ) list.x2 @ _extra-value = ;
: str? ( node -- ? ) list.x2 @ _extra-str = ;
: list? ( node -- ? ) list.x2 @ _extra-list = ;

: list-what ( node -- n ) list.x2 @ ;

\ -----------------------------------------------------------------------

() VALUE list-of-cur-lists

: cur-list ( -- list ) list-of-cur-lists car ;
: cur-list! ( list -- ) list-of-cur-lists setcar ;
: add-node ( node -- ) cur-list cons cur-list! ;

: %n ( u -- ) vnode as-value add-node ;

\ ƒобавить u как значение в текущий список
: % ( u -- ) %n ;

\ ƒобавить l как элемент-список в текущий список
: %l ( l -- ) vnode as-list add-node ;

\ ƒобавить s как элемент-строку (~ac/lib/str4.f) в текущий список
: %s ( s -- ) vnode as-str add-node ;

\ начать новый список - добавл€ть элементы с помощью %
: lst( ( -- ) list-of-cur-lists () vnode SWAP cons TO list-of-cur-lists ;

\ завершить создание списка
: )lst ( -- list ) list-of-cur-lists DUP cdr TO list-of-cur-lists DUP car SWAP FREE-NODE reverse ;

: %[ lst( ;
: ]% )lst ;
: ]%l ]% %l ;

\ -----------------------------------------------------------------------

WARNING @
WARNING 0!

\ освободить пам€ть занимаемую самим списком, а также данными каждого элемента
\ используетс€ информаци€ о типах
\ дл€ строк - STRFREE
\ дл€ списков - рекурсивно FREE-LIST
\ дл€ value - ничего
: FREE-LIST ( node -- )
   BEGIN
   DUP empty? IF DROP EXIT THEN
   DUP cdr
   SWAP
   DUP list? IF DUP car RECURSE THEN
   DUP str? IF DUP car STRFREE THEN
   FREE-NODE
   AGAIN ;

WARNING !

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES list-core

 6 () vcons 5 SWAP vcons 4 SWAP vcons VALUE list
 lst( 4 % 5 % 6 % )lst VALUE list2

 (( 0 :NONAME car + ; list map -> 15 ))
 (( list length -> 3 ))
 (( 3 list nth empty? -> TRUE ))
 (( 3 list nth -> () ))
 (( 2 list nth car -> 6 ))
 (( 1 list nth car -> 5 ))
 (( 0 list nth car -> 4 ))
 (( 3 list member? -> FALSE ))
 (( 4 list member? -> TRUE ))
 (( 5 list member? -> TRUE ))
 (( 6 list member? -> TRUE ))
 (( 7 list member? -> FALSE ))

 (( 0 list2 nth car -> 4 ))
 (( 1 list2 nth car -> 5 ))
 (( 2 list2 nth car -> 6 ))
 (( list2 length -> 3 ))

 1 list nth car 2 list nth car
 1 list nth setcar 2 list nth setcar
 (( 1 list nth car -> 6 ))
 (( 2 list nth car -> 5 ))
 (( list length -> 3 ))
 (( list car -> 4 ))

 list FREE-LIST
 list2 FREE-LIST

END-TESTCASES
