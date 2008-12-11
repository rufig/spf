\ $Id$
\ Ещё одна либа для списков
\ Основной элемент -- cons pair -- пара CELL'ов : car с данными и cdr со связью

REQUIRE WORDLIST-NAMED ~pinka/spf/compiler/native-wordlist.f
REQUIRE ALSO! ~pinka/lib/ext/basics.f

S" list" WORDLIST-NAMED DROP

list ALSO!
GET-CURRENT DEFINITIONS

\ элемент списка
0
CELL -- node.car \ ячейка-данные
CELL -- node.cdr \ связь
CONSTANT /NODE

\ создать новый элемент
: NEW-NODE ( -- node )
    /NODE ALLOCATE THROW
    DUP /NODE ERASE
;

\ освободить память занимаемую элементом списка
: FREE-NODE ( node -- ) FREE THROW ;

\ установить связь node1->node2
: LINK-NODE ( node1 node2 -- ) SWAP node.cdr ! ;

\ создать новый элемент списка с данными val
: node ( val -- node ) NEW-NODE TUCK node.car ! ;

\ nil или () - пустой элемент - указывает сам на себя - конец списка
HERE /NODE ALLOT CONSTANT nil
nil CONSTANT ()
() () LINK-NODE

\ TRUE - элемент пуст, нет перехода
\ FALSE - иначе
: empty? ( node -- ? ) () = ;

\ перейти к следующему элементу в списке после элемента node1
: cdr ( node1 -- node2 ) node.cdr @ ;

\ содержимое ячейки данных элемента node
: car ( node -- val ) node.car @ ;

\ установить данные ячейки
: setcar ( val node -- ) DUP empty? IF 2DROP EXIT THEN node.car ! ;

\ сокращения :)
: cddr cdr cdr ;
: cdddr cdr cdr cdr ;
: cdar cdr car ;
: cddar cdr cdr car ;

\ пройти по цепочке элементов до последнего - указывающего на ()
: end ( node -- node2 )
   BEGIN
   DUP cdr empty? IF EXIT THEN
   cdr
   AGAIN ;

\ Добавить элемент в начало списка и вернуть получившийся список
\ node1->node2
: cons-node ( node1 node2 -- node1 ) OVER SWAP LINK-NODE ;

\ node1(value)->node
: cons ( value node -- node1 ) SWAP node SWAP cons-node ;

\ Присоединить весь список node1 в начало списка node2
: concat ( node1 node2 -- node )
   OVER empty? IF NIP EXIT THEN
   OVER end SWAP LINK-NODE ;

\ Получить n-ый элемент списка, прямым проходом
: nth ( n node -- node ) SWAP 0 ?DO cdr LOOP ;

\ получить длину списка - прямым проходом до конца списка
: length ( node -- n )
   0 >R
   BEGIN
    DUP empty? IF DROP R> EXIT THEN
    cdr
    RP@ 1+!
   AGAIN ;

\ освободить память занятую списком
: free ( node -- )
   BEGIN
    DUP empty? IF DROP EXIT THEN
    DUP cdr
    SWAP FREE-NODE
   AGAIN ;

: append-node ( node1 node2 -- node ) 
  DUP empty? IF 
    DROP DUP () LINK-NODE 
  ELSE 
    TUCK end OVER LINK-NODE () LINK-NODE 
  THEN ;

\ добавить val в конец списка node2 (перед пустым элементом)
\ node2->...->node(val)->nil
: append ( val node2 -- node ) SWAP node SWAP append-node ;

\ развернуть список в обратную сторону
: reverse ( node -- node1 )
   () >R
   BEGIN
    DUP empty? 0=
   WHILE
    DUP cdr
    SWAP
    R> cons-node >R
   REPEAT
   DROP R> ;

SET-CURRENT PREVIOUS
