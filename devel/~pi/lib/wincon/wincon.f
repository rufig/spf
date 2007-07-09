\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   wincon for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека графической консоли
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|
\ -----------------------------------------------------------------------------
REQUIRE STRUCT:	lib\ext\struct.f
REQUIRE pen	~pi/lib/win/pen.f

WINAPI: GetModuleHandleA	KERNEL32.DLL

WINAPI: RegisterClassExA 	USER32.DLL
WINAPI: CreateWindowExA		USER32.DLL
WINAPI: LoadIconA		USER32.DLL
WINAPI: LoadCursorA		USER32.DLL
WINAPI: DefWindowProcA		USER32.DLL
WINAPI: PostQuitMessage		USER32.DLL
WINAPI: GetMessageA		USER32.DLL
WINAPI: TranslateMessage	USER32.DLL
WINAPI: DispatchMessageA	USER32.DLL
WINAPI: ShowWindow		USER32.DLL
WINAPI: MoveWindow		USER32.DLL
WINAPI: BeginPaint		USER32.DLL
WINAPI: EndPaint		USER32.DLL
WINAPI: GetDC			USER32.DLL
WINAPI: ReleaseDC		USER32.DLL

WINAPI: DeleteObject		GDI32.DLL
WINAPI: CreateSolidBrush	GDI32.DLL
WINAPI: CreatePen		GDI32.DLL
WINAPI: CreateCompatibleDC	GDI32.DLL
WINAPI: DeleteDC		GDI32.DLL
WINAPI: CreateCompatibleBitmap	GDI32.DLL
WINAPI: BitBlt			GDI32.DLL
WINAPI: SelectObject		GDI32.DLL
WINAPI: Rectangle		GDI32.DLL



\ Структура класса окна
STRUCT: WNDCLASSEX
 CELL -- cbSize
 CELL -- style
 CELL -- lpfnWndProc
 CELL -- cbClsExtra
 CELL -- cbWndExtra
 CELL -- hInstance
 CELL -- hIcon
 CELL -- hCursor
 CELL -- hbrBackground
 CELL -- lpszMenuName
 CELL -- lpszClassName
 CELL -- hIconSm
;STRUCT

\ Структура сообщений окна
STRUCT: MSG
 CELL -- hwnd
 CELL -- message
 CELL -- wParam
 CELL -- lParam
 CELL -- time
 CELL 4 * -- pt
;STRUCT

\ Структура рисования
STRUCT: PAINTSTRUCT
 CELL -- hdc
 CELL -- fErase
 CELL 4 * -- rcPaint
 CELL -- fRestore
 CELL -- fIncUpdate
 32 -- rgbReserved
;STRUCT

2 CONSTANT WM_DESTROY
0xF CONSTANT WM_PAINT

\ Выделение памяти под структуру класса окна
CREATE classwin WNDCLASSEX::/SIZE ALLOT
CREATE msgwin MSG::/SIZE ALLOT
CREATE paint PAINTSTRUCT::/SIZE ALLOT

