\ работа с окнами

WINAPI: GetWindowRect user32.dll
WINAPI: GetDesktopWindow user32.dll
WINAPI: GetWindow user32.dll
WINAPI: GetWindowTextA USER32.DLL
WINAPI: GetClassNameA user32.dll
WINAPI: FindWindowExA user32.dll

REQUIRE WTHROW lib/win/winerr.f
REQUIRE WINCONST lib/win/const.f

: WindowRect@ ( hwnd -- bottom right top left )
\ получить координаты углов окна
  >R
  0 0 0 0 SP@
  R>
  GetWindowRect WTHROW DROP
;

: GetWindowChild ( hwnd -- childhwnd )
\ получить первое дочернее окно
  GW_CHILD SWAP GetWindow
;

: GetWindowNext ( hwnd -- childhwnd )
\ получить следующее дочернее окно
  GW_HWNDNEXT SWAP GetWindow
;

: GetWindowOwner ( hwnd -- childhwnd )
\ получить владельца окна
  GW_OWNER SWAP GetWindow
;

: GetWindowChilds ( hwnd -- h1 ... hn n )
\ получить все дочерние окна, n - их количество
  GetWindowChild
  DUP IF
    1
    BEGIN
      OVER
      GetWindowNext ?DUP
    WHILE
      SWAP 1+
    REPEAT
  THEN
;

USER-CREATE WinText 257 USER-ALLOT

: GetWindowText ( hwnd -- addr u )
\ получить текст окна 
  256 SWAP WinText SWAP GetWindowTextA WinText SWAP
;

USER-CREATE WinClass 257 USER-ALLOT

: GetWindowClass ( hwnd -- addr u )
\ получить класс окна
  256 SWAP WinClass SWAP GetClassNameA WinClass SWAP
;

: FindChildByClass ( h1 addr u -- h2 )
\ найти дочернее окно по его классу
  DROP
  SWAP >R
  0 SWAP
  0 R> FindWindowExA
;
  
