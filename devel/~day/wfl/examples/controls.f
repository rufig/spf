( example of using of different controls )

REQUIRE CWindow ~day\wfl\wfl.f

101 CONSTANT urlLabelID

CDialog SUBCLASS CTestDialog

       CUrlLabel OBJ label

\ Let a messages such WM_CTLCOLORSTATIC be reflected
 \ we catch it in urllabel
: message ( lpar wpar msg hwnd -- n )
    || CWinMessage msg ||

    msg copy INHERIT

    msg @ ReflectNotifications
    IF NIP THEN
;


W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )
   2DROP 2DROP

   S" http://forth.org.ru" label setURL
   urlLabelID SUPER getDlgItem label attach
   TRUE
;

;CLASS

0 0 200 150
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_CENTER OR

DIALOG: TestDialog Different controls
      urlLabelID   20 20 200 10   0 LTEXT http://www.forth.org.ru
DIALOG;

: winTest ( -- n )
  || CTestDialog dlg ||

  TestDialog 0 dlg showModal .
;

winTest