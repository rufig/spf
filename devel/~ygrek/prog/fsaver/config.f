REQUIRE FrameWindow ~day\joop\win\framewindow.f
REQUIRE Button ~day\joop\win\control.f
REQUIRE Font ~day\joop\win\font.f
REQUIRE RG_OpenKey  ~ac/lib/win/registry2.f

: DefaultPath S" D:\WORK\FORTH\spf4" ;

: getConfigPath ( -- a u )
   HKEY_CURRENT_USER EK !
   S" fpath" S" SOFTWARE\fsaver" StrValue 
   DUP 0= IF 2DROP DefaultPath THEN ;

<< :bOkClick
<< :storeConfig

CLASS: ConfigDialog <SUPER FrameWindow
        Static OBJ st
        Edit   OBJ ePath
        Button OBJ bOk

: :init
    own :init
    WS_DLGFRAME WS_CAPTION OR WS_SYSMENU OR vStyle !
;

: :bOkClick 
   self :storeConfig
   0 self :modalResult! ;

W: WM_CHAR wparam @ 13 = IF self :bOkClick THEN ;

: :create
   own :create
   S" Directory to scan *.f in :" 10 10 120 11 self st :install
   getConfigPath 10 20 120 11 self ePath :install
   250 ePath :setLimit
   S" Ok" 10 36 40 13 self bOk :install
   ['] :bOkClick bOk <OnClick !
;

: :storeConfig
    HKEY_CURRENT_USER EK !
    ePath :getText S" fpath" S" SOFTWARE\fsaver" StrValue! ;

;CLASS

: ShowConfigDialog ( hwnd -- a u )
   >R ConfigDialog :new 
   R> SWAP >R 
   R@ :create
   140 100 140 70 R@ :move
   S" Input path" R@ :setText
   R@ :showModal DROP
   R> :free
;

\ getConfigPath \ TYPE CR

\EOF
0 ShowConfigDialog BYE
