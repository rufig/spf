\ $Id$
\ Больше операций со списками

REQUIRE lst( ~ygrek/lib/list/ext.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE /TEST ~profit/lib/testing.f

\ Вызвать xt для каждого элемента списка ( параметр - car ячейка)
\ Если xt возвращает 0 - элемент удаляется из списка (память занимаемая самой ячейкой освобождается)
\ Иначе остаётся
\ Возвращается результирующий список
: reduce-this ( xt node1 -- node2 )
  ( xt: node-car -- ? ) \ TRUE - remain, FALSE - free node
   lst(
    BEGIN
     DUP empty? 0= 
    WHILE
     2>R
     2R@ car SWAP EXECUTE IF R> DUP cdr >R add-node 2R> ELSE R> DUP cdr >R FREE-NODE 2R> THEN
    REPEAT
    2DROP
   )lst ;

(

REQUIRE CREATE-VC ~profit/lib/bac4th-closures.f

: S>VC { a u | t -- vc }
   CREATE-VC -> t
   ALSO bac4th-closures 
   a u t VC-COMPILED 
   PREVIOUS 
   t VC-RET, 
   t ;

: list-remove-all { val lst | vc -- lst }
   val S" LITERAL <>" S>VC TO vc
   vc XT-VC lst reduce-this 
   vc DESTROY-VC ;
)

0 VALUE _list-remove-all-val

\ Удалить из списка lst все элементы со значением val
: list-remove-all ( val lst -- lst1 )
   SWAP TO _list-remove-all-val
   LAMBDA{ _list-remove-all-val <> } SWAP 
   reduce-this ;

\ удалить из списка lst все значения-дубликаты
: list-remove-dublicates ( lst -- )
   BEGIN
    DUP empty? 0= 
   WHILE
    DUP car OVER cdr list-remove-all cons
    cdr
   REPEAT DROP ;

\ Вставить элемент node1 в список list после первого элемента
\ list->...->nil
\ list->node1->...->nil
: insert ( node1 list -- )
   >R
   R@ cdr cons
   R> SWAP cons DROP ;

\ Проверка на равенство по значению
: equal? ( node1 node2 -- ? )
   BEGIN
    DUP empty? IF DROP empty? EXIT THEN
    OVER empty? IF 2DROP FALSE EXIT THEN
    OVER list-what OVER list-what <> IF 2DROP FALSE EXIT THEN
    DUP value? IF 2DUP car SWAP car <> IF 2DROP FALSE EXIT THEN THEN
    DUP str? IF 2DUP car STR@ ROT car STR@ COMPARE IF 2DROP FALSE EXIT THEN THEN
    DUP list? IF 2DUP car SWAP car RECURSE 0= IF 2DROP FALSE EXIT THEN THEN 
    cdr SWAP cdr
   AGAIN TRUE ;

\ -----------------------------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE write-list ~ygrek/lib/list/write.f

TESTCASES list-remove-all

lst( 1 % 2 % 4 % 2 % 3 % 4 % 6 % 6 % 2 % )lst VALUE l
CR l write-list
2 l list-remove-all TO l 
CR l write-list
l list-remove-dublicates 
CR l write-list

lst( :NONAME 10 0 DO 2 % LOOP ; EXECUTE )lst DUP CR write-list
DUP list-remove-dublicates
CR write-list

END-TESTCASES

TESTCASES list equal?

 lst( 1 % 2 % " coo zoo " %s lst( " so so" %s 200 % )lst %l 2000 % )lst VALUE l1
 lst( 1 % 2 % " coo zoo " %s lst( " so so" %s 200 % )lst %l 2000 % )lst VALUE l2

 (( l1 l2 equal? -> TRUE ))

END-TESTCASES

\ :NONAME car 3 MOD 0= ; l0 filter CR show-list

\ l1 DUP car . cdr DUP car . cdr DUP car . cdr DUP car . DUP cdr car . DROP
