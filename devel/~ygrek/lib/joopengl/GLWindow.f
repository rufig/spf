\ Last changes 07/05/2005

\ 07.May.2005  ~ygrek
\  Небольшие фиксы

\ TODO: Разобраться с многочисленными багами, глюками и ошибками
\  которые появляются при запуске. Такие как - GL error 502 итп

\ OpenGL demo in Forth  
\ with jOOP by ~day
\ (c) yGREK heretix mailto:heretix@yandex.ru
\ Started 20/02/2005

REQUIRE GLObject      ~ygrek/lib/joopengl/GLObject.f
REQUIRE FrameWindow   ~day/joop/win/framewindow.f
REQUIRE RECT          ~ygrek/lib/joopengl/extra.f 
REQUIRE glBegin       ~ygrek/lib/data/opengl.f  
REQUIRE POPUPMENU     ~day/joop/win/menu.f
REQUIRE List          ~day/joop/lib/list.f

~day\joop\samples\about_dlg.f

HERE 

101 CONSTANT ID_ABOUT
102 CONSTANT ID_CLOSE

FDOUBLE

: status CR ." f=" FDEPTH . ." d=" DEPTH DUP . HEX 10 < IF DEPTH .SN THEN
  GetLastError ?DUP IF CR ." Error " . THEN
  glGetError ?DUP IF CR ." GL error " . THEN
  \ Если это закоментарить то не запуститься
  \ Потому что получениу инфы об ошибке очищает внутренний флаг ошибки
  \ и дяльше будет выполняться нормально. Где ошибка я не знаю.
  DECIMAL
;
: M, ( addr u -- addr+4 )   OVER  ! CELL+ ;
: MC, ( addr c -- addr+4 )  OVER C! 1+ ;
: MW, ( addr c -- addr+4 )  OVER W! 2+ ;


CLASS: GLWinClass <SUPER WinClass

: :init
    \ ." Init."
     own :init
     S" OpenGL Class" DROP lpszClassName !
     style @ CS_OWNDC OR style !  \ это похоже не критично   
     \ ." Init done."
;
     
;CLASS

GLWinClass :newLit VALUE iGLClass

: show ( node -- ) <data @ DUP :draw :rotate 0 ;

<< :maximize
<< :add \ добавить обьект для отрисовки
CLASS: GLWindow <SUPER FrameWindow

  CELL VAR hDC          \ Private GDI Device Context
  CELL VAR hRC          \ Permanent Rendering Context
  CELL VAR width        \
  CELL VAR height       \ размеры GL окна
  List OBJ scene        \ все обьекты для отрисовки

: :init
   own :init
   600 width ! 400 height ! NULL hDC ! NULL hRC !
   NULL iGLClass <hbrBackground !
   WS_OVERLAPPEDWINDOW WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR vStyle !
   WS_EX_APPWINDOW WS_EX_WINDOWEDGE OR vExStyle !    
   iGLClass vClass !
;


M: ID_ABOUT
    S" OpenGL Window class for jOOP"
    S" yGREK heretix (c) 25/02/2005" 
    self ShowAbout
;

\ M: ID_CLOSE self :free ; \ именно self, а не own
 
: :createPopup
   POPUPMENU
     S" About" ID_ABOUT MENUITEM
  \   S" Close" ID_CLOSE MENUITEM
   END-MENU
;


: :initGL
   \ CR ." InitGL. "
   GL_SMOOTH glShadeModel  DROP \ Enable Smooth Shading

   0.5E float 0E float  0E float 0E float glClearColor DROP \ Black Background

   1E double glClearDepth DROP      \ Depth Buffer Setup

   GL_DEPTH_TEST glEnable DROP      \ Enables Depth Testing

   GL_LEQUAL glDepthFunc  DROP      \ The Type Of Depth Testing To Do

   GL_NICEST GL_PERSPECTIVE_CORRECTION_HINT glHint DROP     
                   \ Really Nice Perspective Calculations
   \ ." InitGL done."
;

