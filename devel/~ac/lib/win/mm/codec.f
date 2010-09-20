REQUIRE /BITMAPINFOHEADER ~ac/lib/win/mm/capture.f 

WINAPI: ICLocate  Msvfw32.dll
WINAPI: ICInfo    Msvfw32.dll
WINAPI: ICOpen    Msvfw32.dll
WINAPI: ICGetInfo Msvfw32.dll

0
CELL -- ici.dwSize
CELL -- ici.fccType
CELL -- ici.fccHandler
CELL -- ici.dwFlags
CELL -- ici.dwVersion
CELL -- ici.dwVersionICM
  32 -- ici.szName        \ [16]wchar
 256 -- ici.szDescription \ [128]
 256 -- ici.szDriver      \ [128]
CONSTANT /ICINFO

\ MKFOURCC
CHAR v
CHAR i 8 LSHIFT OR
CHAR d 16 LSHIFT OR
CHAR c 24 LSHIFT OR CONSTANT ICTYPE_VIDEO

CHAR a
CHAR u 8 LSHIFT OR
CHAR d 16 LSHIFT OR
CHAR c 24 LSHIFT OR CONSTANT ICTYPE_AUDIO
\ перебор аудио-кодеков этими функциями (ниже) не работает...

4 CONSTANT ICMODE_QUERY

: TEST { \ i ici hic -- }
  /ICINFO ALLOCATE THROW -> ici
  /ICINFO ici ici.dwSize !
  BEGIN
    ici i ICTYPE_VIDEO ICInfo
  WHILE
    \ ici ici.szName 32 DUMP \ пусто
    \ ici ici.szDescription 32 DUMP \ пусто
    i . ici ici.szDriver UASCIIZ> UNICODE> TYPE SPACE
    ici ici.fccType 8 TYPE SPACE
    ICMODE_QUERY ici ici.fccHandler @ ici ici.fccType @ ICOpen ?DUP
    IF -> hic
      /ICINFO ici hic ICGetInfo
      IF ici ici.szDescription UASCIIZ> UNICODE> ANSI>OEM TYPE CR THEN
    THEN
    i 1+ -> i
  REPEAT
;
TEST
