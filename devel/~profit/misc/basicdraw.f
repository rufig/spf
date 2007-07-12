REQUIRE WFL ~day/wfl/wfl.f
REQUIRE CGLWindow ~ygrek/lib/wfl/opengl/GLWindow.f
REQUIRE CBMP24 ~ygrek/lib/spec/bmp.f
REQUIRE CGLImage ~profit/lib/wfl/openGL/GLImage.f
REQUIRE state-table ~profit/lib/chartable.f
REQUIRE CONST ~micro/lib/const/const.f
REQUIRE VK_F11 ~micro/lib/const/vk_.f


WINAPI: wglUseFontBitmapsA OpenGL32.DLL
WINAPI: wglGetCurrentContext OpenGL32.DLL
WINAPI: wglDeleteContext OpenGL32.DLL
WINAPI: wglCreateContext OpenGL32.DLL
WINAPI: wglMakeCurrent OpenGL32.DLL

WINAPI: glCallLists OpenGL32.DLL
WINAPI: glListBase OpenGL32.DLL

MODULE: basic-graph

0 VALUE glwindow
0 VALUE list1
0 VALUE bmp
VECT drawer

EXPORT

: set-reactions ( "state-table -- )
' >BODY CELL+ current-state! ;

256 state-table keys
' 2DROP ->VECT click ( x y -- )

DEFINITIONS

CGLWindow SUBCLASS CGLMyWindow
W: WM_KEYDOWN ( lpar wpar msg hwnd -- res )
2DROP NIP keys
0 ;

W: WM_LBUTTONDOWN ( lpar wpar msg hwnd -- res )  { | WindowRect }
2DROP DROP DUP LOWORD SWAP HIWORD ( x y ) 

RECT::/SIZE ALLOCATE THROW TO WindowRect
0 WindowRect RECT::left ! \ Set Left Value To 0
10 WindowRect RECT::right ! \ Set Right Value To Requested Width  
0 WindowRect RECT::top ! \ Set Top Value To 0
10 WindowRect RECT::bottom ! \ Set Bottom Value To Requested Height
glwindow => exStyle @ FALSE glwindow => style @ WindowRect AdjustWindowRectEx DROP
bmp => height @ SWAP - WindowRect RECT::top @ + SWAP
WindowRect RECT::left @ + WindowRect RECT::left @ + SWAP
WindowRect FREE THROW

( x' y' ) click
0 ;

;CLASS

EXPORT

: CLS ( -- ) bmp => :cls ;
: PIXEL ( x y -- ) bmp => :pixel ;
: SET-COLOR ( r g b -- ) bmp => :set-color ;
: SET-SIZE ( w h -- ) 2DUP bmp => :set-size
SWAP TRUE -ROT
glwindow => getWindowRect 2SWAP 2DROP ( true height width y x )
glwindow => moveWindow ;

: START-DRAW ( xt -- n ) TO drawer
|| CMessageLoop loop ||
CGLMyWindow NewObj TO glwindow
CGLObjectList NewObj TO list1
CGLImage NewObj TO bmp
bmp list1 => :add
list1 glwindow => :add
0 glwindow => create DROP
SW_SHOW glwindow => showWindow
drawer
loop run ;

: REFRESH ( -- ) drawer  glwindow => updateWindow ;

;MODULE

/TEST

\ Примерный код

\ Три переменные для показа нашего квадрата
50 ->VARIABLE x
50 ->VARIABLE y
1 ->VARIABLE current-color

set-reactions keys \ Установка реакций на нажатия клавиш

\ WSAD -- вверх, вниз, влево, вправо
CHAR W asc:  10 y +! REFRESH ;
CHAR S asc: -10 y +! REFRESH ;
CHAR A asc: -10 x +! REFRESH ;
CHAR D asc:  10 x +! REFRESH ;

\ F11 -- смена цвета
VK_F11 asc:
current-color 1+!
current-color @ 4 = IF 1 current-color ! THEN
REFRESH ;

\ задание трёх цветов
3 state-table colors
1 asc: 0 0 200 ;
2 asc: 0 200 0 ;
3 asc: 200 0 0 ;

:NONAME ( x y -- )
y ! x ! REFRESH ; TO click

\ Создание слова-отрисовщика
:NONAME
600 400 SET-SIZE \ установка размера экрана (одновременно с его очисткой)
current-color @ colors SET-COLOR \ установка текущего цвета
\ рисование квадратика
y @ 10 + y @ DO
x @ 10 + x @ DO I J PIXEL LOOP LOOP
; START-DRAW \ BYE
\ и запуск его параметром в слово START-DRAW начинающего весь цикл отображения


\ wglGetCurrentContext
\ CreateCompatibleDC DUP wglCreateContext >R
\ 1000 255 0 R@ wglUseFontBitmapsA
\ 1000 glListBase
\ S" Hello Win32 OpenGL World" GL_UNSIGNED_BYTE SWAP glCallLists
\ 1 GL_UNPACK_ALIGNMENT glPixelStorei DROP
\ 1000 CELLS ALLOCATE THROW addr !
\ addr @ GL_UNSIGNED_BYTE GL_LUMINANCE ( height @ width @ ) 100 100 0 0 glReadPixels DROP
\ addr @
\ R> wglDeleteContext DROP \ THROW
\ wglMakeCurrent