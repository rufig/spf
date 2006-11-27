( Example of subclassed button. We filter windows messages in a queue of the button )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

CButton SUBCLASS CColorButton

         VAR captured
         VAR textPen

: captureCursor
   1 captured !
   SUPER hWnd@ SetCapture DROP
   0 0 SUPER hWnd@ InvalidateRect DROP
;

W: WM_LBUTTONDBLCLK
   captureCursor
   2DROP 2DROP 0
;

W: WM_LBUTTONDOWN
   captureCursor
   2DROP 2DROP 0
;

W: WM_MOUSEMOVE
   2DROP 2DROP 0
;

W: WM_CAPTURECHANGED
   0 captured !
   0 0 SUPER hWnd@ InvalidateRect DROP
   2DROP 2DROP 0
;

W: WM_LBUTTONUP
   ReleaseCapture DROP
   2DROP 2DROP 0
;

: getBrushColor ( -- rgb )
   captured @
   IF 0xFF 0 0xFF 
   ELSE 0xFF 0xFF 0
   THEN 
   rgb 
;

: drawText ( hdc )
   || CRect r ||
   SUPER getClientRect r !

   DUP TRANSPARENT SWAP SetBkMode DROP

   DT_VCENTER DT_CENTER OR DT_SINGLELINE OR
   r addr
   ROT ( hdc )
   S" This is a subclassed button!" SWAP
   ROT
   DrawTextA DROP
;

: getTextColor ( -- rgb )
   captured @
   IF
     0xFF 0xFF 0 
   ELSE 0 0 0
   THEN  rgb
;

W: WM_PAINT
   || R: hwnd CPaintDC dc CBrush brush CRect r ||

   2DROP DROP hwnd @ dc create DROP

   getTextColor dc setTextColor
   getBrushColor brush createSolid dc selectObject DROP

   SUPER getClientRect
   brush handle @ dc fillRect

   dc:: handle @ drawText

   0
;

;CLASS

CFrameWindow SUBCLASS CMainWindow

     CColorButton OBJ btn

12345 CONSTANT btnID

W: WM_CREATE ( lpar wpar msg hwnd -- n )
    2DROP 2DROP

    btnID SELF btn create 
    btn attach
  
    0 50 200 100 100 btn moveWindow
    FALSE
;

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

;CLASS

: winTest ( -- n )
  || CMainWindow wnd CMessageLoop loop ||

  0 wnd create DROP
  SW_SHOW wnd showWindow

  S" test window" wnd setText

  loop run
;

TRUE TO TRACE-WINMESSAGES
winTest

\EOF

TRUE  TO ?GUI
FALSE TO ?CONSOLE
FALSE TO TRACE-WINMESSAGES

: winTest
   winTest BYE
;

' winTest MAINX !
   S" test.exe" SAVE BYE