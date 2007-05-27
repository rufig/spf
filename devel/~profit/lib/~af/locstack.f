\ См. ~af/lib/locstack.f
\ Только убраны опасные игры с CATCH/THROW

REQUIRE /TEST ~profit/lib/testing.f

USER-VALUE LSP@
USER-CREATE S-LSP  64 CELLS USER-ALLOT
: LS-INIT S-LSP TO LSP@ ;
LS-INIT
..: AT-THREAD-STARTING LS-INIT ;..

: +LSP ( -- )    \ Добавить уровень
  LSP@ CELL+ TO LSP@ ;

: -LSP ( -- )    \ Убрать уровень
  LSP@ 1 CELLS - TO LSP@ ;

: >L ( n -- ) ( l: -- n ) \ перенести число со стека данных на локальный стек
  LSP@ ! +LSP ;

: L> ( -- n ) ( l: n -- ) \ перенести число с локального стека на стек данных
  -LSP LSP@ @ ;

: L@ ( -- n ) \ копирует верхнее число с локального стека на стек данных
  LSP@ 1 CELLS - @ ;

: LPICK ( n1 -- n2)
  LSP@ SWAP 1+ CELLS - @ ;

: LDROP ( l: n -- )  -LSP ;

: 2>L ( x1 x2 -- ) ( l: -- x1 x2 ) \ копирует два числа на лок. стек
  SWAP >L >L ;

: 2L> ( -- x1 x2 ) ( l: x1 x2 -- )
  L> L> SWAP ;

: 2L@ ( -- x1 x2 )
  1 LPICK L@ ;

/TEST
$> 1 >L  2 >L  L> . L> .