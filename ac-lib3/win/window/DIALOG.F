( 26.01.2000 Черезов А. )

( Работа с диалогами Windows )

REQUIRE ||             ~ac/lib/temps.f
REQUIRE CW_USEDEFAULT  ~ac/lib/win/window/winconst.f

WINAPI: DialogBoxIndirectParamA USER32.DLL
WINAPI: EndDialog               USER32.DLL
WINAPI: GetDlgItemTextA         USER32.DLL

: DialogGetItemText ( addr u item dlg -- len )
  2SWAP SWAP 2SWAP GetDlgItemTextA
;
\ ----------------------------------------------------------------------
\ функция окна диалога

: (DlgWndProc)     ( lparam wparam uint hwnd -- flag )
  || lparam wparam uint hwnd || (( lparam wparam uint hwnd ))

  uint WM_INITDIALOG = 
  IF  TRUE EXIT THEN

  uint WM_COMMAND =
  IF wparam IDCANCEL =
     IF 0 hwnd EndDialog EXIT THEN
     wparam IDOK =
     IF PAD 100 101 hwnd DialogGetItemText PAD SWAP TYPE
        PAD 100 102 hwnd DialogGetItemText PAD SWAP TYPE
        1 hwnd EndDialog EXIT THEN
  THEN

  FALSE
;

' (DlgWndProc) WNDPROC: DlgWndProc

: DialogModal ( template xt parent-hwnd -- x )
  || tpl xt par || (( tpl xt par ))
  0 xt par tpl 0 DialogBoxIndirectParamA
;
: DialogModalLoad ( filea fileu xt parent-hwnd -- x )
  || fa fu xt par h size dlg || (( fa fu xt par ))
  fa fu R/O OPEN-FILE ?DUP IF NIP EXIT THEN  -> h
  h FILE-SIZE ?DUP IF NIP NIP EXIT THEN D>S -> size
  size ALLOCATE THROW -> dlg
  dlg size h READ-FILE ?DUP IF NIP EXIT THEN DROP
  h CLOSE-FILE DROP
  0 xt par dlg 0 DialogBoxIndirectParamA
  dlg FREE DROP
;
\ : TEST
\ \  PasswordDialog @ ['] DlgWndProc 0 DialogModal .
\   S" password_dialog.res" ['] DlgWndProc 0 DialogModalLoad .
\ ;
\ TEST
