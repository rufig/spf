\ $Id$

REQUIRE glViewport ~ygrek/lib/data/opengl.f
REQUIRE PIXELFORMATDESCRIPTOR ~ygrek/lib/joopengl/extra.f
REQUIRE ADD-CONST-VOC lib/ext/const.f
S" ~ygrek/lib/data/opengl.const" ADD-CONST-VOC

: gl-status
  ( CR
  ." f=" FDEPTH .
  ." d=" DEPTH  . 
  DEPTH 10 MIN .SN )
  GetLastError ?DUP IF CR ." Error " . THEN
  glGetError ?DUP IF CR ." GL error " . THEN
;

\ переносит число с float-стека на стек данных в формате "32 бит" (как его ожидают GL функции)
: float ( F: f -- D: f ) FLOAT>DATA32 ;

\ [ 0x8D C, 0x6D C, 0xFC C,
\   0xD9 C, 0x5D C, 0x00 C,
\   0x87 C, 0x45 C, 0x00 C,
\   0xC3 C, ] ;

\ CODE float
\        LEA  EBP, -4 [EBP]
\        FSTP  DWORD [EBP]
\        XCHG  EAX, [EBP]
\        RET
\ END-CODE

\ --""-- в формате "64 бит"
: double ( F: f -- D: f1 f2 ) FLOAT>DATA SWAP ;
