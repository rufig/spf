\ $Id$

\ »де€ ~yz
\  онтролы размещаютс€ в сетках, которые можно раст€гивать
\ pre alpha

REQUIRE WFL ~day/wfl/wfl.f
NEEDS ~ygrek/lib/list/all.f
NEEDS lib/include/core-ext.f

\ --------------------------

400 CONSTANT GRID_DEFAULT_WIDTH
300 CONSTANT GRID_DEFAULT_HEIGHT

\ --------------------------

: (DO-PRINT-VARIABLE) ( a u addr -- ) -ROT TYPE ."  = " @ . ;

: PRINT: ( "name" -- )
   PARSE-NAME
   2DUP
   POSTPONE SLITERAL
   EVALUATE
   POSTPONE (DO-PRINT-VARIABLE) ; IMMEDIATE

\ --------------------------

CLASS CGridBox

 VAR _h
 VAR _w
 VAR _xspan
 VAR _yspan
 VAR _wmin
 VAR _hmin
 VAR _obj

init:
  20 _h ! 20 _w !
  20 _wmin ! 20 _hmin !
  -1 _xspan ! -1 _yspan !
;

\ выполнить раст€жку по x если €чейка раст€гиваема
: :perform-xspan ( extra -- ) _xspan @ 0= IF DROP 0 THEN _wmin @ + _w ! ;
\ выполнить раст€жку по y если €чейка раст€гиваема
: :perform-yspan ( extra -- ) _yspan @ 0= IF DROP 0 THEN _hmin @ + _h ! ;

: :perform-yspan-upto ( ymax -- ) _hmin @ - 0 MAX :perform-yspan ;

: :print
   PRINT: _wmin
   PRINT: _w
   PRINT: _xspan

   PRINT: _hmin
   PRINT: _h
   PRINT: _yspan
;

: :control! ( ctl-obj -- ) _obj ! ;

: :finalize { x y -- } TRUE _h @ _w @ y x _obj @ => moveWindow ;

;CLASS

\ --------------------------

\ р€д €чеек это тоже одна €чейка
CGridBox SUBCLASS CGridRow

 VAR _cells

init:
  () _cells !
;

: :add ( cell -- ) vnode _cells @ cons _cells ! ;

: traverse-row ( xt -- ) _cells @ mapcar ;

: :xmin ( -- n ) 0 LAMBDA{ => _wmin @ + } traverse-row ;
: :ymin ( -- n ) 0 LAMBDA{ => _hmin @ MAX } traverse-row ;

\ будет ли этот р€д раст€гиватьс€
: :yspan? ( -- ? ) FALSE LAMBDA{ => _yspan @ OR } traverse-row SUPER _yspan @ OR ;

\ число €чеек которые можно раст€нуть по горизонтали
: :xspan-count ( -- n ) 0 LAMBDA{ => _xspan @ 1 AND + } traverse-row ;

: :xformat { given | extra cell xspan-extra -- }
   \ сколько нам дали места минус то сколько нам надо
   given :xmin - 0 MAX -> extra
   :xspan-count DUP 0= IF DROP 0 TO xspan-extra ELSE extra SWAP / TO xspan-extra THEN

   \ раздадим xspan-extra каждой клетке
   \ те у которых xspan включен займут его
   _cells @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car xspan-extra SWAP :: CGridBox.:perform-xspan
    cdr
   REPEAT
   DROP

   \ сколько осталось после раздачи
   \ если например :xspan-count был 0 то всЄ лишнее место ещЄ не распределно
   0 LAMBDA{ => _w @ + } traverse-row DUP SUPER _wmin ! given - 0 MAX TO extra

   \ всЄ нераспределЄнное место отдаем в xspan этого р€да как одной клетки
   extra SUPER :perform-xspan

   \ вполне возможно что xspan выключен и тогда место просто лишнее - resize-ить нельз€
;

: :yformat { given | extra -- }
   \ дать каждой €чейке раст€нутьс€ не более чем на given
   _cells @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car given SWAP :: CGridBox.:perform-yspan-upto
    cdr
   REPEAT
   DROP

   \ сколько места осталось нераспределЄнным?
   0 LAMBDA{ => _h @ MAX } traverse-row DUP SUPER _hmin ! given - 0 MAX TO extra

   \ выдать в р€д-клетку
   extra SUPER :perform-yspan
;

: :print ( -- )
   CR ." CGridRow :print"
   CR ." Row: " SUPER :print
   CR ." Cells : "
   LAMBDA{ CR => :print } traverse-row
