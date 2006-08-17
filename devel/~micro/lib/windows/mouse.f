\ Работа с мышью

WINAPI: GetCursorPos user32.dll
WINAPI: SetCursorPos user32.dll

REQUIRE WTHROW lib/win/winerr.f

: CursorPos@ ( -- y x )
    0 0 SP@ GetCursorPos WTHROW DROP
;

: CursorPos! ( x y -- )
  SWAP SetCursorPos WTHROW DROP
;