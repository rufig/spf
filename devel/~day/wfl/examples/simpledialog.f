( Simple modal dialog example )

REQUIRE CWindow ~day\wfl\wfl.f

101 CONSTANT loginID
102 CONSTANT pswID

CDialog SUBCLASS CPswDialog

    CString OBJ psw
    CString OBJ login

C: IDOK ( code -- )
    loginID SUPER getItemStrText login !
    pswID SUPER getItemStrText psw !

    DROP IDOK SUPER endDialog
;

: report ( -- addr u )
    <# psw @ STR@ HOLDS
       S"  and password: " HOLDS login @ STR@ HOLDS 
       S" you entered login: " HOLDS 0. #>
    SUPER showMessage
;

;CLASS

0 0 102 66
WS_POPUP WS_SYSMENU OR WS_CAPTION OR DS_MODALFRAME OR
DS_SETFONT OR DS_CENTER OR

DIALOG: PasswordDialog Login

      8 0 FONT MS Sans Serif

  loginID 45  4 51 14 ES_AUTOHSCROLL                EDITTEXT
    pswID 45 25 51 14 ES_AUTOHSCROLL ES_PASSWORD OR EDITTEXT
     IDOK  5 45 40 14 0 PUSHBUTTON OK
 IDCANCEL 55 45 40 14 0 PUSHBUTTON Cancel
      104  6  7 37  8 0 LTEXT Name
      105  6 28 37  8 0 LTEXT Password

DIALOG;


CPswDialog NEW dialog

: test
    PasswordDialog 0 dialog showModal IDOK =
    IF
       dialog report
    ELSE S" Please enter the values" dialog showMessage
    THEN
;

test