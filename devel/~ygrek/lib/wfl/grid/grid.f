\ $Id$

\ Идея ~yz
\ Контролы размещаются в сетках, которые можно растягивать
\ pre alpha

REQUIRE WFL ~day/wfl/wfl.f
NEEDS ~ygrek/lib/list/all.f
NEEDS lib/include/core-ext.f

\ -----------------------------------------------------------------------

: (DO-PRINT-VARIABLE) ( a u addr -- ) -ROT TYPE ."  = " @ . ;

: PRINT: ( "name" -- )
   PARSE-NAME
   2DUP
   POSTPONE SLITERAL
   EVALUATE
   POSTPONE (DO-PRINT-VARIABLE) ; IMMEDIATE

\ -----------------------------------------------------------------------

\ 20 VALUE def-h
\ 20 VALUE def-w
30 VALUE def-hmin
50 VALUE def-wmin
TRUE VALUE def-xspan
TRUE VALUE def-yspan

\ -----------------------------------------------------------------------

\ Базовый элемент сетки - ячейка
CLASS CGridBox

 VAR _h     \ актуальная высота
 VAR _w     \ актуальная ширина
 VAR _yspan \ флаг - расятжение по высоте
 VAR _xspan \ флаг - растяжение по ширине
 VAR _hmin  \ минимальная высота
 VAR _wmin  \ минимальная ширина
 VAR _obj   \ обьект-контрол

init:
  0 _h !
  0 _w !
  0 _obj !
  def-wmin _wmin !
  def-hmin _hmin !
  def-xspan _xspan !
  def-yspan _yspan !
;

\ выполнить растяжку по x если ячейка растягиваема
: :xformat ( given -- ) _xspan @ 0= IF DROP 0 THEN _wmin @ MAX _w ! ;
\ выполнить растяжку по y если ячейка растягиваема
: :yformat ( given -- ) _yspan @ 0= IF DROP 0 THEN _hmin @ MAX _h ! ;

: :xmin _wmin @ ;
: :ymin _hmin @ ;

\ : :yformat ( u -- ) SELF => :ymin - 0 MAX SELF => :yformat-extra ;
\ : :xformat ( u -- ) SELF => :xmin - 0 MAX SELF => :xformat-extra ;

: :yspan? _yspan @ ;
: :xspan? _xspan @ ;

: :print
   PRINT: _wmin
   PRINT: _w
   PRINT: _xspan

   PRINT: _hmin
   PRINT: _h
   PRINT: _yspan
;

: :control! ( ctl-obj -- ) _obj ! ;

\ передать информацию о расположении и размере ячейки контролу с тем чтобы он себя отрисовал
: :finalize { x y -- } _obj @ 0= IF EXIT THEN TRUE _h @ _w @ y x _obj @ => moveWindow ;

;CLASS

\ --------------------------

\ ряд ячеек как одна ячейка
CGridBox SUBCLASS CGridRow

 VAR _cells \ список ячеек этого ряда

init:
  () _cells !
;

: :add ( cell -- ) vnode _cells @ cons _cells ! ;

: traverse-row ( xt -- ) _cells @ mapcar ;

\ минимальная ширина ряда как сумма минимальной ширины каждой ячейки
: :xmin ( -- n ) 0 LAMBDA{ => :xmin + } traverse-row ;
\ минимальная высота ряда как сумма минимальной высоты каждой ячейки
: :ymin ( -- n ) 0 LAMBDA{ => :ymin MAX } traverse-row ;

\ будет ли этот ряд растягиваться
: :yspan? ( -- ? ) FALSE LAMBDA{ => :yspan? OR } traverse-row SUPER :yspan? OR ;

\ число ячеек которые можно растянуть по горизонтали
: :xspan-count ( -- n ) 0 LAMBDA{ => :xspan? IF 1 + THEN } traverse-row ;

: :xformat { given | extra -- }
   :xspan-count \ если у нас есть внутри потребители - отдаём всё им
   DUP
   IF
    given :xmin - 0 MAX SWAP / -> extra

    \ раздадим xspan-extra каждой клетке
    \ те у которых xspan включен займут его
    _cells @
    BEGIN
     DUP empty? 0=
    WHILE
     DUP car DUP => :xmin extra + SWAP => :xformat
     cdr
    REPEAT
    DROP
   ELSE \ иначе забираем всё себе
    DROP
    given SUPER :xformat
   THEN

   0 LAMBDA{ => _w @ + } traverse-row
   \ SUPER _wmin !
   given MAX SUPER :xformat
;

