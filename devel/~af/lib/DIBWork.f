\ Andrey Filatkin, af@forth.org.ru
\ Работа с DIB'ом.
\ Только 256 цветов.

WINAPI: DeleteObject       GDI32.DLL
WINAPI: CreateCompatibleDC GDI32.DLL
WINAPI: DeleteDC           GDI32.DLL
WINAPI: CreateDIBSection   GDI32.DLL
WINAPI: SelectObject       GDI32.DLL
WINAPI: BitBlt             GDI32.DLL
WINAPI: SetDIBColorTable   GDI32.DLL


0
4 -- biSize
4 -- biWidth
4 -- biHeight
2 -- biPlanes
2 -- biBitCount
4 -- biCompression
4 -- biSizeImage
4 -- biXPelsPerMeter
4 -- biYPelsPerMeter
4 -- biClrUsed
4 -- biClrImportant
CONSTANT /BITMAPINFOHEADER

0
1 -- rgbBlue; 
1 -- rgbGreen; 
1 -- rgbRed; 
1 -- rgbReserved; 
CONSTANT /RGBQUAD

0
/BITMAPINFOHEADER -- bmiHeader
/RGBQUAD          -- bmiColors
CONSTANT /BITMAPINFO


0 VALUE BITMAPINFO
0 VALUE hDIB
0 VALUE DWordWidth
VARIABLE FBits


: DIBResize ( Width Height --) { \ DC -- }
  BITMAPINFO bmiHeader biHeight !
  BITMAPINFO bmiHeader biWidth  !
  0 GetDC DUP
  CreateCompatibleDC TO DC
  BITMAPINFO bmiHeader biWidth @ 3 + 2 RSHIFT 2 LSHIFT TO DWordWidth
  hDIB 0<> IF
    hDIB DeleteObject DROP
  THEN
  FBits 0!
  BITMAPINFO bmiHeader biWidth @ 0 <>
  BITMAPINFO bmiHeader biHeight @ 0 <>
  OR IF
    0 NULL FBits DIB_PAL_COLORS BITMAPINFO DC CreateDIBSection TO hDIB
  THEN
  DC DeleteDC DROP
  0 ReleaseDC DROP
;

: DIBCreate ( Width Height --)
  /BITMAPINFO /RGBQUAD 256 * + ALLOCATE THROW TO BITMAPINFO

  /BITMAPINFOHEADER BITMAPINFO bmiHeader biSize        !
                  1 BITMAPINFO bmiHeader biPlanes      W!
                  8 BITMAPINFO bmiHeader biBitCount    W!
             BI_RGB BITMAPINFO bmiHeader biCompression !
  DIBResize
;

: DIBDestroy
  BITMAPINFO FREE THROW
  hDIB 0<> IF
    hDIB DeleteObject DROP
  THEN
;

: DIBSetPalette ( LogPalette --) { \ DC -- }
  0 GetDC DUP
  CreateCompatibleDC TO DC
  hDIB DC SelectObject
  ROT 256 0 DC SetDIBColorTable DROP
  DC SelectObject DROP
  DC DeleteDC DROP
  0 ReleaseDC DROP
;

: DIBPaint ( destDC Left Top --) { destDC Left Top \ DC -- }
  0 GetDC DUP
  CreateCompatibleDC TO DC
  hDIB DC SelectObject

  SRCCOPY
   0 0
   DC
   BITMAPINFO bmiHeader biHeight @  BITMAPINFO bmiHeader biWidth @
   Top Left
   destDC
  BitBlt DROP

  DC SelectObject DROP
  DC DeleteDC DROP
  0 ReleaseDC DROP
;
