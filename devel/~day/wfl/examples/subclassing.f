( Example of subclassed button. We filter windows messages in a queue of the button )

REQUIRE CWindow ~day\wfl\wfl.f


CFrameWindow SUBCLASS CMainWindow

W: WM_DESTROY
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

;CLASS


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

: winTest ( -- n )
  || CMainWindow wnd CColorButton btn CMessageLoop loop ||

  0 wnd create DROP
  SW_SHOW wnd showWindow

  S" test window" wnd setText

  12345 wnd this btn create 
  btn attach
  
  0 50 200 100 100 btn moveWindow

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