: :yformat { given -- }
   \ дать каждой ячейке растянуться не более чем на given
   _cells @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car given SWAP => :yformat
    cdr
   REPEAT
   DROP

   \ сколько места осталось нераспределённым?
   0 LAMBDA{ => _h @ MAX } traverse-row given MAX SUPER :yformat
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

: :finalize { x y -- }
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

\ Сетка - это список рядов
\ и одновременно также одна ячейка
CGridBox SUBCLASS CGrid

 VAR _rows

init:
  () _rows ! ;

: traverse-grid ( xt -- ) _rows @ mapcar ;

: :xmin ( -- n ) 0 LAMBDA{ => :xmin MAX } traverse-grid ;
: :ymin ( -- n ) 0 LAMBDA{ => :ymin + } traverse-grid ;

\ число рядов которые можно растянуть по вертикали
: :yspan-count ( -- n ) 0 LAMBDA{ => :yspan? 1 AND + } traverse-grid ;

: :xformat { given -- }

   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car given SWAP => :xformat
    cdr
   REPEAT
   DROP

   \ считаем ширину как максимум из ширины каждого ряда
   0 LAMBDA{ => _w @ MAX } traverse-grid SUPER _w !
;

: :yformat { given | extra -- }

   \ будем раздавать каждому +yspan ряду поровну
   :yspan-count
   DUP
   IF
    given :ymin - 0 MAX SWAP / -> extra

    \ раздадим extra каждому ряду
    \ те у которых yspan включен займут его
    _rows @
    BEGIN
     DUP empty? 0=
    WHILE
     DUP car DUP => :ymin extra + SWAP => :yformat
     cdr
    REPEAT
    DROP
   ELSE
    DROP
    given SUPER :yformat
   THEN

   \ считаем высоту как сумму высоты каждой ячейки
   0 LAMBDA{ => _h @ + } traverse-grid SUPER _h !
;

: :add ( row -- ) 0 OVER => :xformat 0 OVER => :yformat vnode _rows @ cons _rows ! ;

: :print ( -- )
   CR ." CGrid :print"
   CR ." Grid: " SUPER :print
   CR ." Rows----- "
   LAMBDA{ CR => :print } traverse-grid
   CR ." ------End"
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

: :finalize { x y -- }
   _rows @
   BEGIN
    DUP empty? 0=
   WHILE
    DUP car x y ROT => :finalize
    DUP car => _h @ y + -> y
    cdr
   REPEAT
   DROP
;

;CLASS

\ -----------------------------------------------------------------------

\ макросы

\ память, ресурсы - всё течет

\ MODULE: WG

0 VALUE box \ текущая ячейке
0 VALUE ctl  \ контрол в текущей ячейке
0 VALUE row  \ текущий ряд
0 VALUE grid \ текущая сетка

\ создать новую клетку в текущем ряду и поместить в неё контрол класса class
: put-box ( box -- )
   TO box
   box row => :add ;

: put ( class -- )
   NewObj TO ctl
   CGridBox NewObj put-box
   0 SELF ctl => create DROP
   ctl box => :control! ;

\ начать новый ряд клеток
: ROW ( -- )
  CGridRow NewObj TO row
  row grid => :add
;

: save-vars ( -- l )  %[ grid % row % box % def-hmin % def-wmin % def-xspan % def-yspan % ]% ;

: restore-vars { l -- }
   ['] NOOP l mapcar ( ... )
   TO def-yspan
   TO def-xspan
   TO def-wmin
   TO def-hmin
   TO box
   TO row
   TO grid
   l FREE-LIST ;

\ начать новую таблицу
\ сохранить значения параметров сетки по-умолчания
: GRID ( -- i*x )
   save-vars
   CGrid NewObj TO grid
   ROW ;

\ закончить таблицу
\ восстановить сохранённые значения параметров сетки по-умолчанию
: ;GRID ( i*x -- grid ) grid >R restore-vars R> ;

: xspan! ( ? -- ) box :: CGridBox._xspan ! ;

\ включить растяжение клетки по ширине
: +xspan ( -- ) TRUE xspan! ;
\ выключить растяжение клетки по ширине
: -xspan ( -- ) FALSE xspan! ;

: yspan! ( ? -- ) box :: CGridBox._yspan ! ;

\ выключить растяжение клетки по высоте
: +yspan ( -- ) TRUE yspan! ;
\ выключить растяжение клетки по высоте
: -yspan ( -- ) FALSE yspan! ;

\ установить обработчик события
\ xt: ( obj -- )
: -command! ( xt -- ) ctl => setHandler ;
: -text! ( a u -- ) ctl => setText ;

: -xmin! ( u -- ) box :: CGridBox._wmin ! ;
: -ymin! ( u -- ) box :: CGridBox._hmin ! ;

\ ;MODULE

\ -----------------------------------------------------------------------
