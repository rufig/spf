REQUIRE WL-MODULES ~day/lib/includemodule.f

\ NEEDS ~pinka/spf/exc-dump.f
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

;CLASS

\ -----------------------------------------------------------------------

: -text! ctl => setText ;

CDialog SUBCLASS CGridDialog

 VAR _g

: :grid! ( grid-obj -- ) _g ! ;

W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )
   2DROP 2DROP

  GRID
    CButton put
    CButton put -xspan 100 -xmin! S" Min width: 100" -text!
    ROW
    CEventButton put -yspan 100 -ymin! S" Min height: 100" -text!
     LAMBDA{ S" button pressed!" ROT => showMessage } -command!
    CGLControlTest put
    ctl S" DROP LITERAL => :switch" axt ( xt )
    CEventButton put ( xt ) -command!
    S" CLICK!" -text!
    ROW
    CButton put
  ;GRID :grid!

   _g @ 0= S" Initialize dialog grid before creating a dialog" SUPER abort

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


W: WM_SIZING ( lpar wpar msg hwnd -- )
   2DROP DROP
   || R: lpar CRect r ||
   lpar @ r rawCopyFrom
   _g @ => :ymin 30 + \ BUG: высота заголовка
   DUP r height > IF r height! lpar @ r rawCopyTo ELSE DROP THEN
   TRUE
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
