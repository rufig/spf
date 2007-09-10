\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   Console for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека для работы с консолью
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|
\ -----------------------------------------------------------------------------

MODULE: _CONSOLE

WINAPI: SetConsoleTitleA		KERNEL32.DLL
WINAPI: SetConsoleCursorPosition	KERNEL32.DLL
WINAPI: SetConsoleTextAttribute		KERNEL32.DLL
WINAPI: SetConsoleCursorInfo		KERNEL32.DLL
WINAPI: GetConsoleCursorInfo		KERNEL32.DLL
WINAPI: SetConsoleScreenBufferSize	KERNEL32.DLL
WINAPI: GetConsoleScreenBufferInfo	KERNEL32.DLL
WINAPI: FillConsoleOutputCharacterA	KERNEL32.DLL
WINAPI: FillConsoleOutputAttribute	KERNEL32.DLL
WINAPI: SetConsoleDisplayMode		KERNEL32.DLL
WINAPI: WriteConsoleOutputCharacterA	KERNEL32.DLL

0 VALUE XWin \ координата X виртуального окна
0 VALUE YWin \ координата Y виртуального окна
0 VALUE LWin \ длина виртуального окна
0 VALUE HWin \ высота виртуального окна
7 VALUE CWin \ цвет символов
0 VALUE BWin \ фон символов

EXPORT

\ Дублирует указанное количество чисел в стеке
: DUPS ( n -> )
	DUP 0 ?DO DUP PICK SWAP LOOP DROP
 ;

\ Упаковать координаты в число
: XY->N ( x y -> n )
	16 LSHIFT OR ;

\ Распаковать координаты из числа
: N->XY ( n -> x y )
	DUP 0xFFFF AND SWAP 16 RSHIFT ;

\ Упаковать цвет и фон в число
: Color->N ( цвет фон -> n )
	4 LSHIFT OR ;

\ Распаковать цвет и фон из числа
: N->Color ( n -> цвет фон )
	DUP 0xF AND SWAP 4 RSHIFT ;
	

\ Изменить титул консоли
: SetTitle ( addr n -> )
	DROP SetConsoleTitleA DROP ;

\ Установить курсор в консоли в заданные координаты
: SetLocate ( x y -> )
	XY->N H-STDOUT SetConsoleCursorPosition DROP ;

\ Спрятать курсор на консоли
: HideCursore ( -> )
	0 0 SP@ DUP H-STDOUT GetConsoleCursorInfo DROP
	ROT DROP 0 -ROT
	H-STDOUT SetConsoleCursorInfo DROP 2DROP ;

\ Показать курсор на консоли
: ShowCursore ( -> )
	0 0 SP@ DUP H-STDOUT GetConsoleCursorInfo DROP
	ROT DROP 1 -ROT
	H-STDOUT SetConsoleCursorInfo DROP 2DROP ;

\ Размер курсора (0-100)
: SizeCursore ( n -> )
	>R 0 0 SP@ DUP H-STDOUT GetConsoleCursorInfo DROP
	SWAP DROP R> SWAP
	H-STDOUT SetConsoleCursorInfo DROP 2DROP ;

\ Размер консоли (от 80) (от 25)
: SizeConsole ( lenght height -> )
	XY->N H-STDOUT SetConsoleScreenBufferSize DROP ;

\ Длинна консоли
: GetLength ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	>R 2DROP 2DROP DROP R> 0xFFFF AND ;

\ Высота консоли
: GetHeight ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	>R 2DROP 2DROP DROP R> 16 RSHIFT ;

\ Координата курсора X
: GetX ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	DROP >R 2DROP 2DROP R> 0xFFFF AND ;

\ Координата курсора Y
: GetY ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	DROP >R 2DROP 2DROP R> 16 RSHIFT ;

\ Получить координаты курсора
: GetLocate ( -> x y )
	GetX GetY ;

\ Текущий цвет консоли
: GetColor ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	2DROP >R 2DROP DROP R> 0xF AND ;

\ Текущий фон консоли
: GetBackground ( -> n )
	0 0 0 0 0 0 SP@ H-STDOUT GetConsoleScreenBufferInfo DROP
	2DROP >R 2DROP DROP R> 4 RSHIFT ;

\ Изменить цвет выходящих символов на консоль
: SetColor ( n -> )
	
	GetBackground 4 LSHIFT OR H-STDOUT SetConsoleTextAttribute DROP ;

\ Изменить фон выходящих символов на консоль
: SetBackground ( n -> )
	16 * GetColor + H-STDOUT SetConsoleTextAttribute DROP ;

\ Изменить координату X курсора в консоли
: SetX ( n -> )
	GetY SetLocate ; 

\ Изменить координату Y курсора в консоли
: SetY ( n -> )
	GetX SWAP SetLocate ; 

\ Очистить консоль
: Cls ( -> )
	0 0 GetLocate XY->N DUP >R 32 H-STDOUT
	FillConsoleOutputCharacterA DROP
	0 0 R> GetColor GetBackground Color->N H-STDOUT
	FillConsoleOutputAttribute DROP
	0 0 SetLocate ;

\ Развернуть консоль на весь экран
: FullConsole ( -> )
	0 1 H-STDOUT SetConsoleDisplayMode DROP ;

\ Вернути полноэкранную консоль в окно
: WindowsConsole ( -> )
	0 0 H-STDOUT SetConsoleDisplayMode DROP ;

\ Установить атрибуты в окне консоли
: AttrWindow ( -> )
	XWin YWin XY->N
	HWin 0 ?DO
	DUP 0 SWAP LWin CWin BWin Color->N H-STDOUT
	FillConsoleOutputAttribute DROP 0x10000 +
	LOOP DROP ;

