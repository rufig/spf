( Simple activeX hosting example )

REQUIRE CWindow ~day\wfl\wfl.f

CFrameWindow SUBCLASS CVerySimpleWindow

W: WM_DESTROY
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop CWebBrowser ctl CWebBrowser ctl2 ||

  StartCOM

  0 wnd create DROP
  0 50 50 830 540 Rect>Win wnd moveWindow
  SW_SHOW wnd showWindow

  \ file dir
  0 wnd this ctl create
  0 10 10 400 500 Rect>Win ctl moveWindow
  S" c:\" ctl navigate

  
  \ wen site
  0 wnd this ctl2 create
  0 410 10 400 500 Rect>Win ctl2 moveWindow
  S" http://forth.org.ru" ctl2 navigate

  loop run

  EndCOM
;

winTest