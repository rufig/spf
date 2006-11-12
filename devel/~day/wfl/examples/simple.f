( The very simple example )

REQUIRE CWindow ~day\wfl\wfl.f

CFrameWindow SUBCLASS CVerySimpleWindow

W: WM_DESTROY
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop ||

  0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run
;

winTest