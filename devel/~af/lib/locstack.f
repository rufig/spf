\ Andrey Filatkin, af@forth.org.ru
\ Локальный стек.
\ опасная либа - заменяет на лету CATCH и THROW

REQUIRE REPLACE-WORD lib/ext/patch.f

DECIMAL
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


: CATCH2
  <SET-EXC-HANDLER>
  LSP@ >R
  SP@ >R  HANDLER @ >R
  RP@ HANDLER !
  EXECUTE
  R> HANDLER !
  RDROP
  RDROP
  0
;
' CATCH2 ' CATCH REPLACE-WORD

: (THROW)2
  DUP
  IF
     DUP 109 = IF DROP EXIT THEN \ broken pipe - обычно не ошибка, а конец входного потока в CGI
     HANDLER @
     DUP
     IF RP!
        R> HANDLER !
        R> SWAP >R
        SP! DROP R>
        R> TO LSP@
     ELSE DROP FATAL-HANDLER THEN
  THEN
;
' (THROW)2 ' (THROW) REPLACE-WORD

: THROW2
  ?DUP
  IF
     DUP 109 = IF DROP EXIT THEN \ broken pipe - обычно не ошибка, а конец входного потока в CGI
     HANDLER @ 
     DUP
     IF RP! 
        R> HANDLER !
        R> SWAP >R
        SP! DROP R>
        R> TO LSP@
     ELSE DROP FATAL-HANDLER THEN
  THEN
; 
' THROW2 ' THROW REPLACE-WORD
