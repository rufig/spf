( str_list.f - реализаци€ простых списков, в частности списков строк.
  DoList, NodeValue, AddNode, FreeList работают с односв€зными
  списками.  аждый элемент списка хранит значение value [€чейка]
  и указатель на следующий элемент. “.е. там не об€зательно строки.
  “олько inList считает, что значение value списка €вл€етс€ 
  адресом xcount-строки.
)

: XCOUNT ( addr -- addr1 u1 )
\ получить строку addr1 u1 из строки со счетчиком addr
\ счетчик - €чейчка, а не байт, в отличие от обычного COUNT
  DUP @ SWAP CELL+ SWAP
;
: NodeValue ( node -- value )
\ получить значение элемента списка
  CELL+ @
;
: NextNode ( node1 -- node2 | 0 )
  @
;
: FirstNode ( list -- node )
  @
;
: DoList ( xt list -- )
\ выполнить токен xt дл€ каждого элемента (node, а не value) списка list
\ xt ( node -- )
  SWAP >R FirstNode
  BEGIN
    DUP
  WHILE
    DUP NextNode SWAP R@ EXECUTE
  REPEAT R> 2DROP
;

: inList ( addr u list -- flag )
\ провер€ет, находитс€ ли строка addr u в списке строк list
  ROT ROT 2>R FirstNode
  BEGIN
    DUP
  WHILE
    DUP NodeValue XCOUNT 2R@ COMPARE 0= IF DROP 2R> 2DROP TRUE EXIT THEN
    NextNode
  REPEAT 2R> 2DROP
;
: FreeNode ( node -- )
  FREE THROW
;
: FreeList ( list -- )
\ освобождает динамическую пам€ть, занимаемую структурами списка.
\ Ќе освобождает пам€ть, выделенную элементам списка, если эти
\ элементы - внешние значени€, например строки.
  ['] FreeNode OVER DoList 0!
;
: AddNode ( value list -- )
\ добавл€ет value в список list
  2 CELLS ALLOCATE THROW >R
  SWAP R@ CELL+ !
  DUP @ R@ !
  R> SWAP !
;
: ReverseList ( list -- )
\ развернуть пор€док элементов в списке на обратный
  DUP >R 0 >R RP@ >R
  FirstNode
  BEGIN
    DUP
  WHILE
    DUP NextNode SWAP DUP NodeValue R@ AddNode FreeNode
  REPEAT DROP
  RDROP R> R> !
;