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

: onAttached
    populate
;

: create ( id parent -- hwnd )
    SUPER create
    SUPER checkWindow SUPER attach ;

;CLASS

\ -----------------------------------------------------------------------

\ copied from ~day/wfl/examples/msgcontroller.f
CMsgController SUBCLASS CColorController

       CBrush OBJ brush

init:
    0xFF 0xFF 0 rgb brush createSolid SUPER -wthrow
;

R: WM_CTLCOLORSTATIC ( -- n )
    SUPER msg wParam @
    TRANSPARENT SWAP SetBkMode DROP
    brush handle @ 
;

;CLASS

\ -----------------------------------------------------------------------

: aButton ( ctl -- )
   S" DROP LITERAL => :switch" axt ( xt )
   CEventButton put 
   ( xt ) =command  
   S" CLICK!" =text ;

CDialog SUBCLASS CExampleDialog

 CGridController OBJ grid
 CColorController OBJ bkcolor
 CStatic OBJ _static 

REFLECT_NOTFICATIONS

W: WM_INITDIALOG ( -- n )
   { | btn lv }

  0 GRID
     CButton put -xspan 120 =xmin S" Fixed width: 120" =text
     CButton put -yspan  30 =ymin S" Fixed height: 30" =text
    ROW

     CGLControlTest put ctl
     CGLControlTest put ctl
     CGLControlTest put ctl 
     -ROT SWAP
     0 GRID DEFAULTS -xspan aButton ROW aButton ROW aButton ;GRID put-box

    ROW
     CEventButton put 
     ctl -> btn
     S" debug" =text

    ROW
     CListView put -xspan 
     120 =xmin
     ctl -> lv

     S" MediaPlayer.MediaPlayer.1" CAxControl put 
     150 =ymin

    ROW
     CStatic put
     S" CStatic with CColorController" =text
     ctl => checkWindow _static attach 
  ;GRID grid :grid!

   0 120 S" column1" lv => insertColumn
   1 60 S" column2" lv => insertColumn

   0 S" Test string1" lv => insertString
   0 S" Test string2" lv => insertString

   grid :grid S" DROP LITERAL => :print" axt btn => setHandler

   bkcolor this _static injectMsgController
   grid this SUPER injectMsgController

   TRUE
;

;CLASS

\ -----------------------------------------------------------------------

0 0 200 250
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR

DIALOG: dlg1 Grid test
DIALOG;

: winTest ( -- n )
  || CExampleDialog dlg ||

  StartCOM
  dlg1 0 dlg showModal DROP
;

winTest

\EOF

: winTest winTest BYE ;

TRUE  TO ?GUI
FALSE TO ?CONSOLE
FALSE TO TRACE-WINMESSAGES

' winTest MAINX !
   S" test.exe" SAVE BYE
