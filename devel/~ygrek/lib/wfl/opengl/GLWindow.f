\ $Id$

REQUIRE WL-MODULES ~day/lib/includemodule.f

NEEDS ~day/wfl/wfl.f
NEEDS ~ygrek/lib/wfl/opengl/common.f
NEEDS ~ygrek/lib/wfl/opengl/GLCanvas.f \ для удобства подключается сразу

: M, ( addr u -- addr+4 )   OVER  ! CELL+ ;
: MC, ( addr c -- addr+4 )  OVER C! 1+ ;
: MW, ( addr c -- addr+4 )  OVER W! 2+ ;

\ -----------------------------------------------------------------------

\ Контекст рисовния OpenGL
\ Состоит из Device Context (GDI) и Rendering Context (GL)
CDC SUBCLASS CGLContext
  VAR _hRC

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
   SUPER createDC DROP
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

\ Клиентская область окна пригодная для рисования OpenGL
CLASS CGLDrawArea

  VAR _hwnd
  CGLContext OBJ _context

init: ;
dispose: ;

: hwnd _hwnd @ ;

: :enable ( -- ) _hwnd @ _context :enable ;
: :disable ( -- ) _context :disable ;
: :swapBuffers ( -- ) _context checkDC wglSwapBuffers DROP ;

: :initialize ( hwnd -- )
   _hwnd !
   { | pfd PixelFormat }
   gl-status
   PIXELFORMATDESCRIPTOR::/SIZE ALLOCATE THROW TO pfd
           \ pfd Tells Windows How We Want Things To Be
   pfd
   PIXELFORMATDESCRIPTOR::/SIZE MW, \ Size Of This Pixel Format Descriptor
   1 MW,                            \ Version Number
   PFD_DRAW_TO_WINDOW               \ Format Must Support Window
   PFD_SUPPORT_OPENGL OR            \ Format Must Support OpenGL
   PFD_DOUBLEBUFFER OR M,           \ Must Support Double Buffering
   PFD_TYPE_RGBA MC,                \ Request An RGBA Format
   16 MC,                           \ Select Our Color Depth
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

\   gl-status
\   pfd PIXELFORMATDESCRIPTOR::/SIZE DUMP
   \ ." PFD created"
   gl-status

   _hwnd @ _context createDC DROP

      pfd _context checkDC ChoosePixelFormat TO PixelFormat
      PixelFormat 0= S" Can't Find A Suitable PixelFormat." SUPER abort

      pfd PixelFormat _context checkDC SetPixelFormat 0= S" Can't set this pixel format." SUPER abort

      pfd FREE THROW \ больше не нужен

      _context :createRC 

   _context release
   ;

;CLASS

\ -----------------------------------------------------------------------

\ Прокси обьединяющий CGLDrawArea и CGLCanvas
\ canvas устанавливается снаружи, <параметр>
CLASS CGLDrawable

  CGLDrawArea OBJ _area
  VAR _v \ область отрисовки

: canvas _v @ ;
: canvas! _v ! ;

: :draw
   _area :enable
   canvas => :display
   _area :swapBuffers
   _area :disable ;

: :resize { w h | WindowRect -- }

   RECT::/SIZE ALLOCATE THROW TO WindowRect

   0 WindowRect RECT::left !
   w WindowRect RECT::right !
   0 WindowRect RECT::top !
   h WindowRect RECT::bottom !

   GWL_EXSTYLE _area hwnd GetWindowLongA
   FALSE 
   GWL_STYLE _area hwnd GetWindowLongA
   WindowRect AdjustWindowRectEx DROP

   WindowRect RECT::bottom @ WindowRect RECT::top @ - ( h )
   WindowRect RECT::right @ WindowRect RECT::left @ - ( h w )
   WindowRect FREE THROW

   SWAP

   ?DUP 0 = IF 1 THEN

   \ Теперь устанавливаем GL параметры окна
   _area :enable
   ( w h ) canvas => :resize
   _area :disable

   :draw
;

: :create ( hwnd -- ) _area :initialize ;

;CLASS

\ -----------------------------------------------------------------------

\ Окно с рамкой
CFrameWindow SUBCLASS CGLWindow

 CGLDrawable OBJ _gl

init:
   NULL SUPER class hbrBackground ! \ we are responsible for erasing background
   \ but we are lazy and do nothing with WM_ERASEBKGND :)

   WS_OVERLAPPEDWINDOW WS_CLIPSIBLINGS OR WS_CLIPCHILDREN OR SUPER style OR!
   WS_EX_APPWINDOW WS_EX_WINDOWEDGE OR SUPER exStyle OR! 
;

dispose: ;

: canvas! _gl canvas! ;

: :setupTimer 0 20 1 SUPER hWnd @ SetTimer DROP ;

W: WM_TIMER _gl :draw 0 ;

W: WM_SIZE ( -- n )
   SUPER msg lParam @ LOWORD
   SUPER msg lParam @ HIWORD
   ( w h ) _gl :resize
   0
;

W: WM_CREATE ( -- n )
    :setupTimer
    SUPER hWnd @ _gl :create
    0 ;

W: WM_DESTROY ( -- n )
   0 0 PostQuitMessage DROP
;

;CLASS

\ -----------------------------------------------------------------------

\ Контрол для встраивания в диалоги
CStatic SUBCLASS CGLControl

 CGLDrawable OBJ _gl

init: ;
dispose: ;

: canvas! _gl canvas! ;

: :setupTimer ( -- ) 0 20 1 SUPER hWnd @ SetTimer DROP ;

: create ( id h -- hwnd )
   SUPER create ( hwnd )
   DUP _gl :create
   :setupTimer
   SUPER checkWindow SUPER attach ;

W: WM_TIMER _gl :draw 0 ;

W: WM_SIZE ( -- n )
   SUPER msg lParam @ LOWORD
   SUPER msg lParam @ HIWORD
   ( w h ) _gl :resize
   0
;

W: WM_DESTROY ( -- n )
   0 0 PostQuitMessage DROP
;

;CLASS

\ -----------------------------------------------------------------------

/TEST

: test ( -- n )
  || CGLWindow aa  CMessageLoop loop  CGLSimpleCanvas z ||

  CGLCube NewObj >R
  2e 3e 4e R@ => :setAngleSpeed
  0e 0e -5e R@ => :setShift
  0.1e R@ => :resize
  R> z :add

  z this aa canvas!

  0 0 aa create DROP
  SW_SHOW aa showWindow

  loop run
;

test

: save
   0 TO SPF-INIT?
   ['] ANSI>OEM TO ANSI><OEM
   TRUE TO ?GUI
   ['] test TO <MAIN>
   S" wflgl.exe" SAVE ;
