\ Ядро AutoPusher-а

WINAPI: FindWindowExA user32.DLL
WINAPI: SendMessageA user32.DLL

REQUIRE GetDesktopWindow ~micro/lib/windows/window.f

: WindowSearch ( hwnd1 addr u -- hwnd2 )
\ если hwnd1<>0, то найти среди его дочерних окон окно с текстом addr u,
\ иначе hwnd2=0
  ROT DUP >R
  ROT ROT
  R> IF
    DROP
    SWAP 0 SWAP 0 SWAP FindWindowExA
  ELSE
    2DROP
  THEN
;

: desktop ( -- hwnd ) GetDesktopWindow ;
\ вернуть хэндл десктопа

: push ( hwnd -- )
\ нажать на окно hwnd, если hwnd<>0
  ?DUP IF
    0 SWAP
    0 SWAP
    BM_CLICK SWAP
    SendMessageA DROP
  THEN
;
