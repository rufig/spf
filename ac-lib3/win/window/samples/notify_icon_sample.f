REQUIRE TrayIconCreate ~ac/lib/win/window/notify_icon.f
REQUIRE ListBoxAddItem ~ac/lib/win/window/listbox.f

GET-CURRENT
VOCABULARY CONT-MENU
ALSO CONT-MENU DEFINITIONS
: Exit
  TrayIconDelete BYE
;
GET-CURRENT
PREVIOUS
SWAP SET-CURRENT

CONSTANT CONT-MENU-VOC

CREATE POINT 0 , 0 ,

: (TEST-WND-PROC) ( lparam wparam msg wnd -- lresult )
  || lparam wparam msg wnd || (( lparam wparam msg wnd ))
  msg 1997 =
  IF
    lparam WM_LBUTTONDOWN =
    IF wnd WindowShow  wnd WindowToForeground THEN
    lparam WM_RBUTTONDOWN =
    IF POINT GetCursorPos DROP
       POINT @ POINT CELL+ @
       wnd CONT-MENU-VOC MenuFromVoc
    THEN
  THEN lparam wparam msg wnd   wnd WindowOrigProc
;
' (TEST-WND-PROC) WNDPROC: TEST-WND-PROC

: TEST
  || w ||
  0 FORTH-WORDLIST ListboxFromVoc -> w
  ['] TEST-WND-PROC w WindowSubclass
  S" Список слов форт-системы" S" ico\mail10.ico" 1997 w TrayIconCreate
  200 400 w WindowSize
  0 w ListboxDeleteItem
  w MessageLoop
;