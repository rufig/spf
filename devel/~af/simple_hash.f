\ Либа для работы с массивом строк. Для поиска строки в массиве
\ используется ее хэш. Каждой строке может быть сопоставлено число.
\ Создание массива - n_size ListCreate, где n_size - размер хэш-таблицы.
\ В либе используется свой менеджер памяти, в связи с чем длина одной строки
\ должна быть не больше чем n_size*4*4.
\ Andrey Filatkin, 2002, af@forth.org.ru


REQUIRE [IF]   lib\include\tools.f

0
4 -- ListNodeKey \ строка
4 -- ListNodeVal \ число
4 -- ListNodeNext \ ссылка на следующий узел с тем же хэшем
CONSTANT ListNodeSizeS

0
4 -- ListRootSize
4 -- ListRootTbl
4 -- ListRootIter_index
4 -- ListRootIter_next
4 -- ListRootItems
4 -- ListPoolMem
4 -- ListPoolPoint
4 -- ListPoolMax
CONSTANT ListRootSizeS

VERSION 400000 < [IF]
  REQUIRE HASH devel\~day\common\hash.f
  : HashCode ( addr u list -- hash ) >R HASH ABS R> @ MOD ;
[ELSE]
  : HashCode ( addr u list -- hash )  @ HASH ;
[THEN]

: ListAllocate ( list size -- addr )
  OVER DUP ListPoolMax @ SWAP ListPoolPoint @ -
  OVER < IF
    OVER DUP >R
    DUP ListPoolMax @ SWAP ListPoolMem @ - DUP ALLOCATE THROW
    R@ ListPoolMem @ OVER !
    DUP R@ ListPoolMem !
    DUP CELL+ R@ ListPoolPoint !
    + R> ListPoolMax !
  THEN
  SWAP ListPoolPoint DUP @ ROT ROT +!
;
: NodeCreate ( addr_key u_key list -- node )
  DUP ListNodeSizeS ListAllocate >R
  OVER 1+ ListAllocate DUP >R
  2DUP C!
  1+ SWAP MOVE
  R> R> SWAP OVER !
;
: ListCreate ( size -- list )
  ListRootSizeS ALLOCATE THROW >R
  DUP R@ ListRootSize !
  ALIGN-BYTES @ 1024 ALIGN-BYTES !
  OVER 4 * CELLS ALIGNED
  SWAP ALIGN-BYTES !
  DUP CELL+ ALLOCATE THROW DUP 0!
  DUP R@ ListPoolMem !
  CELL+ DUP R@ ListPoolPoint !
  + R@ ListPoolMax !
  CELLS ALLOCATE THROW R@ ListRootTbl !
  R>
;
: ListDestroy ( list --)
  DUP ListPoolMem @
  BEGIN ?DUP WHILE
    DUP @ SWAP FREE THROW
  REPEAT
  DUP ListRootTbl @ FREE THROW
  FREE THROW
;
: AddListItem ( addr u prev list -- node)
  DUP ListRootItems 1+!
  SWAP >R NodeCreate DUP R> !
;
: AddNode ( addr_key u_key list -- node )
  >R 2DUP
  R@ HashCode CELLS
  R@ ListRootTbl @ + DUP @
  ?DUP IF
    NIP DUP >R BEGIN WHILE
      R@ @ COUNT 2OVER COMPARE
      IF R> ListNodeNext DUP @ ?DUP
        IF >R ELSE R> AddListItem FALSE THEN
      ELSE
        2DROP R> RDROP FALSE
      THEN
    REPEAT
  ELSE R> AddListItem
  THEN
;
: FindNode ( addr_key u_key list -- node )
  >R 2DUP
  R@ HashCode CELLS
  R> ListRootTbl @ + @
  DUP BEGIN WHILE
    DUP >R @ COUNT
    2OVER COMPARE
    IF R> ListNodeNext @ DUP
    ELSE R> FALSE
    THEN
  REPEAT
  NIP NIP
;

\ Hash Table iterator data/functions
: NextNode ( list -- node)
  DUP ListRootIter_next @
  ?DUP IF
    DUP ListNodeNext @
    ROT ListRootIter_next !
  ELSE
    DUP ListRootTbl @
    OVER @ CELLS +
    OVER ListRootIter_index @
    ?DO
      I @ ?DUP IF
        2DUP ListNodeNext @
        SWAP ListRootIter_next !
        SWAP ListRootIter_index I CELL+ SWAP !
        UNLOOP EXIT
      THEN
    CELL +LOOP
    DUP ListRootTbl @
    OVER ListRootSize @ +
    SWAP ListRootIter_index !
    0
  THEN
;
: FirstNode ( list -- node)
  DUP ListRootTbl @ OVER ListRootIter_index !
  DUP ListRootIter_next 0!
  NextNode
;
: ListCount ( list -- n)  ListRootItems @ ;
