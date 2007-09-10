\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   graph for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека вывода графики на граф. консоль
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|  v 1.4
\ -----------------------------------------------------------------------------
REQUIRE ConCreate ~pi/lib/wincon/wincon.f

MODULE: _GRAPH

WINAPI: SetPixel		GDI32.DLL
WINAPI: MoveToEx		GDI32.DLL
WINAPI: LineTo			GDI32.DLL
WINAPI: Ellipse			GDI32.DLL
WINAPI: RoundRect		GDI32.DLL
WINAPI: LoadImageA		USER32.DLL
WINAPI: StretchBlt		GDI32.DLL
WINAPI: GetObjectA		GDI32.DLL
WINAPI: DrawIcon		USER32.DLL
WINAPI: GetPixel		GDI32.DLL
WINAPI: Arc			GDI32.DLL
WINAPI: Pie			GDI32.DLL

0
CELL -- bmType
CELL -- bmWidth
CELL -- bmHeight
CELL -- bmWidthBytes
2 -- bmPlanes
2 -- bmBitsPixel
CELL -- bmBits
CONSTANT BITMAP
0 VALUE bitmap
BITMAP ALLOCATE THROW TO bitmap

EXPORT

\ Перемещает точку начала рисования для Draw
: MoveTo ( x y -> )
	0 -ROT SWAP phdc MoveToEx DROP ;

\ Рисует линию от текуще точки рисования
: Draw ( x y -> )
	SWAP phdc LineTo DROP ;

\ Нарисовать точку
: Point ( x y -> )
	SWAP color -ROT phdc SetPixel DROP ;

\ Нарисовать линию
: Line ( x y x1 y1 -> )
	2SWAP MoveTo Draw ;

\ Нарисовать круг
: Circle ( x y d -> )
	>R SWAP 2DUP R@ + SWAP R> + SWAP 2SWAP phdc Ellipse DROP ;

\ Нарисовать элипс
: Ellips ( x y x1 y1 -> )
	SWAP 2SWAP SWAP phdc Ellipse DROP ;

\ Нарисовать квадрат
: Square ( x y l -> )
	>R SWAP 2DUP R@ + SWAP R> + SWAP 2SWAP phdc Rectangle DROP ;

\ Нарисовать прямоугольник
: Rect ( x y x1 y1 -> )
         SWAP 2SWAP SWAP phdc Rectangle DROP ;

\ Нарисовать прямоугольник c кругленными концами
: RRect ( x y x1 y1 ll lh -> )
         SWAP 2SWAP SWAP 2>R 2SWAP SWAP 2R> 2SWAP phdc RoundRect DROP ;

\ Нарисовать квадрат  c кругленными концами
: RSquare ( x y l ll lh-> )
	SWAP 2SWAP >R -ROT 2SWAP SWAP 2DUP R@ + SWAP R> + SWAP 2SWAP phdc RoundRect DROP ;

\ Вывести изображение bmp из файла на консоль
: Image ( addr u x y -> )
	{ x y | hbitmap bhdc pbhdc }
	DROP >R 0x10 0 0 0 R> hwdwin LoadImageA TO hbitmap
	bitmap 24 hbitmap GetObjectA DROP
	phdc CreateCompatibleDC TO bhdc
	hbitmap bhdc SelectObject TO pbhdc
	0xCC0020 bitmap bmHeight @ bitmap bmWidth @ 0 0 bhdc
	bitmap bmHeight @ bitmap bmWidth @ y x phdc StretchBlt DROP
	hbitmap DeleteObject DROP
	bhdc DeleteDC DROP ;

\ Возвращает цвет пиксела в указанных координатах
: GPixel ( x y -> RGB )
	SWAP phdc GetPixel ;
	
\ Вывести иконку ico из файла на консоль
: Icon ( addr u x y -> )
	2SWAP DROP >R 0x10 0 0 1 R> hwdwin LoadImageA DUP
	2SWAP SWAP phdc DrawIcon DROP DeleteObject DROP ;
\ Дуга
\ X1, Y1: Веpхний левый угол огpаничивающего пpямоугольника.
\ X2, Y2: Пpавый нижний угол огpаничивающего пpямоугольника.
\ X3, Y3: Начальная точка дуги.
\ X4, Y4: Конечная точка дуги. 
: Arcs  ( x1 y1 x2 y2 x3 y3 x4 y4 -> )
	{ x1 y1 x2 y2 }
	SWAP 2SWAP SWAP y2 x2 y1 x1 phdc Arc DROP ;

\ Сектор
\ X1, Y1: Веpхний левый угол огpаничивающего пpямоугольника.
\ X2, Y2: Пpавый нижний угол огpаничивающего пpямоугольника.
\ X3, Y3: Начальная точка сектора.
\ X4, Y4: Конечная точка сектора. 
: Sector ( x1 y1 x2 y2 x3 y3 x4 y4 -> )
	{ x1 y1 x2 y2 }
	SWAP 2SWAP SWAP y2 x2 y1 x1 phdc Pie DROP ;

;MODULE

\EOF

Point		( x y -> ) - нарисовать точку
MoveTo		( x y -> ) - перемещает точку начала рисования для Draw
Draw		( x y -> ) - рисует линию от текуще точки рисования
Line		( x y x1 y1 -> ) - нарисовать линию
Square		( x y l -> ) - нарисовать квадрат
Rect 		( x y x1 y1 -> ) - нарисовать прямоугольник
Ellips		( x y x1 y1 -> ) - нарисовать элипс
Circle		( x y d -> ) - нарисовать круг
RRect		( x y x1 y1 h l -> ) - нарисовать прямоугольник c скругленными углами
RSquare		( x y l ll lh-> ) - нарисовать квадрат  c скругленными углами
Image		( c-addr u x y -> ) - вывести изображение bmp из файла на консоль
Icon		( c-addr u x y -> ) - вывести иконку ico из файла на консоль
GPixel		( x y -> RGB ) - возвращает цвет пикселz в указанных координатах
Arcs		( x1 y1 x2 y2 x3 y3 x4 y4 -> ) - дуга
Sector		( x1 y1 x2 y2 x3 y3 x4 y4 -> ) - сектор
