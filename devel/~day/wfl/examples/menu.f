( The very simple example )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f

101 CONSTANT HOORAY_ID
102 CONSTANT BEEP_ID

WINAPI: MessageBeep USER32.DLL

CFrameWindow SUBCLASS CVerySimpleWindow

W: WM_DESTROY ( -- n )
   0 PostQuitMessage DROP
   0
;

M: HOORAY_ID ( -- )
   S" ура!" SUPER showMessage
;

M: BEEP_ID ( -- )
   MB_OK MessageBeep DROP
;

: createMenu \ -- h
    MENU
       S" Ура"  HOORAY_ID MF_GRAYED MENUITEM
       POPUP
          S" Ура2" HOORAY_ID 0 MENUITEM
       S" Ура" END-POPUP

       POPUP
          S" Beep" BEEP_ID 0 MENUITEM
          S" Beep2" BEEP_ID 0 MENUITEM
       S" Бимкнуть" END-POPUP    
    END-MENU
;    

;CLASS

: winTest ( -- n )
  || CVerySimpleWindow wnd CMessageLoop loop ||

  wnd createMenu
  0 wnd create DROP
  SW_SHOW wnd showWindow

  loop run
;

winTest