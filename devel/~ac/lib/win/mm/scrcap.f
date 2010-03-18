\ Запись экрана в BMP-файл.
\ Переведенный в Форт пример с сайта
\ http://msdn.microsoft.com/en-us/library/dd183533%28v=VS.85%29.aspx

REQUIRE GetClientRect    ~ac/lib/win/window/window.f 
REQUIRE GetDesktopWindow ~ac/lib/win/window/enumwindows.f 
REQUIRE {                ~ac/lib/locals.f
\ REQUIRE CreatePng        ~ac/lib/lin/zlib/png.f 

WINAPI: GetDC                  USER32.DLL
WINAPI: ReleaseDC              USER32.DLL
WINAPI: GetSystemMetrics       USER32.DLL
WINAPI: DeleteDC               GDI32.DLL
WINAPI: CreateCompatibleDC     GDI32.DLL
WINAPI: SetStretchBltMode      GDI32.DLL
WINAPI: StretchBlt             GDI32.DLL
WINAPI: BitBlt                 GDI32.DLL
WINAPI: CreateCompatibleBitmap GDI32.DLL
WINAPI: SelectObject           GDI32.DLL
WINAPI: GetObjectA             GDI32.DLL
WINAPI: GetDIBits              GDI32.DLL
WINAPI: DeleteObject           GDI32.DLL

0x00CC0020 CONSTANT SRCCOPY
         4 CONSTANT HALFTONE
         1 CONSTANT SM_CYSCREEN
         0 CONSTANT SM_CXSCREEN

         0 CONSTANT BI_RGB
         4 CONSTANT BI_JPEG
         5 CONSTANT BI_PNG

         0 CONSTANT DIB_RGB_COLORS

\ capture.f
0
CELL -- R.left
CELL -- R.top
CELL -- R.right
CELL -- R.bottom
CONSTANT /RECT

0
CELL -- bmType
CELL -- bmWidth
CELL -- bmHeight
CELL -- bmWidthBytes
   2 -- bmPlanes
   2 -- bmBitsPixel
CELL -- bmBits
CONSTANT /BITMAP

0
   2 -- bfType
CELL -- bfSize
   2 -- bfReserved1
   2 -- bfReserved2
CELL -- bfOffBits
CONSTANT /BITMAPFILEHEADER

0
CELL -- biSize
CELL -- biWidth
CELL -- biHeight
   2 -- biPlanes
   2 -- biBitCount
CELL -- biCompression
CELL -- biSizeImage
CELL -- biXPelsPerMeter
CELL -- biYPelsPerMeter
CELL -- biClrUsed
CELL -- biClrImportant
CONSTANT /BITMAPINFOHEADER

: SaveWindow { a u hwnd \ hdcWindow hdcScreen hdcMemDC rcClient hbmScreen bmpScreen bmfHeader bi dwBmpSize lpbitmap hFile dwSizeofDIB }
  hwnd GetDC -> hdcWindow 
  0 GetDC -> hdcScreen 
  hdcWindow CreateCompatibleDC -> hdcMemDC 
  hdcMemDC  0= IF ." hdcMemDC err" EXIT THEN
  /RECT ALLOCATE THROW -> rcClient
  rcClient hwnd GetClientRect DROP
\  rcClient R.left @ . rcClient R.top @ .
\  rcClient R.right @ . rcClient R.bottom @ . CR
  HALFTONE hdcWindow SetStretchBltMode DROP

  SRCCOPY
  SM_CYSCREEN GetSystemMetrics 
  SM_CXSCREEN GetSystemMetrics 
  0 0
  hdcScreen
  rcClient R.bottom @ rcClient R.right @
  0 0
  hdcWindow StretchBlt 0= IF ." StretchBlt err" EXIT THEN

  rcClient R.bottom @ rcClient R.top @ -
  rcClient R.right @ rcClient R.left @ - hdcWindow 
  CreateCompatibleBitmap -> hbmScreen 

  hbmScreen hdcMemDC SelectObject DROP

  SRCCOPY
  0 0 hdcWindow
  rcClient R.bottom @ rcClient R.top @ -
  rcClient R.right @ rcClient R.left @ -
  0 0 hdcMemDC BitBlt DROP

  /BITMAP ALLOCATE THROW -> bmpScreen
  bmpScreen /BITMAP hbmScreen GetObjectA DROP

  /BITMAPFILEHEADER ALLOCATE THROW -> bmfHeader
  /BITMAPINFOHEADER ALLOCATE THROW -> bi

  /BITMAPINFOHEADER  bi biSize !
  bmpScreen bmWidth @ bi biWidth !
  bmpScreen bmHeight @ bi biHeight !
  1 bi biPlanes W!
  32 bi biBitCount W!
  \ 24 bi biBitCount W! \ для CreatePng
  BI_RGB bi biCompression !
  bi biSizeImage 0!
  bi biXPelsPerMeter 0!
  bi biYPelsPerMeter 0!
  bi biClrUsed 0!
  bi biClrImportant 0!

  bmpScreen bmWidth @ bi biBitCount @ * 31 + 32 / 4 * bmpScreen bmHeight @ *
  -> dwBmpSize

  dwBmpSize ALLOCATE THROW -> lpbitmap

  DIB_RGB_COLORS bi lpbitmap
  bmpScreen bmHeight @ 0 hbmScreen hdcWindow GetDIBits DROP \ ." lines=" .

  a u R/W CREATE-FILE THROW -> hFile
  /BITMAPINFOHEADER /BITMAPFILEHEADER + dwBmpSize + -> dwSizeofDIB 

  /BITMAPINFOHEADER /BITMAPFILEHEADER + bmfHeader bfOffBits !
  dwSizeofDIB bmfHeader bfSize !
  0x4D42 bmfHeader bfType W! \ BM

  bmfHeader /BITMAPFILEHEADER hFile WRITE-FILE THROW
  bi /BITMAPINFOHEADER hFile WRITE-FILE THROW
  lpbitmap dwBmpSize hFile WRITE-FILE THROW
  hFile CLOSE-FILE THROW

  \ lpbitmap dwBmpSize S" test_screen.png" rcClient R.right @ rcClient R.left @ -
  \ CreatePng
  \ Картинка в png получается перевернутой.

  rcClient FREE THROW
  bmpScreen FREE THROW
  bmfHeader FREE THROW
  bi FREE THROW
  lpbitmap FREE THROW

  hbmScreen DeleteObject DROP
  \ hdcMemDC hwnd ReleaseDC . \ тут в msdn ошибка
  hdcMemDC DeleteDC DROP
  hdcScreen 0 ReleaseDC DROP
  hdcWindow hwnd ReleaseDC DROP
;
\ S" captureqwsx.bmp" GetDesktopWindow SaveWindow