\ Очистить окно в консоли без изменения атрибутов
: ClearWindow ( -> )
	XWin YWin XY->N
	HWin 0 ?DO
	DUP 0 SWAP LWin 32 H-STDOUT
	FillConsoleOutputCharacterA DROP 0x10000 +
	LOOP DROP ;

\ Очистить окно на консоли
: ClsWindow ( -> )
	ClearWindow AttrWindow ;

\ Поменять цвета фон и цвета консоли местами
: SwapColor ( -> )
	GetBackground GetColor SetBackground SetColor ;

\ Вывод строки без смещения курсора и без изменения цвета
: PrintС ( n addr x y -> )
	XY->N 0 SWAP 2SWAP SWAP H-STDOUT WriteConsoleOutputCharacterA DROP ;

\ Вывод символа без смещения курсора и без изменения цвета
: EmitС ( x y char -> )
	>R XY->N 0 SWAP 1 RP@ H-STDOUT WriteConsoleOutputCharacterA
	R> 2DROP ;

\ Одинарная горизонтальная линия
: LineH ( n -> )
	0 ?DO 0xC4 EMIT LOOP ;

\ Двойная горизонтальная линия
: DLineH ( n -> )
	0 ?DO 0xCD EMIT LOOP ;

\ Одинарная вертикальная линия
: LineV ( n -> )
	0 ?DO GetLocate 0xB3 EMIT 1+ SetLocate LOOP ;

\ Двойная вертикальная линия
: DLineV ( n -> )
	0 ?DO GetLocate 0xBA EMIT 1+ SetLocate LOOP ;

\ Вывести одинарную рамку по виртуальному окну
: Box ( -> )
	GetColor GetBackground CWin SetColor BWin SetBackground
	XWin YWin SetLocate
	0xDA EMIT LWin 2- LineH 0xBF EMIT
	XWin YWin HWin 2- 0 ?DO
	1+ 2DUP SetLocate 0xB3 EMIT LWin 2- SPACES 0xB3 EMIT
	LOOP
	1+ SetLocate 0xC0 EMIT LWin 2- LineH 0xD9 EMIT
	SetBackground SetColor ;

\ Вывести двойную рамку по виртуальному окну
: DBox ( -> ) 
	GetColor GetBackground CWin SetColor BWin SetBackground
	XWin YWin SetLocate
	0xC9 EMIT LWin 2- DLineH 0xBB EMIT
	XWin YWin HWin 2- 0 ?DO
	1+ 2DUP SetLocate 0xBA EMIT LWin 2- SPACES 0xBA EMIT
	LOOP
	1+ SetLocate 0xC8 EMIT LWin 2- DLineH 0xBC EMIT
	SetBackground SetColor ;

\ Стандартные установки атрибутов консоли
: Console ( -> )
	WindowsConsole
	0 SetBackground
	7 SetColor
	80 25 SizeConsole
	10 SizeCursore
	ShowCursore
	Cls ;
	

GetLength 	TO LWin
GetHeight 	TO HWin
GetColor	TO CWin
GetBackground	TO BWin

;MODULE
\EOF

---Общие слова---
DUPS		( n -> ) - дублирует указанное количество чисел в стеке
XY->N		( x y -> n ) - упаковать координаты в число
N->XY		( n -> x y ) - распаковать координаты из числа
Color->N	( цвет фон -> n ) - упаковать цвет и фон в число
N->Color	( n -> цвет фон ) - распаковать цвет и фон из числа

---Вывод на консоль---
CharС		( x y char -> ) - вывод символа без смещения курсора и изменения
		цвета
PrintС		( n addr x y -> ) - вывод строки без смещения курсора и
		изменения цвета
LineH 		( n -> ) - одинарная горизонтальная линия
DLineH		( n -> ) -  двойная горизонтальная линия
LineV		( n -> ) - одинарная вертикальная линия
DLineV		( n -> ) - двойная вертикальная линия
Box		( -> ) - вывести одинарную рамку (задается nWin)
DBox		( -> ) - вывести двойную рамку (задается nWin)


---Действия с координатами---
SetLocate	( x y -> ) - установить курсор в консоли в заданные координаты
GetLocate	( -> x y ) - получить координаты курсора
SetX		( n -> ) - изменить координату X курсора в консоли
SetY		( n -> ) - изменить координату Y курсора в консоли
GetX		( -> n ) - координата курсора X
GetY		( -> n ) - координата курсора Y

---Действия с курсором---
HideCursore	( -> ) - спрятать курсор на консоли
ShowCursore	( -> ) - показать курсор на консоли
SizeCursore	( n -> ) - размер курсора (0-100)

---Действия с консолью---
SetTitle	( addr n -> ) - изменить титул консоли
FullConsole	( -> ) - развернуть консоль на весь экран
WindowsConsole	( -> ) - свернуть полноэкранную консоль в окно
SizeConsole	( lenght height -> ) - размер консоли (от 80) (от 25)
GetLength	( -> n ) - длинна консоли
GetHeight	( -> n ) - высота консоли
ClearWindow	( -> ) - очистить окно без изменения атрибутов (задается nWin)
Cls		( -> ) - очистить консоль
ClsWindow	( -> ) - очистить окно на консоли (задается nWin)

---Действия с цветами консоли---
GetColor	( -> n ) - текущий цвет консоли
GetBackground	( -> n ) - текущий фон консоли
SetColor	( n -> ) - изменить цвет выходящих символов на консоль
SetBackground	( n -> ) - изменить фон выходящих символов на консоль
SwapColor	( -> ) - поменять цвета фон и цвета консоли местами
AttrWindow 	( -> ) - установить атрибуты в окне консоли (задается nWin)
