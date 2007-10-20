( example of using of different controls )

REQUIRE WL-MODULES ~day\lib\includemodule.f
NEEDS ~day\wfl\wfl.f
NEEDS ~day\wfl\controls\urllabel.f

101 CONSTANT urlLabelID

CDialog SUBCLASS CTestDialog

       CUrlLabel OBJ label
       CEventButton  OBJ eventBtn


\ послылаем уведомления обратно дочерним окнам
\ этим пользуется например URLLabel
REFLECT_NOTFICATIONS

( it is not called as HYPE method, just as FORTH word, so 
  do not call SELF here )

: btnClick ( button-obj )
    S" button pressed!" ROT ^ showMessage
;

W: WM_INITDIALOG ( lpar wpar msg hwnd -- n )
   S" http://forth.org.ru" label setURL
   urlLabelID SUPER getDlgItem label attach

   20 80 60 20 Rect>Pixels ['] btnClick SELF eventBtn createSimple

   TRUE
;

;CLASS

0 0 200 150
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR WS_SIZEBOX OR
DS_CENTER OR

DIALOG: TestDialog Different controls
      urlLabelID   20 20 200 10   0 LTEXT http://www.forth.org.ru
DIALOG;

: winTest ( -- n )
  || CTestDialog dlg ||

  TestDialog 0 dlg showModal .
;

winTest

\EOF
TRUE  TO ?GUI
FALSE TO ?CONSOLE
FALSE TO TRACE-WINMESSAGES

: winTest
   winTest BYE
;

' winTest MAINX !
   S" test.exe" SAVE BYE