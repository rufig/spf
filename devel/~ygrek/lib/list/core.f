\ $Id$
\ Ещё одна либа для списков
\ Основной элемент - cons pair, то бишь пара CELL'ов : car с данными и cdr со связью

0
CELL -- list.car
CELL -- list.cdr
CELL -- list.x1
CELL -- list.x2
CONSTANT /NODE

: NEW-NODE ( -- node )
    /NODE ALLOCATE THROW 
    DUP /NODE ERASE 
; 

: FREE-NODE ( node -- ) FREE THROW ;

\ Установить связь node1->node2
: LINK-NODE ( node1 node2 -- ) SWAP list.cdr ! ;

\ создать cons pair с данными
: vnode ( val -- node ) NEW-NODE TUCK list.car ! ;

\ () - пустой элемент - указывает сам на себя - конец списка
NEW-NODE VALUE ()
\ C" <NULL>" () !
() () LINK-NODE

\ TRUE - элемент пуст, нет перехода
\ FALSE - иначе
: empty? ( node -- ? ) () = ;

\ перейти к следующему элементу в списке после элемента node1
: cdr ( node1 -- node2 ) list.cdr @ ;

\ содержимое ячейки данных элемента node
: car ( node -- val ) list.car @ ;

\ установить данные ячейки
: setcar ( val node -- ) DUP empty? IF 2DROP EXIT THEN list.car ! ;

\ сокращения :)
: cddr cdr cdr ;
: cdddr cdr cdr cdr ;
: cdar cdr car ;
: cddar cdr cdr car ;

\ пройти по цепочке элементов до последнего - указывающего на ()
: end ( node -- node2 )
   DUP cdr empty? IF EXIT THEN
   cdr RECURSE ;

\ Добавить элемент в начало списка и вернуть получившийся список 
\ node1->node2
: cons ( node1 node2 -- node1 ) OVER SWAP LINK-NODE ;

\ Применить xt ко всем элементам списка node1
\ xt: ( node -- ) \ xt получает параметром каждый элемент на нетронутом стеке
: map ( xt node1 -- )
   DUP empty? IF 2DROP EXIT THEN
   2DUP 2>R SWAP EXECUTE 
   2R> cdr RECURSE ;

\ Применить xt к данным всех элементов списка node1
\ xt: ( node.car -- ) \ xt получает параметром car ячейку каждого элемента на нетронутом стеке
: mapcar ( xt node -- )
   DUP empty? IF 2DROP EXIT THEN
   2DUP 2>R car SWAP EXECUTE 
   2R> cdr RECURSE ;

\ Получить n-ый элемент списка, прямым проходом
: nth ( n node -- node )
   OVER 0= IF NIP EXIT THEN
   cdr SWAP 1- SWAP
   RECURSE ;

\ получить длину списка - прямым проходом до конца списка
: length ( node -- n )
   DUP empty? IF DROP 0 EXIT THEN
   cdr RECURSE 1+ ;

\ освободить память занятую списком
: FREE-LIST ( node -- ) 
   DUP empty? IF DROP EXIT THEN
   DUP cdr 
   SWAP FREE-NODE 
   RECURSE ;

\ node2->...->node1->nil
: (append) ( node1 node2 -- )
    end OVER LINK-NODE
    () LINK-NODE ;

\ добавить элемент node1 в конец списка node2 (перед пустым элементом)
\ node2->...->node1->nil
: append ( node1 node2 -- node ) DUP empty? IF DROP DUP () LINK-NODE ELSE TUCK (append) THEN ;

\ развернуть список в обратную сторону
: reverse ( node -- node1 )
   () >R
   BEGIN
    DUP empty? 0=
   WHILE
    DUP cdr
    SWAP
    R> cons >R
   REPEAT 
   DROP R> ;

\ Проверка на принадлежность
: member? ( n node -- ? ) 
   BEGIN
    DUP empty? 0=
   WHILE
    2DUP car = IF 2DROP TRUE EXIT THEN
    cdr
   REPEAT 
   2DROP FALSE ;
