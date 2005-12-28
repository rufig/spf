REQUIRE STRUCT: lib/ext/struct.f
REQUIRE {       lib/ext/locals.f 

STRUCT: BMPINFO
   2 -- fType \     {Symbols 'B' and 'M'}
   4 -- fSize
   4 -- fRsrv
   4 -- fOffset \  {Size of file, reserved, offset to image}
   4 -- bSize
   4 -- bWidth
   4 -- bHeight \ {Size of structure = 28h,image metrics}
   2 -- bPlanes
   2 -- bBitCount \ {Number of color planes = 1, bits per pixel}
   4 -- bCompress
   4 -- bSizeImg \  {Compression = 0, size of the image}
   4 -- bXPelspM
   4 -- bYPelspM \   {Resolution - pixels per meter}
   4 -- bClrUsed
   4 -- bClrImportant \ {Colors used, important = 0}
;STRUCT

STRUCT: RGBImage 
 2 -- sizeX
 2 -- sizeY
 4 -- data
;STRUCT

: ?error SWAP IF CR ." BMP error " . SPACE FALSE RDROP EXIT ELSE DROP THEN ;

: LoadBMP24 { \ f inf img -- rgbimg }
   2DUP FILE-EXIST 0= IF 2DROP FALSE EXIT THEN
   R/O OPEN-FILE THROW TO f
   f FILE-SIZE DROP THROW BMPINFO::/SIZE < 1 ?error \ " Too small "
   BMPINFO::/SIZE ALLOCATE THROW TO inf 
   inf BMPINFO::/SIZE f READ-FILE THROW BMPINFO::/SIZE <> 2 ?error \ " No header "
   inf BMPINFO::fType W@ 0x4D42 <> 3 ?error \ " No BM sig "
   inf BMPINFO::bSize @ 0x028 <> 4 ?error \ " Size of structure <> 28h"
   inf BMPINFO::fSize @ f FILE-SIZE DROP THROW <> 5 ?error \ " Bad structure"
   inf BMPINFO::bBitCount W@ 24 <> 6 ?error \ " Not a 24bpp image"
\   inf BMPINFO::fOffset @ f REPOSITION-FILE THROW

   inf BMPINFO::fSize @ inf BMPINFO::fOffset @ - 
   DUP DUP ALLOCATE THROW TO img  
   img SWAP f READ-FILE THROW <> 7 ?error \ " Read failed"
   f CLOSE-FILE THROW

   RGBImage::/SIZE ALLOCATE THROW
   DUP img SWAP RGBImage::data !
   DUP inf BMPINFO::bWidth @ SWAP RGBImage::sizeX W!
   DUP inf BMPINFO::bHeight @ SWAP RGBImage::sizeY W!
   inf FREE THROW
;

\ S" nehe.bmp" LoadBMP24 DROP


