( 06.09.1999 Черезов А. )

( Работа с Popup Menu )

REQUIRE Window  ~ac/lib/win/window/window.f

WINAPI: CreatePopupMenu       USER32.DLL
WINAPI: AppendMenuA           USER32.DLL
WINAPI: TrackPopupMenu        USER32.DLL
WINAPI: DestroyMenu           USER32.DLL


BASE @ HEX
0080 CONSTANT TPM_NONOTIFY \ Don't send any notification msgs
0100 CONSTANT TPM_RETURNCMD
BASE !


: AppendMenu ( addr u id h -- )
  ROT DROP 0 SWAP AppendMenuA DROP
;
: TrackMenuWnd ( x y w h -- cmd )
  || x y w h || (( x y w h ))
  w SetForegroundWindow DROP
  0 w 0 y x TPM_RETURNCMD TPM_NONOTIFY OR h TrackPopupMenu
;
: TrackMenu ( x y h -- cmd )
  || x y h w || (( x y h ))
  S" EDIT" 0 0 Window -> w
  x y w h TrackMenuWnd
  w WindowDelete
;
: MenuFromVoc ( x y wnd wid -- ... )
  || x y wnd wid h a c i || (( x y wnd wid ))
  CreatePopupMenu -> h
  wid @
  BEGIN
    DUP
  WHILE
\    DUP NAME>        \ пришлось заменить на i, т.к. Win98 не сохраняет полный id :(
    i 1+ DUP -> i
    OVER COUNT 2DUP + DUP -> a C@ -> c  0 a C!
    ROT h AppendMenu
    c a C!
    CDR
  REPEAT DROP
  x y wnd h TrackMenuWnd -> i \ WinNT позволяет передавать xt в качестве id
  i                           \ а Win98 'обрезает' большие числа, пришлось
  IF                          \ вводить эту глупость с нумерацией
    wid @
    BEGIN
      i 1- DUP -> i
    WHILE
      CDR
    REPEAT NAME> EXECUTE
  THEN
  h DestroyMenu DROP
;

\ Примеры:

\ VARIABLE M
\ CreatePopupMenu M !
\ S" test1" 1 M @ AppendMenu
\ S" test2" 2 M @ AppendMenu
\ S" test3" 3 M @ AppendMenu
\ 0 0 M @ TrackMenu


\ HEX 0 0 S" EDIT" 0 0 Window FORTH-WORDLIST MenuFromVoc
