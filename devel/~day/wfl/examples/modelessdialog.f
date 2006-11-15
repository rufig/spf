REQUIRE CWindow ~day\wfl\wfl.f

0 0 100 50
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: Dialog1 TAB button works!

      8 0 FONT MS Sans Serif

      -1  5  5  50 15  WS_GROUP  PUSHBUTTON Button1
      -1  5  22  50 15  0 PUSHBUTTON Button2

DIALOG;


CDialog NEW dlg1
CDialog NEW dlg2

Dialog1 0 dlg1 show DROP
Dialog1 0 dlg2 show DROP

SW_SHOW dlg1 showWindow
SW_SHOW dlg2 showWindow

TRUE dlg1 getWindowRect 60 60 ToPixels MoveRect Rect>Width dlg1 moveWindow


CMessageLoop NEW msgloop

msgloop run