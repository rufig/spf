\ 13.Jul.2001 Fri 20:30  Ruv
\ оригинал - ~ac\lib\win\window\notify_icon.f 
\ расширил для возможности управлять несколькими иконками в терее одновременно.
\ Изменил имена.

REQUIRE Window    ~ac/lib/win/window/window.f
REQUIRE LoadIcon  ~ac/lib/win/window/image.f
REQUIRE TrackMenu ~ac/lib/win/window/popupmenu.f

REQUIRE {               ~ac/lib/locals.f
REQUIRE [UNDEFINED]     lib\include\tools.f

[UNDEFINED] Shell_NotifyIcon [IF]

WINAPI: Shell_NotifyIcon SHELL32.DLL

0 CONSTANT NIM_ADD
1 CONSTANT NIM_MODIFY
2 CONSTANT NIM_DELETE

1 CONSTANT NIF_MESSAGE
2 CONSTANT NIF_ICON
4 CONSTANT NIF_TIP
                             [THEN]
VOCABULARY NotifyIconVoc
GET-CURRENT
ALSO NotifyIconVoc DEFINITIONS

0
4 -- cbSize
4 -- hWnd
4 -- uID
4 -- uFlags
4 -- uCallbackMessage
4 -- hIcon
64 -- szTip
CONSTANT /NOTIFYICONDATA

( HERE CONSTANT IconID
CREATE IconData /NOTIFYICONDATA ALLOT
/NOTIFYICONDATA IconData cbSize !
IconID IconData uID !
NIF_MESSAGE NIF_ICON OR NIF_TIP OR IconData uFlags !
)

SET-CURRENT  \ EXPORT \ PUBLIC \ 

: Delete-TrayIcon ( ic_id -- )
  DUP NIM_DELETE Shell_NotifyIcon DROP
  DUP hIcon @  ?DUP IF DestroyIcon ERR THROW THEN
  FREE THROW
;
: Create-TrayIcon ( addr u icona iconu cmd hwnd -- ic_id )
  { a u ia iu cmd hwnd \ mem }
  /NOTIFYICONDATA ALLOCATE THROW -> mem
  /NOTIFYICONDATA mem cbSize !
  cmd  mem uID  !
  NIF_MESSAGE NIF_ICON OR NIF_TIP OR mem uFlags !

  hwnd mem hWnd !
  cmd mem uCallbackMessage !
  ia iu LoadIcon mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
\  mem TrayIconDelete
  mem NIM_DELETE Shell_NotifyIcon DROP
  mem NIM_ADD Shell_NotifyIcon DROP
  mem
;
: Create-TrayIconFromResource ( addr u iconid cmd hwnd -- ic_id )
  { a u id cmd hwnd \ mem }
  /NOTIFYICONDATA ALLOCATE THROW -> mem
  /NOTIFYICONDATA mem cbSize !
  cmd  mem uID  !
  NIF_MESSAGE NIF_ICON OR NIF_TIP OR mem uFlags !

  hwnd mem hWnd !
  cmd mem uCallbackMessage !
  id LoadIconResource16 mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
\  mem TrayIconDelete
  mem NIM_DELETE Shell_NotifyIcon DROP
  mem NIM_ADD Shell_NotifyIcon DROP
  mem
;

: Modify-TrayIcon ( addr u icona iconu ic_id -- )
  { a u ia iu  mem }
  mem hIcon @ ?DUP IF DestroyIcon ERR THROW THEN
  ia iu LoadIcon mem hIcon !
  mem szTip 64 ERASE a mem szTip u MOVE
  mem NIM_MODIFY Shell_NotifyIcon DROP
;
: Modify-TrayIconText ( addr u ic_id -- )
  { a u mem }
  mem szTip 64 ERASE a mem szTip u 63 MIN MOVE
  mem NIM_MODIFY Shell_NotifyIcon DROP
;
: Modify-TrayIconFile ( addr u ic_id -- )
  { ia iu mem }
  mem hIcon @ ?DUP IF DestroyIcon ERR THROW THEN
  ia iu LoadIcon mem hIcon !
  mem NIM_MODIFY Shell_NotifyIcon DROP
;
: Modify-TrayIconImage ( hImage ic_id -- )
  DUP hIcon @ ?DUP IF DestroyIcon ERR THROW THEN
  TUCK  hIcon !
  NIM_MODIFY Shell_NotifyIcon DROP
;

PREVIOUS

 (
0 VALUE w
: test
S" STATIC" 0 0 Window TO w
S" Это пример" S" MODEM16.ICO" 1997  w Create-TrayIcon 
 KEY DROP Delete-TrayIcon
;
\ )