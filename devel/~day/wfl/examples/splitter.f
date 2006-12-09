( The very simple example )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f
NEEDS ~day\wfl\controls\splitter.f

CFrameWindow SUBCLASS CVerySimpleWindow

       CSplitterController OBJ hsplitter
       CSplitterController OBJ vsplitter

W: WM_CREATE
   2DROP 2DROP
   hsplitter setHorizontal
   SELF hsplitter createPanels
   SELF hsplitter createSplitter

   hsplitter upperPane this DUP
   vsplitter createPanels
   vsplitter createSplitter
   0
;

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
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