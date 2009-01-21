\ $Id$
\ Calculate pixels in dialog units

REQUIRE NEEDS ~day/lib/includemodule.f
REQUIRE GRID ~ygrek/lib/wfl/grid/grid.f
REQUIRE AsQName ~pinka/samples/2006/syntax/qname.f
REQUIRE +METHODS ~ygrek/lib/hype/ext.f
REQUIRE axt ~profit/lib/bac4th-closures.f

WINAPI: MapDialogRect USER32.DLL

CWindow +METHODS
: setStrText ( s -- ) DUP STRA 0 WM_SETTEXT sendMessage DROP STRFREE ;
;CLASS

CDialog SUBCLASS CMyDialog

 CGridController OBJ _g
 CStatic OBJ _label
 CFont OBJ _font

: getfactor
   || CRect r ||
   1000 r top !
   1000 r right !
   r this SUPER hWnd @ MapDialogRect DROP
   r right @ r top @
 ;

: update_label
  getfactor " 1000x1000 units = {n}x{n} pixels (HxW)" _label setStrText ;

: onclick
   update_label
   getfactor . . CR
; 

: ~font _font handle @ TRUE ctl => setFont ;

W: WM_INITDIALOG

 \ FIXME fontface here doesn't work. why?
 -14 700 S" Courier New" _font createFont DROP

 0 GRID
  _label this (put)
  \ CStatic put ctl => checkWindow _label attach
  ~font
  300 =xmin
  ROW
  CEventButton put
    `update =text
    SELF S" DROP LITERAL => onclick" axt =command
    ~font
 ;GRID _g :grid!

 update_label

 _g this SUPER injectMsgController

 TRUE
;

dispose: 
  \ DESTROY-VC for button click handler 
;

;CLASS

0 0 0 0
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR DS_SETFONT OR

DIALOG: mydlg Dialog units
  \ this font (and current windows theme) influences dialog units 
  12 0 FONT Tahoma 
DIALOG;

: winTest ( -- n )
  || CMyDialog dlg ||

  mydlg 0 dlg showModal DROP
;

winTest
