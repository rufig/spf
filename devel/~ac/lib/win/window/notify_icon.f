REQUIRE Window    ~ac/lib/win/window/window.f
REQUIRE LoadIcon  ~ac/lib/win/window/image.f
REQUIRE TrackMenu ~ac/lib/win/window/popupmenu.f

WINAPI: Shell_NotifyIcon SHELL32.DLL

0 CONSTANT NIM_ADD
1 CONSTANT NIM_MODIFY
2 CONSTANT NIM_DELETE

1 CONSTANT NIF_MESSAGE
2 CONSTANT NIF_ICON
4 CONSTANT NIF_TIP

0
4 -- cbSize
4 -- hWnd
4 -- uID
4 -- uFlags
4 -- uCallbackMessage
4 -- hIcon
64 -- szTip
CONSTANT /NOTIFYICONDATA

HERE CONSTANT IconID
CREATE IconData /NOTIFYICONDATA ALLOT
/NOTIFYICONDATA IconData cbSize !
IconID IconData uID !
NIF_MESSAGE NIF_ICON OR NIF_TIP OR IconData uFlags !


: TrayIconDelete ( -- )
  IconData NIM_DELETE Shell_NotifyIcon DROP
;
: TrayIconCreate ( addr u icona iconu cmd hwnd -- )
  || a u ia iu cmd h mem || (( a u ia iu cmd h ))
  IconData -> mem
  h mem hWnd !
  cmd mem uCallbackMessage !
  ia iu LoadIcon mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
  TrayIconDelete
  mem NIM_ADD Shell_NotifyIcon DROP
;
: TrayIconCreateFromResource ( addr u iconid cmd hwnd -- )
  || a u id cmd h mem || (( a u id cmd h ))
  IconData -> mem
  h mem hWnd !
  cmd mem uCallbackMessage !
  id LoadIconResource16 mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
  TrayIconDelete
  mem NIM_ADD Shell_NotifyIcon DROP
;
: TrayIconModify ( addr u icona iconu cmd hwnd -- )
  || a u ia iu cmd h mem || (( a u ia iu cmd h ))
  IconData -> mem
  h mem hWnd !
  cmd mem uCallbackMessage !
  ia iu LoadIcon mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
  mem NIM_MODIFY Shell_NotifyIcon DROP
;
: TrayIconModifyText ( addr u cmd hwnd -- )
  || a u cmd h mem || (( a u cmd h ))
  IconData -> mem
  h mem hWnd !
  cmd mem uCallbackMessage !
  mem szTip 64 ERASE a mem szTip u 63 MIN MOVE
  mem NIM_MODIFY Shell_NotifyIcon DROP
;

\ S" Это пример" S" ico\mail10.ico" 1997 S" STATIC" 0 0 Window TrayIconCreate KEY DROP TrayIconDelete

