REQUIRE CapStart  ~ac/lib/win/mm/cam.f 
REQUIRE CreatePng ~ac/lib/lin/zlib/png.f 

: SaveSamplePNG { lBufferSize pBuffer dblSampleTime2 dblSampleTime1 this -- }
  dblSampleTime1 dblSampleTime2 D. pBuffer . lBufferSize . CR
  pBuffer lBufferSize CamBufStretch
  pBuffer lBufferSize S" test.png" this @ CB.width @ CreatePng
;
: TEST { \ cap -- }
  ComInit THROW
  ['] SaveSamplePNG CapOpen -> cap
  cap 0= IF EXIT THEN
  cap CapStart
  2000 PAUSE \ колбэки получают кадры
  cap CapStop
  cap CapClose

  CR CR
  ['] SaveSamplePNG CapOpen -> cap
  cap CapStart
  2000 PAUSE \ колбэки получают кадры
  cap CapStop
  cap CapClose
;
\ S" vtest.exe" SAVE BYE
TEST
