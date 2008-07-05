REQUIRE ||             ~ac/lib/temps.f

WINAPI: LoadImageA    USER32.DLL
WINAPI: LoadIconA     USER32.DLL
WINAPI: DestroyIcon   USER32.DLL
WINAPI: DeleteObject  GDI32.DLL  \ для bitmap
WINAPI: DestroyCursor USER32.DLL

BASE @ HEX
0010 CONSTANT LR_LOADFROMFILE
0020 CONSTANT LR_LOADTRANSPARENT
1000 CONSTANT LR_LOADMAP3DCOLORS
BASE !

0 CONSTANT IMAGE_BITMAP
1 CONSTANT IMAGE_ICON
2 CONSTANT IMAGE_CURSOR

: LoadIcon ( addr u -- h )
  || a u || (( a u ))
  LR_LOADFROMFILE 16 16 IMAGE_ICON a 0 LoadImageA
;
: LoadIconResource16 ( id -- h )
\ id - идентификатор ресурса GROUP_ICON, а не ICON
  || id || (( id ))
  0 16 16 IMAGE_ICON id IMAGE-BASE LoadImageA
;
: LoadIconResource32 ( id -- h )
\ id - идентификатор ресурса GROUP_ICON
  || id || (( id ))
  0 32 32 IMAGE_ICON id IMAGE-BASE LoadImageA
;
: LoadBitmap ( addr u -- h ) \ для вставки в меню, поэтому с LR_LOADMAP3DCOLORS
  || a u || (( a u ))
  LR_LOADFROMFILE ( LR_LOADTRANSPARENT OR) LR_LOADMAP3DCOLORS OR 
  0 0 IMAGE_BITMAP a 0 LoadImageA
;

\ S" ico\mail10.ico" LoadIcon .
