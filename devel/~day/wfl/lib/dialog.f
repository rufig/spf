

WINAPI: CreateDialogIndirectParamA USER32.DLL
WINAPI: DialogBoxIndirectParamA    USER32.DLL

:NONAME ( lpar wpar msg hwnd -- u )
    OVER WM_INITDIALOG  = ( the first message of dialog )
    IF
       DUP 4 PICK ( obj = lpar ) DWL_DLGPROC InstallThunk

       \ send this message to the new object
       SendMessageA
    ELSE
       2DROP 2DROP 0
    THEN
; WNDPROC: BaseDlgProc

CWindow SUBCLASS CDialog

: SKIP
   S" OF TRUE EXIT ENDOF" EVALUATE
; IMMEDIATE

: skipMsgResult? ( msg -- f )
    CASE
      WM_INITDIALOG        SKIP
      WM_COMPAREITEM       SKIP
      WM_VKEYTOITEM        SKIP
      WM_CHARTOITEM        SKIP
      WM_QUERYDRAGICON     SKIP
      WM_CTLCOLORMSGBOX    SKIP
      WM_CTLCOLOREDIT      SKIP
      WM_CTLCOLORLISTBOX   SKIP
      WM_CTLCOLORBTN       SKIP
      WM_CTLCOLORDLG       SKIP
      WM_CTLCOLORSCROLLBAR SKIP
      WM_CTLCOLORSTATIC    SKIP
    ENDCASE 0
;

: message ( lpar wpar msg hwnd -- result )
    SUPER message

    SUPER msg message @ skipMsgResult? 0=
    IF
        0 SetLastError DROP
        DWL_MSGRESULT
        SUPER hWnd @ DUP
        IF
           SetWindowLongA SUPER -wthrow 0
        ELSE 2DROP
        THEN
    THEN
;

\ create modeless dialog
: show ( template parent-obj -- hwnd )
    || R: parent-obj R: template ||
    SELF
    ['] BaseDlgProc
    parent-obj @ DUP IF ^ checkWindow THEN
    template @ @
    HINST
    CreateDialogIndirectParamA
;

: endDialog ( n )
   SUPER checkWindow EndDialog SUPER -wthrow
;


C: IDCANCEL  ( code -- )
   DROP IDCANCEL endDialog
;

W: WM_CLOSE ( -- res )
    IDCANCEL endDialog 0
;

: showModal ( template parent-obj -- result )
    || R: parent-obj R: template ||
    SELF
    ['] BaseDlgProc
    parent-obj @ DUP IF ^ checkWindow THEN
    template @ @
    HINST
    DialogBoxIndirectParamA
;

: getItemStrText ( id -- str )
    || CWindow wnd ||
    SUPER checkWindow GetDlgItem wnd hWnd !
    wnd getStrText
;

;CLASS
