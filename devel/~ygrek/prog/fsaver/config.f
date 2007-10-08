REQUIRE FrameWindow ~day/joop/win/framewindow.f
REQUIRE Button ~day/joop/win/control.f
REQUIRE Font ~day/joop/win/font.f
REQUIRE RG_OpenKey  ~ac/lib/win/registry2.f
REQUIRE /TEST ~profit/lib/testing.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f
REQUIRE STR@ ~ac/lib/str5.f
REQUIRE $Revision: ~ygrek/lib/fun/kkv.f

MODULE: YZ
REQUIRE CZMOVE ~yz/lib/common.f
REQUIRE ShellGetDir ~ygrek/lib/win/shell.f
;MODULE

: fsaver-version $Revision$ SLITERAL " fsaver v0.{s} - sample screen saver in SP-Forth{CRLF}(see http://spf.sf.net)" STR@ ;

: DefaultPath S" C:\Program Files\SP-Forth" ;

: GetConfigPath ( -- a u )
    HKEY_CURRENT_USER EK !
    S" fpath" S" Software\fsaver" StrValue DUP IF EXIT THEN
    2DROP

    HKEY_LOCAL_MACHINE EK !
    S" InstallLocation" S" SOFTWARE\RUFIG\SP-Forth" StrValue DUP IF EXIT THEN
    2DROP

    HKEY_CLASSES_ROOT EK !
    S" " S" spf\Shell\open\command" StrValue DUP IF CUT-PATH 2DUP + 0 SWAP C! EXIT THEN
    2DROP

    DefaultPath ;

: SetConfigPath ( a u -- )
    HKEY_CURRENT_USER EK !
    S" fpath" S" SOFTWARE\fsaver" StrValue! ;

<< :bOkClick
<< :bCancelClick
<< :bBrowseClick
<< :setConfigPath

CLASS: ConfigDialog <SUPER FrameWindow
    Static OBJ stVersion
    Static OBJ st1
    Edit   OBJ ePath
    Button OBJ bOk
    Button OBJ bCancel
    Button OBJ bBrowse

: :init
    own :init
    WS_DLGFRAME WS_CAPTION OR WS_SYSMENU OR vStyle !
;

: :setConfigPath ePath :getText SetConfigPath ;

: :bOkClick 
   self :setConfigPath
   0 self :modalResult! ;

: :bCancelClick
   1 self :modalResult! ;

: :bBrowseClick 
   S" Select directory to search for *.f files" DROP 0 LAMBDA{ ePath :setText } YZ::ShellGetDir ;

W: WM_CHAR
   wparam @ 13 = IF self :bOkClick THEN 
   wparam @ 27 = IF self :bCancelClick THEN ;

: :create
   own :create

   fsaver-version 10 4 120 16 self st1 :install

   S" Directory to search for *.f files :" 10 20 120 10 self st1 :install

   GetConfigPath 10 30 115 11 self ePath :install
   250 ePath :setLimit

   S" Browse..." 10 46 35 13 self bBrowse :install
   ['] :bBrowseClick bBrowse <OnClick !
   S" Ok" 50 46 35 13 self bOk :install
   ['] :bOkClick bOk <OnClick !
   S" Cancel" 90 46 35 13 self bCancel :install
   ['] :bCancelClick bCancel <OnClick !
;

;CLASS

: ShowConfigDialog ( hwnd -- )
   ConfigDialog :new { dlg }
   dlg :create
   120 100 135 78 dlg :move
   S" Input path" dlg :setText
   dlg :showModal DROP
   dlg :free
;

/TEST
GetConfigPath TYPE CR
0 ShowConfigDialog 
BYE
