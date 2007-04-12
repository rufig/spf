\ чтобы увидеть кролика - модель брать тут : http://www.forth.org.ru/~ygrek/files/bun_zipper.7z
\ распаковать и положить рядом
\ можно сохранить по save и запускать указав модель как параметр в комстроке
\ wflgl.exe bun_zipper.ply2

REQUIRE WL-MODULES ~day/lib/includemodule.f

: REQUIRE NEEDED ;

REQUIRE FLOAT lib/include/float2.f

NEEDS ~day/hype3/hype3.f
NEEDS ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/GLObject.f
NEEDS ~ygrek/lib/joopengl/extra.f 
NEEDS ~ygrek/lib/data/opengl.f
NEEDS ~day/common/clparam.f

\ NEEDS ~ac/lib/str5.f

: PrepareLight

   GL_NORMALIZE glEnable DROP       \ Enable normalization of normales

   GL_COLOR_MATERIAL glEnable DROP  \ The color is treated as the material color

   || CGLPoint p ||

   0.2e 0.2e 0.2e 0.5e p :set4
   p :getv GL_AMBIENT GL_LIGHT1 glLightfv DROP
   0.6e 0.6e 0.6e 1.0e p :set4 
   p :getv GL_DIFFUSE GL_LIGHT1 glLightfv DROP
   0.0e -10.e 0.0e 0.0e p :set4
   p :getv GL_POSITION GL_LIGHT1 glLightfv DROP

   GL_LIGHT1 glEnable DROP \ Enable our light source
   GL_LIGHTING glEnable DROP \ Enable lighting in general
;

: status 
  CR 
  ." f=" FDEPTH . 
  ." d=" DEPTH  . 
  DEPTH 10 MIN .SN
  GetLastError ?DUP IF CR ." Error " . THEN
  glGetError ?DUP IF CR ." GL error " . THEN 
;


REQUIRE CGLPoint GLObject.f
REQUIRE FGENRAND ~ygrek/lib/neilbawd/mersenne.f

101 CONSTANT ID_ABOUT
102 CONSTANT ID_CLOSE

: M, ( addr u -- addr+4 )   OVER  ! CELL+ ;
: MC, ( addr c -- addr+4 )  OVER C! 1+ ;
: MW, ( addr c -- addr+4 )  OVER W! 2+ ;


0 [IF]
CFrameWindow SUBCLASS CGLFrameWindow

init:
     CS_OWNDC SUPER exStyle OR! \ это похоже не критично   
;
    
;CLASS
[THEN]

CFrameWindow SUBCLASS CGLWindow

  VAR _hDC      \ GDI Device Context
  VAR _hRC      \ Rendering Context
  VAR _width    \
  VAR _height   \ размеры GL окна
  CGLObjectList OBJ _scene      \ все обьекты для отрисовки

\ : createClass S" WFL CGLFrameWindow" DROP ;

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

   PrepareLight

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

0 VALUE K

0 VALUE list1

: FGENRANDMAX ( F: max -- f ) FGENRAND F* ;
: FGENRANDABS ( F: abs -- f ) 2e F* FGENRAND 0.5e F- F* ;

: test ( -- n )
  || CGLWindow aa CMessageLoop loop D: m CTimer timer CModelLoaderPLY2 ml1  CModelLoaderOFF ml2  D: filename ||

  S" bun_zipper_res2.ply2" " {s}" filename !

  NEXT-PARAM CUT-FILENAME S" spf4.exe" COMPARE
  IF 
   NEXT-PARAM DUP 0=
   IF 
    2DROP
    ELSE
    filename @ STRFREE
    " {s}" filename !
   THEN
  THEN

  \ CGLMayaModel NewObj m !
  \ S" m16.obj1" m @ => :load

  CGLObjectList NewObj TO list1

  0 TO K
  BEGIN

  K 1 < 
  WHILE
    10 0 DO
      10 0 DO
       \ CR I . J . K .
       CGLCube NewObj 
       DUP 0.75e :: CGLCube.:resize
       DUP 0e I DS>F 3e F* F+ 0e J DS>F 3e F* F+ 0e K DS>F 3e F* F- :: CGLObject.:setShift
       DUP 5e FGENRANDABS 5e FGENRANDABS 5e FGENRANDABS :: CGLObject.:setAngleSpeed
           list1 :: CGLObjectList.:add
      LOOP
    LOOP
    K 1+ TO K
  REPEAT

  CGLSimpleModel NewObj m !
  
  filename @ STR@ m @ => :model ml1 :load 
  10e 2e 10e m @ => :setShift
  0e 1e 0e m @ => :setAngleSpeed
  \ 0e 90e 0e m @ => :setAngle
  10e m @ => :resize
  m @ aa :add

  CGLSimpleModel NewObj m !
  S" m16.off" m @ => :model ml2 :load
  5e 5e -10e m @ => :setShift
  1e 0e 0e m @ => :setAngleSpeed
  0e 90e 0e m @ => :setAngle
  0.01e m @ => :resize
\  m @ aa :add

  \ 1e 0e 0e list1 :setAngleSpeed
  \ -1e 0e 0e list2 :setAngleSpeed

  list1 aa :add

  -15e -15e -40e aa :setShift

  0 aa create DROP
  SW_SHOW aa showWindow

  timer :start
  loop run
  timer :stop
  timer :ms@ CR ." Total time = " .
;

test

: save
   0 TO SPF-INIT?
   ['] ANSI>OEM TO ANSI><OEM
   TRUE TO ?GUI
   ['] NOOP TO <MAIN>
   ['] test MAINX !
   S" wflgl.exe" SAVE ;
