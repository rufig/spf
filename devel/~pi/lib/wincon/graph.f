\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   graph for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека вывода графики на граф. консоль
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|  v 1.3
\ -----------------------------------------------------------------------------
REQUIRE wincon	~pi/lib/wincon/wincon.f

WINAPI: SetPixel		GDI32.DLL
WINAPI: MoveToEx		GDI32.DLL
WINAPI: LineTo			GDI32.DLL
WINAPI: Ellipse			GDI32.DLL
WINAPI: RoundRect		GDI32.DLL
WINAPI: LoadImageA		USER32.DLL
WINAPI: StretchBlt		GDI32.DLL
WINAPI: GetObjectA		GDI32.DLL

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

\EOF

Point		( x y -> ) - нарисовать точку
MoveTo		( x y -> ) - перемещает точку начала рисования для Draw
Draw		( x y -> ) - рисует линию от текуще точки рисования
Line		( x y x1 y1 -> ) - нарисовать линию
Square		( x y l -> ) - нарисовать квадрат
Rect 		( x y x1 y1 -> ) - нарисовать прямоугольник
Ellips		( x y x1 y1 -> ) - нарисовать элипс
Circle		( x y d -> ) - нарисовать круг
RRect		( x y x1 y1 h l -> ) - нарисовать прямоугольник c кругленными концами
RSquare		( x y l ll lh-> ) - нарисовать квадрат  c кругленными концами
Image		( addr u x y -> ) - вывести изображение bmp из файла на консоль
