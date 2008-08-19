REQUIRE (WIN-SHOW-CONST) ~nn\lib\wincon.f
WINAPI: LoadImageA    USER32.DLL
WINAPI: LoadIconA     USER32.DLL
WINAPI: DestroyIcon   USER32.DLL
WINAPI: DeleteObject  GDI32.DLL  \ для bitmap
WINAPI: DestroyCursor USER32.DLL

BASE @ HEX
0010 CONSTANT LR_LOADFROMFILE
BASE !

0 CONSTANT IMAGE_BITMAP
1 CONSTANT IMAGE_ICON
2 CONSTANT IMAGE_CURSOR

: LoadIcon ( addr u -- h )
  DROP >R LR_LOADFROMFILE 16 16 IMAGE_ICON R> 0 LoadImageA
;
\ Добавил Абдрахимов И.А.
\ 02.11.04г.

: LoadIcon32 ( addr u -- h )
  DROP >R LR_LOADFROMFILE 32 32 IMAGE_ICON R> 0 LoadImageA
;

: LoadImage ( addr u -- h )
  DROP >R LR_LOADFROMFILE LR_DEFAULTSIZE LR_DEFAULTSIZE IMAGE_BITMAP 0 LoadImageA
;

: LoadImageSized ( addr u w h -- h )
  SWAP 2SWAP DROP >R 2>R LR_LOADFROMFILE 2R> IMAGE_BITMAP R> 0 LoadImageA
;

: LoadIconResource16 ( id -- h )
\ id - идентификатор ресурса GROUP_ICON, а не ICON
  >R
  0 16 16 IMAGE_ICON R> IMAGE-BASE LoadImageA
;
: LoadIconResource32 ( id -- h )
\ id - идентификатор ресурса GROUP_ICON
  >R
  0 32 32 IMAGE_ICON R> IMAGE-BASE LoadImageA
;
: LoadImageResource32  ( id -- h )
   >R
  0 32 32 IMAGE_BITMAP R> IMAGE-BASE LoadImageA
;

 \ S" qm.ico" LoadIcon .
