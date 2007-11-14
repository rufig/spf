REQUIRE NEEDS ~day/lib/includemodule.f

NEEDS ~ygrek/lib/wfl/grid/grid.f

CDialog SUBCLASS CMyDialog

 CGridController OBJ _g

: label ( a u -- ) CStatic put =text ;

: buttons 3 0 DO CButton put S" B" =text LOOP ;

 
: (grid)
 0 GRID
 2DUP label 
 ROW 
 DEFAULTS 
 EVALUATE 
 buttons 
 ;GRID put-box 
 ROW ;

: q: -1 PARSE POSTPONE SLITERAL POSTPONE (grid) ; IMMEDIATE

W: WM_INITDIALOG

 0 GRID
  q: +xspan +xfill 0 =xpad
  q: +xspan +xfill 5 =xpad
  q: +xspan -xfill 0 =xpad
  q: +xspan -xfill 5 =xpad
  q: -xspan 0 =xpad
  q: -xspan 5 =xpad
 ;GRID _g :grid!     

 _g this SUPER injectMsgController

 TRUE
;

;CLASS

0 0 0 0
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR

DIALOG: dlg1 grid-show!
DIALOG;

: winTest ( -- n )
  || CMyDialog dlg ||

  dlg1 0 dlg showModal DROP
;

winTest
