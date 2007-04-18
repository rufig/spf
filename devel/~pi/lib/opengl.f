\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   OpenGl for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека для работы с opengl v0.01
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|
\ -----------------------------------------------------------------------------
S" lib\include\float2.f" INCLUDED
MODULE: HIDDEN

WINAPI: CreateWindowExA		USER32.DLL
WINAPI: GetSystemMetrics	USER32.DLL
WINAPI: GetDC			USER32.DLL
WINAPI: ReleaseDC		USER32.DLL
WINAPI: ShowCursor		USER32.DLL
WINAPI: GetAsyncKeyState	USER32.DLL

WINAPI: ChoosePixelFormat	GDI32.DLL
WINAPI: SetPixelFormat		GDI32.DLL
WINAPI: SwapBuffers		GDI32.DLL

WINAPI: wglCreateContext	OPENGL32.DLL
WINAPI: wglMakeCurrent		OPENGL32.DLL
WINAPI: glHint			OPENGL32.DLL
WINAPI: glMatrixMode		OPENGL32.DLL
WINAPI: glClear			OPENGL32.DLL
WINAPI: glLoadIdentity		OPENGL32.DLL
WINAPI: glTranslated		OPENGL32.DLL
WINAPI: glPointSize		OPENGL32.DLL
WINAPI: glBegin			OPENGL32.DLL
WINAPI:	glVertex2d		OPENGL32.DLL
WINAPI:	glEnd			OPENGL32.DLL
WINAPI: glColor3b		OPENGL32.DLL
WINAPI: glRotated		OPENGL32.DLL
WINAPI: glLineWidth		OPENGL32.DLL
WINAPI: glPolygonMode		OPENGL32.DLL
WINAPI: glEnable		OPENGL32.DLL
WINAPI: glDisable		OPENGL32.DLL

WINAPI: gluPerspective		GLU32.DLL

0
2 -- nSize
2 -- nVersion
CELL -- dwFlags
1 -- iPixelType
1 -- cColorBits
1 -- cRedBits
1 -- cRedShift
1 -- cGreenBits
1 -- cGreenShift
1 -- cBlueBits
1 -- cBlueShift
1 -- cAlphaBits
1 -- cAlphaShift
1 -- cAccumBits
1 -- cAccumRedBits
1 -- cAccumGreenBits
1 -- cAccumBlueBits
1 -- cAccumAlphaBits
1 -- cDepthBits
1 -- cStencilBits
1 -- cAuxBuffers
1 -- iLayerType
1 -- bReserved
CELL -- dwLayerMask
CELL -- dwVisibleMask
CELL -- dwDamageMask
CONSTANT PIXELFORMATDESCRIPTOR
0 VALUE pfd		\ структура для opengl
PIXELFORMATDESCRIPTOR ALLOCATE THROW TO pfd
0x25 pfd dwFlags !
32 pfd cColorBits C! 
pfd FREE THROW

0 VALUE glhandle	\ хендл окна
0 VALUE glhdc		\ хендл контекста


EXPORT

\ Высота изображения экрана в пикселях
: VScreen ( -> n )
	1 GetSystemMetrics ;

\ Ширина изображения экрана в пикселях
: HScreen ( -> n )
	0 GetSystemMetrics ;

\ Число float со стека float на стек данных
: F>FL  ( -> f ) ( F: f -> )
	[                 
	0x8D C, 0x6D C, 0xFC C, 
	0xD9 C, 0x5D C, 0x00 C, 
	0x87 C, 0x45 C, 0x00 C, 
	0xC3 C, ] ;

\ Число double со стека float на стек данных
: F>DL ( -> d ) ( F: f -> )
	FLOAT>DATA SWAP ;

\ Переконвертировать число на стеке во float
: S>FL ( n -> f )
	DS>F F>FL ;

\ Переконвертировать число на стеке в double
: S>DL ( n -> d )
	DS>F F>DL ;

\ Аспект соотношения ширины и высоты
: AScreen ( -> d )
	HScreen DS>F VScreen S>D D>F F/ F>DL ;

\ Показать курсор на экране
: ShowCursore ( -> )
	1 ShowCursor DROP ;

\ Спрятать курсор c экрана
: HideCursore ( -> )
	0 ShowCursor DROP ;

\ Выход
: glClose ( -> )
	glhdc glhandle ReleaseDC 0 ExitProcess ;

\ Проверяет нажата ли клавиша по заданному коду
: key ( n -- flag )
	GetAsyncKeyState ;

\ Инициализация glокна
: glOpen ( -> )
 0 0 0 0 VScreen HScreen 0 0 0x90000000 S" edit" DROP DUP 8 CreateWindowExA
 DUP TO glhandle GetDC TO glhdc
 pfd DUP glhdc ChoosePixelFormat glhdc SetPixelFormat DROP
 glhdc wglCreateContext glhdc wglMakeCurrent DROP
 0x1102 0xC50 glHint DROP
 0x1701 glMatrixMode DROP
 100 S>DL 1 DS>F 10 DS>F F/ F>DL AScreen 90 S>DL gluPerspective DROP
 0x1700 glMatrixMode DROP ;

\ Очистить буфер изображения
: Cls ( -> )
	0x4000 glClear DROP ;

\ Показ буфера изображения (где рисовали)
: View ( -> )
	glhdc SwapBuffers DROP ;

\ Единичная матрица
: SingleMatrix ( -> )
	glLoadIdentity DROP ;

\ Выполняет сдвиг текущей матрицы на вектор (x, y, z).
: ShiftMatrix ( F: f f f -> )
	F>DL F>DL F>DL glTranslated DROP ;

\ Размер точки
: PointSize ( n -> )
	S>FL glPointSize DROP ;

