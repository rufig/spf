( Simple activeX hosting example )

REQUIRE CWindow ~day\wfl\wfl.f

CFrameWindow SUBCLASS CVerySimpleWindow

W: WM_DESTROY
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop CAxControl ctl CAxControl ctl2 ||

  StartCOM

  0 wnd create DROP
  SW_SHOW wnd showWindow

  S" MSHTML:<HTML><BODY> ActiveX HTML label! </BODY></HTML>" 
  0 wnd this ctl create

  S" MediaPlayer.MediaPlayer.1" 0 wnd this ctl2 create

  0 100 200 10 10 ctl moveWindow
  0 150 300 120 120 ctl2 moveWindow

  loop run

  EndCOM
;

winTest