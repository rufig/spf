\ ��� AutoPusher-�

WINAPI: FindWindowExA user32.DLL
WINAPI: SendMessageA user32.DLL

REQUIRE GetDesktopWindow ~micro/lib/windows/window.f

: WindowSearch ( hwnd1 addr u -- hwnd2 )
\ �᫨ hwnd1<>0, � ���� �।� ��� ���୨� ���� ���� � ⥪�⮬ addr u,
\ ���� hwnd2=0
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
\ ������ ����� ���⮯�

: push ( hwnd -- )
\ ������ �� ���� hwnd, �᫨ hwnd<>0
  ?DUP IF
    0 SWAP
    0 SWAP
    BM_CLICK SWAP
    SendMessageA DROP
  THEN
;