: :resize { \ WindowRect -- } \ Resize And Initialize The GL Window
\ Подогнать запрашиваемые размеры к возможным GLевским
  \     CR ." Request dimensions : " width @ . height @ .
       RECT::/SIZE ALLOCATE THROW TO WindowRect                                 
                 0 WindowRect RECT::left ! \ Set Left Value To 0                 
          width @ WindowRect RECT::right ! \ Set Right Value To Requested Width  
                  0 WindowRect RECT::top ! \ Set Top Value To 0                  
        height @ WindowRect RECT::bottom ! \ Set Bottom Value To Requested Height
                                                                                 
       vExStyle @ FALSE vStyle @ WindowRect AdjustWindowRectEx DROP              
                                                                                 
       WindowRect RECT::bottom @ WindowRect RECT::top @ - height !               
       WindowRect RECT::right @ WindowRect RECT::left @ - width !                
       WindowRect FREE THROW             
   \    CR ." Changed dimensions to : " width @ . height @ .                                 

 \ Теперь устанавливаем GL параметры окна
        height @ 0 = IF 1 height ! THEN  \ Prevent A Divide By Zero
        height @ width @ 0 0 glViewport DROP    \ Reset The Current Viewport

        GL_PROJECTION glMatrixMode DROP \ Select The Projection Matrix
        glLoadIdentity  DROP            \ Reset The Projection Matrix
        \ Calculate The Aspect Ratio Of The Window
        100e double \ far clipping plane
        0.1e double \ near clipping plane
        width @ DS>F height @ DS>F F/ double \ aspect ratio
        45e double  \ Field of View Y-coordinate
        gluPerspective DROP 

        GL_MODELVIEW glMatrixMode DROP  \ Select The Modelview Matrix
        glLoadIdentity  DROP            \ Reset The Modelview Matrix
;

: :create { \ pfd PixelFormat WindowRect -- } 
  status
  own :create
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

   hwnd @ GetDC hDC !
   hDC @ 0= IF
    S" Can't create a GL Device Context." own :showMessage
    own :free BYE
   THEN

   pfd hDC @ ChoosePixelFormat TO PixelFormat
   PixelFormat 0= IF
    S" Can't Find A Suitable PixelFormat." own :showMessage 
    status
    own :free BYE
   THEN

   pfd PixelFormat hDC @ SetPixelFormat 0= IF
    S" Can't set this pixel format." own :showMessage 
    own :free BYE
   THEN

   pfd FREE THROW \ больше не нужен

   hDC @ wglCreateContext hRC !
   hRC @ 0= IF
    S" Can't Create A GL Rendering Context." own :showMessage
    own :free BYE
   THEN

   hRC @ hDC @ wglMakeCurrent  \ Try To Activate The Rendering Context
   0= IF
    S" Can't Activate The GL Rendering Context." own :showMessage 
    own :free BYE
   THEN

   own :resize      \ Set Up Our Perspective GL Screen

   own :initGL
;

W: WM_CREATE
    0 20 1 handle @ SetTimer DROP
   \ CR ." Timer set."
;

: :maximize SW_MAXIMIZE handle @ ShowWindow DROP ;

: :add ( obj -- ) scene :addObject ;

W: WM_TIMER  \ Here's Where We Do All The Drawing
      GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear DROP  
                                   \ Clear Screen And Depth Buffer
      ['] show scene :doEach 

      hDC @ wglSwapBuffers DROP \ Doublebuffering :)
;

: onPaint
      GL_COLOR_BUFFER_BIT GL_DEPTH_BUFFER_BIT OR glClear DROP  
                                   \ Clear Screen And Depth Buffer
      ['] show scene :doEach 

      hDC @ wglSwapBuffers DROP \ Doublebuffering :)
;

: :free          \ Properly Kill The Window
\  ." Kill "
  1 handle @ KillTimer DROP

  hRC @ IF                                                                                  
   NULL NULL wglMakeCurrent 0= IF \ Are We Able To Release The DC And RC Contexts?
   CR ." Release Of DC And RC Failed." THEN
   hRC @ wglDeleteContext 0= IF     \ Are We Able To Delete The RC?
   CR ." Release Rendering Context Failed." THEN
   NULL hRC !
  THEN

  hDC @ hwnd @ ReleaseDC 0= 
  hDC @ AND IF                      \ Are We Able To Release The DC
          CR ." Release Device Context Failed."
          NULL hDC !
          THEN

 scene :free 
 \ ." done."
 \ own :free \ по идее это нужно, но вызывает ошибку
;

: :move
  height !
  width !
  own :resize
  width @ height @ own :move
;

W: WM_SIZE
   lparam @ LOWORD width !
   lparam @ HIWORD height !
   own :resize
;

;CLASS
HERE SWAP - .( Size of GLWindow class is ) . .( bytes) CR
