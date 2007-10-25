\ TODO: вывод текста
\ TODO: исправление неточности в позиционировании курсора мыши
\ TODO: попеременное послание нескольких клавиш при одновременном нажатии
\ TODO: обработка пропущенных кадров, синхронизация по времени при вызовах REFRESH'а
\ TODO: внедрение в Grid

REQUIRE WL-MODULES ~day/lib/includemodule.f
REQUIRE WFL ~day/wfl/wfl.f
REQUIRE CGLWindow ~ygrek/lib/wfl/opengl/GLWindow.f
REQUIRE CBMP24 ~ygrek/lib/spec/bmp.f
REQUIRE CGLImage ~profit/lib/wfl/openGL/GLImage.f
REQUIRE state-table ~profit/lib/chartable.f
\ REQUIRE CONST ~micro/lib/const/const.f
\ REQUIRE VK_F11 ~micro/lib/const/vk_.f

WINAPI: glColor3i OpenGL32.DLL
WINAPI: glReadPixels OpenGL32.DLL
WINAPI: wglUseFontBitmapsA OpenGL32.DLL
WINAPI: wglUseFontBitmapsW OpenGL32.DLL
WINAPI: wglUseFontOutlinesA OpenGL32.DLL
WINAPI: wglGetCurrentContext OpenGL32.DLL

WINAPI: glCallLists OpenGL32.DLL
WINAPI: glListBase OpenGL32.DLL

WINAPI: wglGetCurrentDC OpenGL32.DLL

MODULE: basic-graph

0 VALUE glwindow
\ 0 VALUE list1
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
SUPER msg wParam @ keys
0 ;

W: WM_LBUTTONDOWN ( lpar wpar msg hwnd -- res )  { | WindowRect }
SUPER msg lParam @ DUP LOWORD SWAP HIWORD ( x y ) 

RECT::/SIZE ALLOCATE THROW TO WindowRect
0 WindowRect RECT::left ! \ Set Left Value To 0
10 WindowRect RECT::right ! \ Set Right Value To Requested Width  
0 WindowRect RECT::top ! \ Set Top Value To 0
10 WindowRect RECT::bottom ! \ Set Bottom Value To Requested Height
SUPER exStyle @ FALSE SUPER style @ WindowRect AdjustWindowRectEx DROP
bmp => height @ SWAP - WindowRect RECT::top @ + SWAP
WindowRect RECT::left @ + WindowRect RECT::left @ + SWAP
WindowRect FREE THROW

( x' y' ) click
0
;

;CLASS

EXPORT

: glTHROW ( res -- ) 0= IF GetLastError THROW THEN ;

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
CGLImage NewObj TO bmp
bmp glwindow => :add
0 0 glwindow => create DROP
SW_SHOW glwindow => showWindow
drawer
loop run 
glwindow FreeObj
0 TO glwindow ;

: REFRESH ( -- ) drawer  glwindow => updateWindow ;

;MODULE

VARIABLE addr

CREATE rrr 1000 ALLOT

: r
\ 13 GetStockObject wglGetCurrentDC SelectObject 111 . .
\ 200 wglGetCurrentDC SetTextColor 111 . .
\ 200 0 0 glColor3i DROP
\ 20000 wglGetCurrentDC SetBkColor 222 . .
1000 255 0 wglGetCurrentDC wglUseFontBitmapsA 333 . .
\ 0 rrr 0 0 1000 255 0 wglGetCurrentDC wglUseFontOutlinesA 333 . . GetLastError . rrr 20 DUMP
1000 glListBase 444 . .
S" Hello" GL_UNSIGNED_BYTE SWAP glCallLists 555 . .
\ 1 GL_UNPACK_ALIGNMENT glPixelStorei glTHROW
\ 10000 CELLS ALLOCATE THROW addr !
\ addr @ GL_UNSIGNED_BYTE GL_LUMINANCE ( height @ width @ ) 100 100 0 0 glReadPixels glTHROW
\ addr @ 1000 DUMP
\ R> wglDeleteContext glTHROW
\ wglMakeCurrent glTHROW
;

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
CHAR Q asc:  r ;

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
700 300 SET-SIZE \ установка размера экрана (одновременно с его очисткой)
current-color @ colors SET-COLOR \ установка текущего цвета
\ рисование квадратика
y @ 10 + y @ DO
x @ 10 + x @ DO I J PIXEL LOOP LOOP

400 0 DO 0 I PIXEL LOOP ; START-DRAW \ BYE
\ и запуск его параметром в слово START-DRAW начинающего весь цикл отображения