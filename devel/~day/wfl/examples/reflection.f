( Example of reflection of notifications from parent to child )

REQUIRE CWindow ~day\wfl\wfl.f


CFrameWindow SUBCLASS CMainWindow

W: WM_DESTROY
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

;CLASS


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

12345 CONSTANT labelID

: winTest ( -- n )
  || CMainWindow wnd CColorStatic label CMessageLoop loop ||

  0 wnd create DROP
  SW_SHOW wnd showWindow

  S" test window" wnd setText

  labelID wnd this label create
  label attach
  
  0 30 400 100 100 label moveWindow

  S" Label that defines its color itself" label setText

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
