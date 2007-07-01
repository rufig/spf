\ $Id$
\ Ещё одна либа для списков
\ Основной элемент - cons pair, то бишь пара CELL'ов : car с данными и cdr со связью

\ элемент списка
0
CELL -- list.car \ ячейка-данные
CELL -- list.cdr \ связь
CELL -- list.x1  \ reserved
CELL -- list.x2  \ reserved
CONSTANT /NODE

\ создать новый элемент
: NEW-NODE ( -- node )
    /NODE ALLOCATE THROW
    DUP /NODE ERASE
;

\ освободить память занимаемую элементом списка
: FREE-NODE ( node -- ) FREE THROW ;

\ установить связь node1->node2
: LINK-NODE ( node1 node2 -- ) SWAP list.cdr ! ;

\ создать новый элемент списка с данными val
: vnode ( val -- node ) NEW-NODE TUCK list.car ! ;

\ () - пустой элемент - указывает сам на себя - конец списка
HERE /NODE ALLOT VALUE ()
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
   BEGIN
   DUP cdr empty? IF EXIT THEN
   cdr
   AGAIN ;

\ Добавить элемент в начало списка и вернуть получившийся список
\ node1->node2
: cons ( node1 node2 -- node1 ) OVER SWAP LINK-NODE ;

\ node1(value)->node
: vcons ( value node -- node1 ) SWAP vnode SWAP cons ;

\ Присоединить весь список node1 в начало списка node2
: concat-list ( node1 node2 -- node )
   OVER empty? IF NIP EXIT THEN
   OVER end SWAP LINK-NODE ;

\ Применить xt ко всем элементам списка node1
\ xt: ( node -- ) \ xt получает параметром каждый элемент на нетронутом стеке
: map ( xt node1 -- )
   2>R
   BEGIN
    R@ empty? IF RDROP RDROP EXIT THEN
    2R@ SWAP EXECUTE
    R> cdr >R
   AGAIN ;

\ Применить xt к данным всех элементов списка node1
\ xt: ( node.car -- ) \ xt получает параметром car ячейку каждого элемента на нетронутом стеке
: mapcar ( xt node -- )
   2>R
   BEGIN
    R@ empty? IF RDROP RDROP EXIT THEN
    2R@ car SWAP EXECUTE
    R> cdr >R
   AGAIN ;

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
: FREE-LIST ( node -- )
   BEGIN
    DUP empty? IF DROP EXIT THEN
    DUP cdr
    SWAP FREE-NODE
   AGAIN ;

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
