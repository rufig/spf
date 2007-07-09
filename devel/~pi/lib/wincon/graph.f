\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   graph for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека вывода графики на граф. консоль
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|
\ -----------------------------------------------------------------------------
REQUIRE wincon	~pi/lib/wincon/wincon.f

WINAPI: SetPixel		GDI32.DLL
WINAPI: MoveToEx		GDI32.DLL
WINAPI: LineTo			GDI32.DLL
WINAPI: Ellipse			GDI32.DLL
WINAPI: RoundRect		GDI32.DLL

\ Нарисовать точку
: Point ( x y -> )
	SWAP color -ROT phdc SetPixel DROP ;

\ Нарисовать линию
: Line ( x y x1 y1 -> )
	SWAP 2SWAP SWAP 0 -ROT phdc MoveToEx DROP phdc LineTo DROP ;

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


\EOF

Point		( x y -> ) - нарисовать точку
Line		( x y x1 y1 -> ) - нарисовать линию
Square		( x y l -> ) - нарисовать квадрат
Rect 		( x y x1 y1 -> ) - нарисовать прямоугольник
Ellips		( x y x1 y1 -> ) - нарисовать элипс
Circle		( x y d -> ) - нарисовать круг
RRect		( x y x1 y1 h l -> ) - нарисовать прямоугольник c кругленными концами
RSquare		( x y l ll lh-> ) - нарисовать квадрат  c кругленными концами
