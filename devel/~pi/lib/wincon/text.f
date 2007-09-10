\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   graph for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека вывода текста на граф. консоль
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|  v 1.0
\ -----------------------------------------------------------------------------
REQUIRE ConCreate ~pi/lib/wincon/wincon.f

MODULE: _TEXT

0
CELL -- rectx
CELL -- recty
CELL -- recth
CELL -- rectl
CONSTANT RECT
0 VALUE rect
RECT ALLOCATE THROW TO rect

WINAPI: DrawTextA		USER32.DLL
WINAPI: SetTextColor		GDI32.DLL
WINAPI: SetBkColor		GDI32.DLL

EXPORT

\ Печать строки в заданных координатах
: Print ( x y c-addr n -> )
	length rect rectl !
	height rect recth !
	SWAP 2SWAP
	rect recty !
	rect rectx !
	0 -ROT
	rect -ROT
	phdc DrawTextA DROP ;

\ Установить цвет текста
: ColorText ( RGB -> )
	phdc SetTextColor DROP ;

\ Установить цвет фона под текстом
: BackgroundText ( RGB -> )
	phdc SetBkColor DROP ;

;MODULE

0xFFFFFF ColorText
0 BackgroundText

\EOF

Print		( x y c-addr n -> ) - печать строки в заданных координатах
ColorText	( RGB -> ) - установить цвет текста
BackgroundText	( RGB -> ) - установить цвет фона под текстом