\ Вывести 2D точку на экран (x,y)
: Point ( F: f f -> )
	0 glBegin DROP F>DL F>DL glVertex2d DROP glEnd DROP ;

\ Установить цвет (B G R)
: Color ( n n n -> )
	glColor3b DROP ;

\ Поворачивает текущую матрицу на заданный угол вокруг заданного вектора.
\ z y x angle
: RotatedMatrix ( F: f f f f -> )
	F>DL F>DL F>DL F>DL glRotated DROP ;

\ Вывести 2D линию (X Y L H)
: Line ( F: f f f f -> )
	1 glBegin DROP
	F>DL F>DL glVertex2d DROP
	F>DL F>DL glVertex2d DROP
	glEnd DROP ;

\ Ширина линии
: LineSize ( n -> )
	S>FL glLineWidth DROP ;

\ Вывести 2D треугольник (X Y X1 Y1 X2 Y2)
: Triangle ( F: f f f f f f -> )
	4 glBegin DROP
	F>DL F>DL glVertex2d DROP
	F>DL F>DL glVertex2d DROP
	F>DL F>DL glVertex2d DROP
	glEnd DROP ;

\ Рисование фигур проволочным стилем
: GlLine ( -> )
	0x1B01 0x408 glPolygonMode DROP ;

\ Рисование фигур закрашенным стилем
: GlFill ( -> )
	0x1B02 0x408 glPolygonMode DROP ;

\ 2D прямоугольник (X Y L H)
: Rectangle ( F: f f f f -> )
	7 glBegin DROP
	F>DL 2DUP F>DL 2DUP 2>R glVertex2d DROP
	F>DL 2DUP 2R> glVertex2d DROP
	F>DL 2DUP 2>R glVertex2d DROP
	2R> glVertex2d DROP
	glEnd DROP ;

\ Сглаживание
: Smoothing ( -> )
	0xB10 glEnable DROP ;

\ Убрать сглаживание
: NoSmoothing ( -> )
	0xB10 glDisable DROP ;


STARTLOG

;MODULE

0 VALUE msec					\ для синхранизации
0 VALUE msei
0.0E FVALUE theta				\ угол поворота матрицы
: main
 glOpen						\ инициализация opengl
 GlLine						\ рисуем проволочным стилем
 Smoothing					\ сглаживание точек
 HideCursore					\ спрятать курсор
 0x1B key DROP					\ непонимаю но иначе неработает
 BEGIN
  TIMER@ DROP TO msei				\ синхронизация
  msei msec <> IF
   msei TO msec
   Cls						\ очистка экрана
   SingleMatrix					\ установим еденичную матрицу
   0.0E 0.0E -5.0E ShiftMatrix			\ отодвигаем матрицу
   10 PointSize					\ размер точки
   theta 0.0E 0.0E 1.0E RotatedMatrix           \ крутим матрицу вокруг осей
   0 0 100 Color				\ установим красный цвет
   0.0E 0.0E Point				\ нарисуем точки
   0.0E 1.0E Point
   0.0E 2.0E Point
   0.0E 3.0E Point
   0.0E 4.0E Point
   0 100 0 Color				\ установим зеленый цвет
   3 LineSize                                   \ ширина линии
   0.0E 0.0E 4.0E 0.0E Line                     \ нарисуем линию
   100 0 0 Color				\ установим синий цвет
   0.0E 0.0E 0.5E 2.0E 2.0E 1.5E Triangle
   -4.0E 4.0E -1.0E -2.0E Rectangle
   View						\ покажем что нарисовали
   theta 0.5E F+ FTO theta
  THEN
 0x1B key UNTIL					\ цикл пока не нажата ESC
 glClose					\ Закрываем opengl приложение
;

main


\EOF

glOpen		( -> ) - инициализация glокна
glClose		( -> ) - выход
key		( n -> flag ) - нажата ли клавиша по заданному коду

--- Экран ---
VScreen		( -> n ) - высота изображения экрана в пикселях
HScreen		( -> n ) - ширина изображения экрана в пикселях
AScreen		( -> d ) - аспект соотношения ширины и высоты
ShowCursore	( -> ) - показать курсор на экране
HideCursore	( -> ) - спрятать курсор c экрана
Cls		( -> ) - очистить буфер изображения
View		( -> ) - показ буфера изображения (где рисовали)
SingleMatrix	( -> ) - единичная матрица
ShiftMatrix	( F: f f f -> ) - выполняет сдвиг текущей матрицы на вектор
				(x, y, z).
RotatedMatrix	( F: f f f f -> ) - поворачивает текущую матрицу на заданный угол
				вокруг заданного вектора z y x angle.

--- float ---
F>FL		( -> f ) (F: f -- ) - число float со стека float на стек данных
S>FL		( n -> f ) - переконвертировать число на стеке во float
F>DL		( -> d ) ( F: f -> ) - число double со стека float на стек данных
S>DL		( n -> d ) - переконвертировать число на стеке в double

--- Элементы ---

Point		( F: f f -> ) - 2D точка на экран (x,y)
Line		( F: f f f f -> ) - 2D линия (x,y,l,h)
Triangle	( F: f f f f f f -> ) - 2D треугольник (X Y X1 Y1 X2 Y2)
Rectangle	( F: f f f f -> ) - 2D прямоугольник (X Y L H)

--- Свойства элементов ---
Color		( n n n -> ) - установить цвет (B G R)
PointSize	( n -> ) - размер точки
GlLine		( -> ) - рисование фигур проволочным стилем
GlFill		( -> ) - рисование фигур закрашенным стилем
Smoothing	( -> ) - сглаживание
NoSmoothing	( -> ) - убрать сглаживание

