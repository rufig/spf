\ однонаправленный список.
\ list+  - не распределяет память, а Только связывает.

\ 08.07.2000  Ruv
\ 14.Apr.2001
\   изменил семантику  List-ForEach - xt не оставляет flag
\   старую семантику держит ?List-ForEach
\ 18.Dec.2001 Tue 19:25 + List-Count
\ 14.Jan.2002 Mon 05:24
\   * List-ForEach позволяет освобождать список.

( 
 0 \ struct node
 4   -- link
 ... -- body
)

: list+  ( a-elem  hList -- )  \ добавить _узел_ ( node) к списку.
\ hList @  - адрес последнего добавленного элемента.
  >R  R@ @  ?DUP IF  ( a-chnl a-last )
    OVER  !  ( a-chnl )
  THEN ( a-chnl )
  R> !
;

: ?List-ForEach  ( xt hList -- )
\ xt ( node -- flag )  \ продолжать, пока true
    BEGIN
      @ DUP  
    WHILE
        2DUP 2>R SWAP EXECUTE 0= IF RDROP RDROP EXIT THEN 2R>
    REPEAT 2DROP
;

: List-ForEach  ( xt hList -- )
\ xt ( node -- )
    @   BEGIN
    DUP WHILE
    2DUP @ 2>R SWAP EXECUTE 2R>
        REPEAT 2DROP
;
: List-Count ( list -- count )
  0 BEGIN SWAP @ DUP WHILE SWAP 1+ REPEAT DROP
;

:NONAME  . CR ;  ( S: xt )
: .list  ( list -- )  LITERAL  ( :da) SWAP List-ForEach ;

 ( example
VARIABLE hList  0 hList !

HERE 0 ,  hList list+
HERE 0 ,  hList list+
HERE 0 ,  hList list+

\ :NONAME  . .S CR  TRUE ;  hList  List-ForEach

hList .list

\ )
