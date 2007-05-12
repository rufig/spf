REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~ygrek/lib/wfl/opengl/GLControl.f
NEEDS ~day\wfl\wfl.f
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

REQUIRE ENUM: ~ygrek/lib/enum.f

\ --------------------------

CLASS CGridCell

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
CGridCell SUBCLASS CGridRow

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
    DUP car xspan-extra SWAP :: CGridCell.:perform-xspan
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
    DUP car given SWAP :: CGridCell.:perform-yspan-upto
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

CGridCell SUBCLASS CGrid

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

: FGENRANDMAX ( F: max -- f ) FGENRAND F* ;
: FGENRANDABS ( F: abs -- f ) 2e F* FGENRAND 0.5e F- F* ;
: toggle! ( addr -- ) DUP @ 0= SWAP ! ;

\ -----------------------------------------------------------------------

CGLControl SUBCLASS CGLControlTest

 VAR cube
 VAR pyr

init: ;
dispose: ;

: populate
     CGLCube NewObj cube !
     0.75e cube @ :: CGLCube.:resize
     0e 0e -10e cube @ :: CGLObject.:setShift
     5e FGENRANDABS 5e FGENRANDABS 5e FGENRANDABS cube @ :: CGLObject.:setAngleSpeed
     cube @ SUPER canvas :add

     CGLPyramid NewObj pyr !
     cube @ => :getScale pyr @ => :setScale
     cube @ => :getShift pyr @ => :setShift
     cube @ :: CGLObject.:getAngleSpeed pyr @ :: CGLObject.:setAngleSpeed
     pyr @ SUPER canvas :add

     TRUE cube @ :: CGLObject.<visible!
     FALSE pyr @ :: CGLObject.<visible!
;

: :switch 
    pyr @ => <visible toggle! 
    cube @ => <visible toggle! 
;

: create ( id parent -- hwnd )
    SUPER create
    SUPER checkWindow SUPER attach
    populate
;

: createSimple ( height width top left xt parent -- )
    0 SWAP create DROP
    DROP \ :)
    2>R 0 ROT ROT 2R> SUPER moveWindow
;

;CLASS

\ -----------------------------------------------------------------------

\ макросы

\ пам€ть, ресурсы - всЄ течет

0 VALUE this_cell
0 VALUE this_ctl
0 VALUE this_row
0 VALUE this_grid

: put ( class -- )
   NewObj TO this_ctl
   CGridCell NewObj TO this_cell
   0 SELF this_ctl => create DROP
   this_ctl this_cell => :control! 
   this_cell this_row => :add
;

: ROW
  CGridRow NewObj TO this_row
  this_row this_grid => :add
;

: GRID
   CGrid NewObj TO this_grid
   ROW ;

: ;GRID this_grid ;

: this_xspan! this_cell :: CGridCell._xspan ! ;

: +xspan TRUE this_xspan! ;
: -xspan FALSE this_xspan! ;

: this_yspan! this_cell :: CGridCell._yspan ! ;

: +yspan TRUE this_yspan! ;
: -yspan FALSE this_yspan! ;

: -xmin! ( u -- ) this_cell :: CGridCell._wmin ! ;
: -ymin! ( u -- ) this_cell :: CGridCell._hmin ! ;

\ -----------------------------------------------------------------------

CDialog SUBCLASS CGridDialog

 VAR _g

W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )
   2DROP 2DROP

   GRID
    CButton put
    CButton put -xspan 100 -xmin!
    ROW
    CButton put -yspan 100 -ymin!
    CGLControlTest put
    CButton put
   ;GRID _g !

   SUPER getClientRect DROP DROP SWAP _g @ => :format
   _g @ => :finalize

   TRUE
;

W: WM_SIZE { lpar wpar msg hwnd }
   lpar LOWORD 
   lpar HIWORD
   ( w h ) _g @ => :format 
   _g @ => :finalize
   FALSE
;

;CLASS

\ -----------------------------------------------------------------------

0 0 200 150
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR

DIALOG: GridDialog1 Grid test
DIALOG;

: winTest ( -- n )
  || CGridDialog dlg ||

  GridDialog1 0 dlg showModal DROP
;

winTest

\EOF

: winTest winTest BYE ;

TRUE  TO ?GUI
FALSE TO ?CONSOLE
FALSE TO TRACE-WINMESSAGES

' winTest MAINX !
   S" test.exe" SAVE BYE

\EOF

\ --------------------------

CGrid NEW grid

 CGridRow NEW row1

  CGridCell NEW z1
  10 z1 _wmin !
  20 z1 _hmin !

 z1 this row1 :add

  CGridCell NEW z2
  40 z2 _wmin !
  20 z2 _hmin !
  TRUE z2 _xspan !

 z2 this row1 :add

row1 this grid :add

 CGridRow NEW row2

  CGridCell NEW p1
  30 p1 _wmin !
  30 p1 _hmin !
  TRUE p1 _yspan !

 p1 this row2 :add

  CGridCell NEW p2
  50 p2 _wmin !
  10 p2 _hmin !
  TRUE p2 _yspan !
  TRUE p2 _xspan !

 p2 this row2 :add

row2 this grid :add


grid :print
grid :draw
200 100 grid :format
CR CR
grid :print
grid :draw