\ hendle консоли
0 VALUE hwdwin
\ hendle потока консоли
0 VALUE hwdwinp
\ Длинна консоли в пикселях
0 VALUE length 
\ Высота консоли в пикселах
0 VALUE height
\ Расположение консоли относительно экрана по верху
0 VALUE top
\ Расположение консоли относительно экрана слева
0 VALUE left
\ hdc консоли
0 VALUE hdc
\ hdc консоли в памяти
0 VALUE phdc
\ hendel bitmap-а консоли (буфер изображения
0 VALUE bufh
\ перо
0 VALUE penh
\ Цвет
0 VALUE color
\ Толщина
0 VALUE psize
\ кисть
0 VALUE brush
\ Фон
0 VALUE background


\ Выход при ошибке API функций
: ERRORAPI ( -> )
	DUP 0=
	IF
		hdc hwdwin ReleaseDC DROP
		phdc DeleteDC DROP BYE
	THEN ;

\ Выход из программы
: BYE ( -> )
	hwdwinp STOP
	penh DeleteObject DROP
	hdc ReleaseDC DROP
	phdc DeleteDC DROP
	BYE ;

:NONAME { lpar wpar msg hwnd -- }
   msg WM_PAINT =
   IF
	paint hwdwin BeginPaint DROP
	0xCC0020 0 0 phdc height length top left hdc BitBlt DROP
	paint hwdwin EndPaint DROP
	0 EXIT
   THEN
   msg WM_DESTROY =
   IF
     0 PostQuitMessage
     BYE
   THEN
   lpar wpar msg hwnd DefWindowProcA
;

WNDPROC: MyWndProc

\ Создание класса для окна
: INITWIN ( -> )
	48 classwin WNDCLASSEX::cbSize !
	0x23 classwin WNDCLASSEX::style !
	['] MyWndProc classwin WNDCLASSEX::lpfnWndProc !
	0 GetModuleHandleA ERRORAPI classwin WNDCLASSEX::hInstance !
	32512 0 LoadIconA ERRORAPI classwin WNDCLASSEX::hIcon !
	32512 0 LoadCursorA ERRORAPI classwin WNDCLASSEX::hCursor !
	0 CreateSolidBrush ERRORAPI classwin WNDCLASSEX::hbrBackground !
	S" CONSOLE" DROP classwin WNDCLASSEX::lpszClassName !
	classwin RegisterClassExA ERRORAPI DROP
	0 classwin WNDCLASSEX::hInstance @ 0 0 height length top left
	0x90000800 0 S" CONSOLE" DROP 0
	CreateWindowExA DUP ERRORAPI TO hwdwin
	BEGIN
		0 0 0 msgwin GetMessageA
	WHILE
		msgwin TranslateMessage DROP
		msgwin DispatchMessageA DROP
	REPEAT
	;

' INITWIN TASK: LoopWin


\ -+=================================================================+-

\ Перевод цветовой гаммы в цвет
: RGB ( R G B -> RGB )
	255 AND ROT 255 AND 16 LSHIFT ROT 255 AND 8 LSHIFT OR OR ;

\ Установить цвет рисования
: Color ( RGB -> )
	penh DeleteObject DROP DUP TO color
	1 0 CreatePen DUP TO penh
	phdc SelectObject DROP ;

\ Установить фон рисования
: Background ( RGB -> )
	DUP TO background
	brush DeleteObject DROP DUP TO brush
	CreateSolidBrush TO brush
	brush phdc SelectObject DROP ;

\ Создать консоль
: ConCreate ( -> )
	200 TO length 100 TO height
	hwdwin 0= IF 0 LoopWin START TO hwdwinp THEN
	hwdwin GetDC ERRORAPI TO hdc 
	hwdwin CreateCompatibleDC ERRORAPI TO phdc
	bufh DeleteObject DROP
	height length hdc CreateCompatibleBitmap ERRORAPI TO bufh
	bufh phdc SelectObject ERRORAPI DROP
	0 CreateSolidBrush ERRORAPI
	phdc SelectObject ERRORAPI DROP
	0x00FFFFFF Color ;

\ Удалить консоль
: ConDestroy ( -> )
	hwdwinp STOP 0 TO hwdwin 0 TO length 0 TO height ;

\ Спрятать консоль
: ConHide ( -> )
	0 hwdwin ShowWindow DROP ;

\ Показать консоль
: ConShow ( -> )
	5 hwdwin ShowWindow DROP ;

\ Изменить координаты консоли на экране
: ConMove ( x y -> )
	TO top TO left
	1 height length top left hwdwin MoveWindow DROP ; 

\ Изменить длинну и высоту консоли и очистить ее
: ConSize ( length height -> )
	TO height TO length
	1 height length top left hwdwin MoveWindow DROP
	bufh DeleteObject DROP
	height length hdc CreateCompatibleBitmap ERRORAPI TO bufh
	bufh phdc SelectObject ERRORAPI DROP ;

\ Очистить консоль
: Cls ( -> )
	length height ConSize
	color background Color
	height length 0 0 phdc Rectangle DROP
	Color ;

ConCreate

\EOF

-+- Для создания новых возможностей -+-
phdc		( -> n ) - контекст консоли в который осуществляется граф. вывод
hwdwin		( -> n ) - хендел окна консоли

-+- Возможности графической консоли -+-
top		( -> n ) - расположение консоли относительно экрана с верху
left		( -> n ) - расположение консоли относительно экрана слева
length		( -> n ) - длина консоли в пикселах
height		( -> n ) - высота консоли в пикселах
color		( -> RGB ) - текущий цвет
background	( -> RGB ) - текущий фон

ConCreate	( -> ) - включить консоль
ConDestroy	( -> ) - удалить консоль
ConHide		( -> ) - спрятать консоль
ConShow		( -> ) - показать консоль
ConMove		( x y -> ) - изменить координаты консоли на экране
ConSize		( length height -> ) - изменить длинну и высоту консоли и очистить ее
Color		( RGB -> ) - установить цвет рисования
Background	( RGB -> ) - установить фон рисования
Cls		( -> ) - очистить окно

-+- Преобразования -+-
RGB		( R G B -> RGB ) - перевод цветовой гаммы в цвет
