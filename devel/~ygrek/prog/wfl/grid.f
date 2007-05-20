REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~ygrek/lib/wfl/opengl/GLControl.f
NEEDS ~ygrek/lib/wfl/grid/grid.f
NEEDS ~profit/lib/bac4th-closures.f

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

CRect SUBCLASS CRect

: rawCopyFrom ( ^RECT -- ) SUPER addr 4 CELLS CMOVE ;
: rawCopyTo ( ^RECT -- ) SUPER addr SWAP 4 CELLS CMOVE ;

: height! ( u -- ) SUPER top @ + SUPER bottom ! ;
: width! ( u -- ) SUPER left @ + SUPER right ! ;

;CLASS

\ -----------------------------------------------------------------------

CDialog SUBCLASS CGridDialog

 VAR _g

: :grid! ( grid-obj -- ) _g ! ;

: :resize ( w h -- )
   _g @ => :yformat
   _g @ => :xformat
   0 0 _g @ => :finalize ;

: :minsize ( w h -- w1 h1 )
   _g @ => :ymin 30 + \ BUG: высота заголовка
   2DUP > IF DROP ELSE NIP THEN
   SWAP
   _g @ => :xmin 8 + \ BUG: ширина рамки
   2DUP > IF DROP ELSE NIP THEN
   \ 2DUP CR ." MIN : w = " . ." h = " .
   SWAP ;

W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )
   2DROP 2DROP
   { | b v }

  GRID
    CButton put
    CButton put -xspan 100 -xmin! S" Min width: 100" -text!
    ROW
    CEventButton put -yspan 100 -ymin! S" Min height: 100" -text!
     LAMBDA{ S" button pressed!" ROT => showMessage } -command!
    CGLControlTest put
    ctl S" DROP LITERAL => :switch" axt ( xt )
    CEventButton put ( xt ) -command!  S" CLICK!" -text!
    ROW
    GRID
     CButton put
     ROW
     CButton put
     ROW
     CButton put
    ;GRID put-box
    S" MediaPlayer.MediaPlayer.1" CAxControl put
    \ CListView put -xspan 120 -xmin!
    \ ctl -> v
    ROW
    CEventButton put S" debug" -text! ctl -> b
  ;GRID :grid!

  \ 0 120 S" column1" v => insertColumn
   \ 1 60 S" column2" v => insertColumn

   \ 0 S" Test string1" v => insertString
   \ 0 S" Test string2" v => insertString

   _g @ 0= S" Initialize dialog grid before creating a dialog" SUPER abort

   _g @ S" DROP LITERAL => :print" axt b => setHandler

   SUPER getClientRect DROP DROP SWAP :minsize :resize

   FALSE _g @ => _h @ _g @ => _w @ SUPER getClientRect 2SWAP 2DROP SWAP SUPER clientToScreen SWAP SUPER moveWindow

   TRUE
;

W: WM_SIZE { lpar wpar msg hwnd }
   lpar LOWORD lpar HIWORD :resize
   FALSE
;

W: WM_SIZING ( lpar wpar msg hwnd -- )
   2DROP DROP
   || R: lpar CRect r ||
   lpar @ r rawCopyFrom
   r width r height :minsize r height! r width!
   lpar @ r rawCopyTo
   TRUE
;

;CLASS

\ -----------------------------------------------------------------------

0 0 200 250
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR

DIALOG: GridDialog1 Grid test
DIALOG;

: winTest ( -- n )
  || CGridDialog dlg ||

  StartCOM
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