;

: :draw { | x }
   0 -> x
   _cells @
   BEGIN
    DUP empty? 0=
   WHILE
    x 3 .R SPACE
    DUP car => _w @ x + -> x
    cdr
   REPEAT
   DROP
   x 3 .R SPACE
\   SUPER _w @ 3 .R SPACE
;

: :finalize { y | x -- }
   0 -> x
   _cells @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car x y ROT => :finalize
    DUP car => _w @ x + -> x
    cdr
   REPEAT
   DROP
;

;CLASS

\ --------------------------

CGridBox SUBCLASS CGrid

 VAR _rows

init:
  GRID_DEFAULT_WIDTH SUPER _w !
  GRID_DEFAULT_HEIGHT SUPER _h !
  () _rows ! ;

: traverse-grid _rows @ mapcar ;

: :xmin ( -- n ) 0 LAMBDA{ => :xmin MAX } traverse-grid ;
: :ymin ( -- n ) 0 LAMBDA{ => :ymin + } traverse-grid ;

\ число р€дов которые можно раст€нуть по вертикали
: :yspan-count ( -- n ) 0 LAMBDA{ => :yspan? 1 AND + } traverse-grid ;

: :format { x y | extra yspan-extra -- }

   y :ymin - 0 MAX -> extra
   :yspan-count DUP 0= IF DROP 0 TO yspan-extra ELSE extra SWAP / TO yspan-extra THEN

   \ раздадим yspan-extra каждому р€ду
   \ те у которых yspan включен займут его
   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car DUP :: CGridRow.:ymin yspan-extra + SWAP :: CGridRow.:yformat
    cdr
   REPEAT
   DROP

   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car x SWAP :: CGridRow.:xformat
    cdr
   REPEAT
   DROP

   0 LAMBDA{ => _w @ MAX } traverse-grid SUPER _w !
   0 LAMBDA{ => _h @ + } traverse-grid SUPER _h !
;

: :add ( row -- ) 0 OVER => :xformat 0 OVER => :yformat vnode _rows @ cons _rows ! ;

: :print ( -- )
   CR ." CGrid :print"
   CR ." Grid: " SUPER :print
   CR ." Rows : "
   LAMBDA{ CR => :print } traverse-grid
;

: :draw { | y }
   0 -> y
   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    CR y 3 .R SPACE ." --->"
    DUP car => :draw
    DUP car => _h @ y + -> y
    cdr
   REPEAT
   DROP
;

: :finalize { | y }
   0 -> y
   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car y SWAP => :finalize
    DUP car => _h @ y + -> y
    cdr
   REPEAT
   DROP
;

;CLASS

\ -----------------------------------------------------------------------

\ макросы

\ пам€ть, ресурсы - всЄ течет

\ MODULE: WFL

0 VALUE box \ текуща€ €чейке
0 VALUE ctl  \ контрол в текущей €чейке
0 VALUE row  \ текущий р€д
0 VALUE grid \ текуща€ сетка

\ создать новую клетку в текущем р€ду и поместить в неЄ контрол класса class
: put ( class -- )
   NewObj TO ctl
   CGridBox NewObj TO box
   0 SELF ctl => create DROP
   ctl box => :control!
   box row => :add
;

\ : put- ( class -- obj ) put ctl ;

\ начать новый р€д клеток
: ROW ( -- )
  CGridRow NewObj TO row
  row grid => :add
;

\ начать новую таблицу
: GRID
   CGrid NewObj TO grid
   ROW ;

\ закончить таблицу
: ;GRID grid ;

: xspan! box :: CGridBox._xspan ! ;

\ включить раст€жение клетки по ширине
: +xspan ( -- ) TRUE xspan! ;
\ выключить раст€жение клетки по ширине
: -xspan ( -- ) FALSE xspan! ;

: yspan! box :: CGridBox._yspan ! ;

\ выключить раст€жение клетки по высоте
: +yspan ( -- ) TRUE yspan! ;
\ выключить раст€жение клетки по высоте
: -yspan ( -- ) FALSE yspan! ;

\ установить обработчик событи€
\ xt: ( obj -- )
: -command! ( xt -- ) ctl => setHandler ;

: -xmin! ( u -- ) box :: CGridBox._wmin ! ;
: -ymin! ( u -- ) box :: CGridBox._hmin ! ;

\ ;MODULE

\ -----------------------------------------------------------------------
