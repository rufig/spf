( Example of reflection of notifications from parent to child )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

CStatic SUBCLASS CColorStatic
       
       CBrush OBJ brush

init:
    0xFF 0xFF 0 rgb brush createSolid SUPER -wthrow
;

\ Note - it is R: for reflected message, not W:

R: WM_CTLCOLORSTATIC ( lpar wpar msg hwnd -- n )
    2 PICK TRANSPARENT SWAP SetBkMode DROP
    2DROP 2DROP
    brush handle @
;

;CLASS


CFrameWindow SUBCLASS CMainWindow

       CColorStatic OBJ label

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
    2DROP 2DROP 0
    0 PostQuitMessage DROP
;

\ Let a message be reflected
: message ( lpar wpar msg hwnd -- n )
    || CWinMessage msg ||

    msg copy INHERIT

    msg @ ReflectNotifications
    IF NIP THEN
;

12345 CONSTANT labelID

W: WM_CREATE ( lpar wpar msg hwnd -- n )
  2DROP 2DROP

  labelID SELF label create
  label attach
  
  0 30 400 100 100 label moveWindow

  S" Label that defines its color itself" label setText

  FALSE
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
