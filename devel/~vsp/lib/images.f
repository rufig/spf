\ Достать дескриптор картинки/иконки/курсора из файла/ресурсов учитывая/не учитывая размер
\ (c) Валентин Первых, 10 мая 2004.

REQUIRE W: ~yz/lib/wincons.f
REQUIRE {  lib/ext/locals.f
REQUIRE " ~yz/lib/common.f

WINAPI: LoadImageA		USER32.DLL
WINAPI: ExtractIconA	SHELL32.DLL


: load-sized-icon { x y z -- hicon }
  W: Lr_LoadFromFile x y W: Image_Icon z IMAGE-BASE LoadImageA ;

: load-sized-bitmap { x y z -- hbitmap }
  W: Lr_LoadFromFile x y W: image_Bitmap z IMAGE-BASE LoadImageA ;

: load-sized-cursor { x y z -- hcursor }
  W: Lr_LoadFromFile x y W: image_Bitmap z IMAGE-BASE LoadImageA ;

: load-icon ( z -- hicon)
  >R 0 0 R> load-sized-icon ;

: load-bitmap ( z -- hbitmap)
  >R 0 0 R> load-sized-bitmap ;

: load-cursor ( z -- hcursor)
  >R 0 0 R> load-sized-cursor ;

: load-sized-icon-from-res { x y n -- hicon }
  0 x y W: Image_Icon n IMAGE-BASE LoadImageA ;

: load-sized-bitmap-from-res { x y n -- hicon }
  0 x y W: Image_Bitmap n IMAGE-BASE LoadImageA ;

: load-sized-cursor-from-res { x y n -- hicon }
  0 x y W: Image_Cursor n IMAGE-BASE LoadImageA ;

: load-icon-from-res ( n -- hicon)
  >R 0 0 R> load-sized-icon-from-res ;

: load-bitmap-from-res ( n -- hbitmap)
  >R 0 0 R> load-sized-bitmap-from-res ;

: load-cursor-from-res ( n -- hcursor)
  >R 0 0 R> load-sized-cursor-from-res ;

: extract-icon ( z n -- hicon )
  SWAP IMAGE-BASE ExtractIconA ;
