REQUIRE SendMessageA ~micro/autopush/core.f
REQUIRE WINCONST lib/win/const.f

WINAPI: PostMessageA user32.dll

: PushWindowWait ( x y h -- )
\ нажать на окно h в точке (x,y) относительно его верхнего левого угла
\ ждать завершения обработки нажатия
  >R
  16 LSHIFT OR 0 2DUP
  WM_LBUTTONDOWN R@ SendMessageA DROP
  WM_LBUTTONUP R> SendMessageA DROP
;

: PushWindow ( x y h -- )
\ нажать на окно h в точке (x,y) относительно его верхнего левого угла
  >R
  16 LSHIFT OR 0 2DUP
  WM_LBUTTONDOWN R@ PostMessageA DROP
  WM_LBUTTONUP R> PostMessageA DROP
;

: SendChar ( c hwnd -- )
  >R
  0 SWAP
  WM_CHAR
  R>
  SendMessageA DROP
;

: SendString ( addr u hwnd -- )
  >R
  0 ?DO
    DUP C@ R@ SendChar
    1+
  LOOP
  DROP RDROP
;