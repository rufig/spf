\ 29.Jun.2002 Sat 23:34 created

REQUIRE list+ ~pinka\lib\list.f

: list-bottom ( hlist -- node )  \ by viewing - последнее при просмотре списка
  BEGIN DUP @ DUP WHILE NIP REPEAT DROP \ node=hlist, если список пуст
;
: catanation-lists ( h1 h2 -- ) \ h2 ->    h1 h2 <- top
  list-bottom SWAP @ SWAP !
  ( если h1 и h2 пересекаются, возможен цикл )
;
\ equivalent to  h2 list-bottom h1 list+

: list+s ( i*x i list -- ) \ add i*x nodes
  >R BEGIN DUP WHILE 1- SWAP R@ list+ REPEAT DROP
  RDROP
;
: @list ( list -- i*x i )
  0 SWAP @
  BEGIN DUP WHILE SWAP 1+ OVER @ REPEAT DROP
;
: reverse-list-small ( list -- ) \ можно и для статических узлов
  DUP >R @list R> SWAP
  BEGIN DUP WHILE >R OVER SWAP ! R> 1- REPEAT
  DROP 0!
;
: reverse-list ( list -- )
  DUP >R
  0 SWAP @ ( prev next )
  BEGIN DUP WHILE
    DUP DUP @
    2SWAP !
  REPEAT ( prev 0 )
  DROP R> !
  \ так надежней, т.к. не всякий список на стек выложишь ;)
;
2 CELLS CONSTANT /simple_list-node
: list_allot+ ( value hlist -- )
  >R  HERE /simple_list-node ALLOT DUP >R
  CELL+ !  R> R> list+
;
: -list_allot+  ( value hlist -- )
  HERE SWAP list-bottom !  \ добавляю узел вниз
  0 ,  ,
;

: list_alloc+ ( value hlist -- )
  >R  /simple_list-node ALLOCATE THROW DUP >R
  CELL+ !  R> R> list+
;
: dealloc-list ( hlist -- )
  DUP @ SWAP 0!
  BEGIN DUP WHILE DUP @ SWAP FREE THROW REPEAT DROP
;
: list-each_value  ( xt hList -- )
\ xt ( value -- )
  @ BEGIN DUP WHILE 2DUP @ 2>R CELL+ @ SWAP EXECUTE 2R> REPEAT 2DROP
;
: for-list_values ( hList xt -- )
\ xt ( value -- )
  SWAP
  @ BEGIN  DUP WHILE 2DUP @ 2>R CELL+ @ SWAP EXECUTE 2R> REPEAT 2DROP
;
: exist-list_value ( value hlist -- flag )
   BEGIN @ DUP WHILE 2DUP CELL+ @ = UNTIL TRUE ELSE FALSE THEN NIP NIP
;

: list_entry-node ( value hlist -- node )
  SWAP >R
  BEGIN @ DUP WHILE DUP CELL+ @ R@ = UNTIL THEN RDROP
  \ node=0, если не найдено
;


USER-VALUE ItEntry
USER-VALUE ItNode

: enum-list ( xt hList -- )
\ xt ( -- )
  ItNode ItEntry 2>R
  @ BEGIN  DUP WHILE 2DUP @ 2>R DUP TO ItNode CELL+ @ TO ItEntry EXECUTE 2R> REPEAT 2DROP
  2R> TO ItEntry TO ItNode
;

USER-VALUE -HoldEnum? \ не остановить итерацию?

: HoldEnum FALSE TO -HoldEnum? ;

: ?enum-list ( xt hList -- )
\ xt ( -- )
  -HoldEnum? >R  TRUE TO -HoldEnum?
  ItNode ItEntry 2>R
  @ BEGIN ( xt node )
  -HoldEnum? WHILE
    DUP WHILE 2DUP @ 2>R DUP TO ItNode CELL+ @ TO ItEntry EXECUTE 2R> REPEAT 
  THEN 2DROP
  2R> TO ItEntry TO ItNode
  R> TO -HoldEnum?
;

: node-entry ( node -- value )
\  CELL+ @
  S" CELL+ @" EVALUATE
; IMMEDIATE
: list-top  ( hlist -- node )
  S" @"       EVALUATE
; IMMEDIATE
