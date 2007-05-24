REQUIRE WFL ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/GLObject.f
NEEDS ~ygrek/lib/joopengl/extra.f

: M, ( addr u -- addr+4 )   OVER  ! CELL+ ;
: MC, ( addr c -- addr+4 )  OVER C! 1+ ;
: MW, ( addr c -- addr+4 )  OVER W! 2+ ;

\ -----------------------------------------------------------------------

CFrameWindow SUBCLASS CGLWindow

  VAR _hDC      \ GDI Device Context
  VAR _hRC      \ Rendering Context
  VAR _width    \
  VAR _height   \ размеры GL окна
  CGLObjectList OBJ _scene      \ все обьекты для отрисовки

init:
   600 _width ! 400 _height ! NULL _hDC ! NULL _hRC !
   \ NULL SUPER class hbrBackground !
   WS_OVERLAPPEDWINDOW WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR SUPER style OR!
   WS_EX_APPWINDOW WS_EX_WINDOWEDGE OR SUPER exStyle OR!
;


: :initGL
   CR ." InitGL. "
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

   CR ." InitGL done."

   CR ." Run :prepare"

   SELF => :prepare

   CR ." All set!"
;

: :resize { | WindowRect -- } \ Resize And Initialize The GL Window
\ Подогнать запрашиваемые размеры к возможным GLевским
      CR ." Request dimensions : " _width @ . _height @ .
       RECT::/SIZE ALLOCATE THROW TO WindowRect
                 0 WindowRect RECT::left ! \ Set Left Value To 0
          _width @ WindowRect RECT::right ! \ Set Right Value To Requested Width
                  0 WindowRect RECT::top ! \ Set Top Value To 0
        _height @ WindowRect RECT::bottom ! \ Set Bottom Value To Requested Height

       SUPER exStyle @ FALSE SUPER style @ WindowRect AdjustWindowRectEx DROP

       WindowRect RECT::bottom @ WindowRect RECT::top @ - _height !
       WindowRect RECT::right @ WindowRect RECT::left @ - _width !
       WindowRect FREE THROW
       CR ." Changed dimensions to : " _width @ . _height @ .

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
;

: :setupTimer
    0 20 1 SUPER hWnd @ SetTimer DROP ;

W: WM_CREATE { lpar wpar msg hwnd | pfd PixelFormat WindowRect h -- n }
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
   ." PFD created"
   status

   SUPER hWnd @ GetDC _hDC !
   _hDC @ 0= IF
    S" Can't create a GL Device Context." SUPER showMessage
    ( own :free ) BYE
   THEN

   pfd _hDC @ ChoosePixelFormat TO PixelFormat
   PixelFormat 0= IF
    S" Can't Find A Suitable PixelFormat." SUPER showMessage
    status
    ( own :free ) BYE
   THEN

   pfd PixelFormat _hDC @ SetPixelFormat 0= IF
    S" Can't set this pixel format." SUPER showMessage
    ( own :free ) BYE
   THEN

   pfd FREE THROW \ больше не нужен

   _hDC @ wglCreateContext _hRC !
   _hRC @ 0= IF
    S" Can't Create A GL Rendering Context." SUPER showMessage
    ( own :free ) BYE
   THEN

   _hRC @ _hDC @ wglMakeCurrent  \ Try To Activate The Rendering Context
   0= IF
    S" Can't Activate The GL Rendering Context." SUPER showMessage
    ( own :free ) BYE
   THEN

   :resize      \ Set Up Our Perspective GL Screen

   :initGL

   :setupTimer

   0 ;

: :maximize SW_MAXIMIZE SUPER hWnd @ ShowWindow DROP ;

: :onPaint
      GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear DROP
                                   \ Clear Screen And Depth Buffer

      GL_MODELVIEW glMatrixMode DROP  \ Select The Modelview Matrix
      glLoadIdentity  DROP            \ Reset The Modelview Matrix

      _scene :draw
      _scene :rotate

      _hDC @ wglSwapBuffers DROP \ Doublebuffering :)
;

: :add _scene :add ;

: :prepare _scene :prepare ;

(
W: WM_PAINT
   2DROP 2DROP
   :onPaint
   0 ;)

W: WM_TIMER
   2DROP 2DROP
   :onPaint
   0 ;

dispose:          \ Properly Kill The Window
  CR ." Kill "
  1 SUPER hWnd @ KillTimer DROP

  _hRC @ IF
   NULL NULL wglMakeCurrent 0= IF \ Are We Able To Release The DC And RC Contexts?
   CR ." Release Of DC And RC Failed." THEN
   _hRC @ wglDeleteContext 0= IF     \ Are We Able To Delete The RC?
   CR ." Release Rendering Context Failed." THEN
   NULL _hRC !
  THEN

  _hDC @ IF
     _hDC @ SUPER hWnd @ ReleaseDC 0= IF \ Are We Able To Release The DC
        CR ." Release Device Context Failed."
        NULL _hDC !
     THEN
  THEN
;

W: WM_DESTROY ( lpar wpar msg hwnd -- n )
   2DROP 2DROP 0
   0 PostQuitMessage DROP
;

W: WM_SIZE ( lpar wpar msg hwnd )
   CR ." WM_SIZE"
   3 PICK LOWORD _width !
   3 PICK HIWORD _height !
   2DROP 2DROP
   SELF :resize
;

: :setShift _scene :setShift ;
: :setAngleSpeed _scene :setAngleSpeed ;

;CLASS
