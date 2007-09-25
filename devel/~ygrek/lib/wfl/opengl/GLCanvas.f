\ $Id$

REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS lib/include/float2.f
NEEDS ~ygrek/lib/data/opengl.f
NEEDS ~day/hype3/hype3.f
NEEDS ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/GLObject.f
NEEDS ~ygrek/lib/joopengl/extra.f
NEEDS ~ygrek/lib/neilbawd/mersenne.f

: M, ( addr u -- addr+4 )   OVER  ! CELL+ ;
: MC, ( addr c -- addr+4 )  OVER C! 1+ ;
: MW, ( addr c -- addr+4 )  OVER W! 2+ ;

\ -----------------------------------------------------------------------

\ Контекст рисовния OpenGL
\ Состоит из Device Context (GDI) и Rendering Context (GL)
CDC SUBCLASS CGLContext
  VAR _hRC      \ Rendering Context

init: NULL _hRC ! ;

: :print CR ." CGLContext : " SUPER checkDC . _hRC @ . ;

: :createRC ( -- )
   SUPER checkDC wglCreateContext _hRC !
   _hRC @ 0= S" Failed to create Rendering Context" SUPER abort
;

\ Activate Rendering Context
: :takeRC ( -- )
   _hRC @ SUPER checkDC wglMakeCurrent
   0= S" Failed to activate Rendering Context" SUPER abort
;

: :releaseRC ( -- )
    NULL NULL wglMakeCurrent 0= S" Failed to release Rendering Context" SUPER abort ;

: :enable ( hwnd -- )
   SUPER create DROP
   :takeRC
;

: :disable ( -- )
   SUPER release
   :releaseRC
;

: :rc@ _hRC @ ;

: :deleteRC
  _hRC @
  IF
   _hRC @ wglDeleteContext 0= IF CR ." Failed to delete Rendering Context" THEN
   NULL _hRC !
  THEN
;

dispose: :deleteRC SUPER release ;

;CLASS

\ -----------------------------------------------------------------------

\ GL полотно - то на чём собственно происходит рисование
\ требует hwnd окна на котором рисует (метод :initialize)
\ сообщения НЕ перехватывает - это делается в классах-обёртках
\ создаёт таймер - можно вешаться на него и отрисовываться
CLASS CGLCanvas

  VAR _hwnd
  CGLContext OBJ _context
  VAR _width    \ ширина
  VAR _height   \ высота полотна для рисования
  CGLObjectList OBJ _scene   \ список обьектов для отрисовки

init:
   600 _width ! 400 _height !
   \ NULL SUPER class hbrBackground !
   \ WS_OVERLAPPEDWINDOW WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR SUPER style OR!
   \ WS_EX_APPWINDOW WS_EX_WINDOWEDGE OR SUPER exStyle OR!
;

: :width@ _width @ ;
: :width! _width ! ;
: :height@ _height @ ;
: :height! _height ! ;

dispose:          \ Properly Kill The Window
  \ CR ." CGLCanvas dispose"
  1 _hwnd @ KillTimer DROP
;

: :setupTimer 0 20 1 _hwnd @ SetTimer DROP ;

: :initGL
   \ CR ." CGLCanvas :initGL"
   GL_SMOOTH glShadeModel  DROP \ Enable Smooth Shading

   0.5E float 0E float  0E float 0E float glClearColor DROP \ Black Background

   GL_COLOR_BUFFER_BIT glClear DROP

   1E double glClearDepth DROP      \ Depth Buffer Setup

   GL_DEPTH_BUFFER_BIT glClear DROP

   GL_DEPTH_TEST glEnable DROP      \ Enables Depth Testing

   GL_LEQUAL glDepthFunc  DROP      \ The Type Of Depth Testing To Do

   GL_NICEST GL_PERSPECTIVE_CORRECTION_HINT glHint DROP
                   \ Really Nice Perspective Calculations

   GL_FRONT_AND_BACK GL_SHININESS 100e float glMaterialf DROP
   GL_FRONT_AND_BACK GL_SPECULAR glColorMaterial DROP
   GL_FRONT_AND_BACK GL_AMBIENT_AND_DIFFUSE glColorMaterial DROP


   GL_SCISSOR_TEST glDisable DROP

   \ CR ." InitGL done."

   \ CR ." Run :prepare"

   SELF => :prepare

   \ CR ." All set!"
