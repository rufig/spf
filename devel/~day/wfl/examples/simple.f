( The very simple example )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

CFrameWindow SUBCLASS CVerySimpleWindow

W: WM_DESTROY ( -- n )
   0 PostQuitMessage DROP 
   0
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop ||

  0 0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run
;

winTest