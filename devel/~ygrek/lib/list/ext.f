REQUIRE cons ~ygrek/lib/list/core.f
REQUIRE /TEST ~profit/lib/testing.f

0 CONSTANT _extra-value
1 CONSTANT _extra-list
2 CONSTANT _extra-str

: as-value _extra-value OVER list.x2 ! ;
: as-list _extra-list OVER list.x2 ! ;
: as-str _extra-str OVER list.x2 ! ;

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

\ Добавить u как значение в текущий список
: % ( u -- ) %n ;

\ Добавить l как элемент-список в текущий список
: %l ( l -- ) vnode as-list add-node ;

\ Добавить s как элемент-строку (~ac/lib/str4.f) в текущий список
: %s ( s -- ) vnode as-str add-node ;

\ начать новый список - добавлять элементы с помощью %
: lst( ( -- ) list-of-cur-lists () vnode SWAP cons TO list-of-cur-lists ;

\ завершить создание списка
: )lst ( -- list ) cur-list list-of-cur-lists cdr TO list-of-cur-lists reverse ;

: %( lst( ; 
: )% )lst ;
: )%l )% %l ;

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

TESTCASES list-core

 6 vnode () cons 5 vnode SWAP cons 4 vnode SWAP cons VALUE list
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

 (( 1 list nth car -> 5 ))
 (( 2 list nth car -> 6 ))
 1 list nth car 2 list nth car 
 1 list nth setcar 2 list nth setcar
 (( 1 list nth car -> 6 ))
 (( 2 list nth car -> 5 ))
 (( list length -> 3 ))
 (( list car -> 4 ))

 list FREE-LIST

END-TESTCASES
