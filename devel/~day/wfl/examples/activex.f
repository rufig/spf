( Simple activeX hosting example )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

CFrameWindow SUBCLASS CVerySimpleWindow

       CAxControl OBJ ctl
       CAxControl OBJ ctl2

W: WM_CREATE ( -- n )
  S" MSHTML:<HTML><BODY> ActiveX HTML label! </BODY></HTML>" 
  0 SELF ctl create DROP

  S" MediaPlayer.MediaPlayer.1" 0 SELF ctl2 create DROP

  0 100 200 10 10 ctl moveWindow
  0 150 300 120 120 ctl2 moveWindow
  FALSE
;

W: WM_DESTROY ( -- n )
   0 PostQuitMessage DROP
   0
;

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop ||

  StartCOM

  0 0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run

  EndCOM
;

winTest