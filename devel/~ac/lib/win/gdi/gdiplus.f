\ Тест GDI+. Конвертация формата и изменение размера изображения.

REQUIRE >UNICODE ~ac/lib/win/com/com.f
REQUIRE STR@     ~ac/lib/str5.f

WINAPI: GdiplusStartup            Gdiplus.dll
WINAPI: GdipLoadImageFromFile     Gdiplus.dll
WINAPI: GdipGetImageThumbnail     Gdiplus.dll
WINAPI: GdipSaveImageToFile       Gdiplus.dll
WINAPI: GdipGetImageEncodersSize  Gdiplus.dll
WINAPI: GdipGetImageEncoders      Gdiplus.dll
WINAPI: GdipDisposeImage          Gdiplus.dll
WINAPI: GdiplusShutdown           Gdiplus.dll
WINAPI: GdipGetImageWidth         Gdiplus.dll
WINAPI: GdipGetImageHeight        Gdiplus.dll

CREATE GdiplusStartupInput 1 , 0 , 0 , 0 ,

: ConvertImageFile { fa fu ta tu ma mu w h \ gp img width height th n size encoders -- }
  0 GdiplusStartupInput ^ gp GdiplusStartup THROW
  ^ img fa fu >UNICODE DROP GdipLoadImageFromFile THROW
  UnicodeBuf @ FREE THROW
\  ^ width img GdipGetImageWidth THROW width .
\  ^ height img GdipGetImageHeight THROW height .
  0 0 ^ th h w img GdipGetImageThumbnail THROW
  ^ size ^ n GdipGetImageEncodersSize THROW
  size ALLOCATE THROW -> encoders
  encoders size n GdipGetImageEncoders THROW
  ma mu >UNICODE
  n 0 DO
    2DUP encoders I 76 * + 48 + @ UASCIIZ> COMPARE 0=
    IF 2DROP encoders I 76 * + LEAVE THEN
  LOOP
  UnicodeBuf @ FREE THROW
  0 SWAP ta tu >UNICODE DROP th GdipSaveImageToFile THROW
  UnicodeBuf @ FREE THROW
  encoders FREE THROW
  th GdipDisposeImage THROW
  img GdipDisposeImage THROW
  gp GdiplusShutdown THROW
;
\ S" C:\Users\ac2\Documents\A5_.jpg" S" test.png" S" image/png" 100 100 ConvertImageFile
\ S" C:\Users\ac2\Documents\A5_.jpg" S" test.jpg" S" image/jpeg" 100 100 ConvertImageFile