;

\ Запрашиваемые размеры в _width и _height
: :resize \ Resize And Initialize The GL Window
    _hwnd @ _context :enable

       \ Теперь устанавливаем GL параметры окна
       _height @ 0 = IF 1 _height ! THEN  \ Prevent A Divide By Zero
       _height @ _width @ 0 0 glViewport DROP    \ Reset The Current Viewport

       GL_PROJECTION glMatrixMode DROP \ Select The Projection Matrix
       glLoadIdentity  DROP            \ Reset The Projection Matrix
       \ Calculate The Aspect Ratio Of The Window
       100e double \ far clipping plane
       0.1e double \ near clipping plane
       _width @ DS>F _height @ DS>F F/ double \ aspect ratio
       45e double  \ Field of View Y-coordinate
       gluPerspective DROP

       GL_MODELVIEW glMatrixMode DROP  \ Select The Modelview Matrix
       glLoadIdentity  DROP            \ Reset The Modelview Matrix

    _context :disable
;

: :initialize ( hwnd -- )
   _hwnd !
   { | pfd PixelFormat WindowRect h }
   status
   PIXELFORMATDESCRIPTOR::/SIZE ALLOCATE THROW TO pfd
           \ pfd Tells Windows How We Want Things To Be
   pfd
   PIXELFORMATDESCRIPTOR::/SIZE MW, \ Size Of This Pixel Format Descriptor
   1 MW,                            \ Version Number
   PFD_DRAW_TO_WINDOW              \ Format Must Support Window
   PFD_SUPPORT_OPENGL OR           \ Format Must Support OpenGL
   PFD_DOUBLEBUFFER OR M,          \ Must Support Double Buffering
   PFD_TYPE_RGBA MC,               \ Request An RGBA Format
   16 MC,                          \ Select Our Color Depth
   0 MC, 0 MC, 0 MC, 0 MC, 0 MC, 0 MC, \ Color Bits Ignored
   0 MC,                            \ No Alpha Buffer
   0 MC,                            \ Shift Bit Ignored
   0 MC,                            \ No Accumulation Buffer
   0 MC, 0 MC, 0 MC, 0 MC,          \ Accumulation Bits Ignored
   16 MC,                           \ 16Bit Z-Buffer (Depth Buffer)
   0 MC,                            \ No Stencil Buffer
   0 MC,                            \ No Auxiliary Buffer
   PFD_MAIN_PLANE MC,               \ Main Drawing Layer
   0 MC,                            \ Reserved
   0 M, 0 M, 0 M,                   \ Layer Masks Ignored
   DROP

\   status
\   pfd PIXELFORMATDESCRIPTOR::/SIZE DUMP
   \ ." PFD created"
   status

   _hwnd @ _context create DROP

   pfd _context checkDC ChoosePixelFormat TO PixelFormat
   PixelFormat 0= S" Can't Find A Suitable PixelFormat." SUPER abort

   pfd PixelFormat _context checkDC SetPixelFormat 0= S" Can't set this pixel format." SUPER abort

   pfd FREE THROW \ больше не нужен

   _context :createRC
   _context :takeRC

   :initGL

   _context :releaseRC
   _context release

   :resize

   :setupTimer ;

: :doPaint ( -- )
   _hwnd @ _context :enable

   GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear DROP
                                \ Clear Screen And Depth Buffer

   GL_MODELVIEW glMatrixMode DROP  \ Select The Modelview Matrix
   glLoadIdentity  DROP            \ Reset The Modelview Matrix

   _scene :draw
   _scene :rotate

   _context checkDC wglSwapBuffers DROP \ Doublebuffering :)

   _context :disable
;

: :add _scene :add ;

: :prepare _scene :prepare ;

: :setShift _scene :setShift ;
: :setAngleSpeed _scene :setAngleSpeed ;

;CLASS

\ -----------------------------------------------------------------------
