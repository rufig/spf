\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   ComPort v1.0 for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека для работы с com портами
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|
\ -----------------------------------------------------------------------------

\ handle открытых портов
0 VALUE com1
0 VALUE com2
0 VALUE com3
0 VALUE com4
\ буфер для чтения/записи com порта
CREATE buffcom 256 ALLOT

MODULE: HIDDEN

WINAPI: GetCommState		KERNEL32.DLL
WINAPI: SetCommState		KERNEL32.DLL
WINAPI: SetCommTimeouts		KERNEL32.DLL
WINAPI: PurgeComm		KERNEL32.DLL
WINAPI: TransmitCommChar	KERNEL32.DLL
WINAPI: WaitCommEvent		KERNEL32.DLL
WINAPI: GetCommMask		KERNEL32.DLL

\ Константы чтения/записи порта
-2147483648 CONSTANT GENERIC_READ
1073741824  CONSTANT GENERIC_WRITE

VARIABLE tempcom
VARIABLE ReadBuffer
VARIABLE EvtMask


0
CELL -- DCBlength	\ задает длину, в байтах, структуры DCB. 
CELL -- BaudRate	\ скорость передачи данных. 
CELL -- Mode		\ включает двоичный режим обмена (это флаги). 
2 -- wReserved		\ не используется, должно быть установлено в 0. 
2 -- XonLim		\ минимальное число символов в приемном буфере перед посылкой символа XON. 
2 -- XoffLim		\ количество байт в приемном буфере перед посылкой символа XOFF. 
1 -- ByteSize		\ число информационных бит в передаваемых и принимаемых байтах. 4-8 
1 -- Parity		\ схема контроля четности 
	\ 0-4=дополнить до четности,1,отсутствует,дополнить до нечетности,0 
1 -- StopBits		\ задает количество стоповых бит. 0,1,2 = 1, 1.5, 2 
1 -- XonChar		\ задает символ XON используемый как для приема, так и для передачи. 
1 -- XoffChar		\ задает символ XOFF используемый как для приема, так и для передачи. 
1 -- ErrorChar		\ задает символ, использующийся для замены символов с ошибочной четностью. 
1 -- EofChar		\ задает символ, использующийся для сигнализации о конце данных. 
1 -- EvtChar		\ задает символ, использующийся для сигнализации о событии. 
2 -- wReserved1		\ зарезервировано и не используется. 
CONSTANT DCB
HERE DUP >R DCB DUP ALLOT ERASE VALUE MyDCB

0   
CELL -- ReadIntervalTimeout		\ Максимальное время, в миллисекундах, допустимое между двумя последовательными символами, считы-ваемыми с коммуникационной линии. 
CELL -- ReadTotalTimeoutMultiplier	\ Задает множитель, в миллисекундах, используемый для вычисления общего тайм-аута операции чтения. 
CELL -- ReadTotalTimeoutConstant	\ Задает константу, в миллисекундах, используемую для вычисления общего тайм-аута операции чтения. 
CELL -- WriteTotalTimeoutMultiplier	\ Задает множитель, в миллисекундах, используемый для вычисления общего тайм-аута операции записи.
CELL -- WriteTotalTimeoutConstant	\ Задает константу, в миллисекундах, используемую для вычисления общего тайм-аута операции записи.
CONSTANT COMMTIMEOUTS
HERE DUP COMMTIMEOUTS DUP ALLOT ERASE VALUE CommTimeouts

\ Открытие com порта по его имени
: ComOpen ( с-addr u -> handle )
DROP >R
0 0 OPEN_EXISTING 0 0 GENERIC_READ GENERIC_WRITE OR R> CreateFileA
DUP -1 = IF DROP 0 THEN ;

\ Первоначальная инициализация порта
: ComInit ( handle -> ior )
	>R
	DCB MyDCB DCBlength !
	MyDCB R> DUP >R GetCommState DROP
	9600 MyDCB BaudRate ! 
	0x80000000 MyDCB Mode !
	8 MyDCB ByteSize C!
	1 MyDCB StopBits C!
	2 MyDCB Parity C!
	MyDCB R> SetCommState ; 

\ Установка интервалов ожидания для чтения/записи в порт
: Timeouts ( handle ms -> flag )
	SWAP >R
	10  CommTimeouts ReadIntervalTimeout !
	1   CommTimeouts ReadTotalTimeoutMultiplier !
	    CommTimeouts ReadTotalTimeoutConstant !
	100 CommTimeouts WriteTotalTimeoutMultiplier !
	1   CommTimeouts WriteTotalTimeoutConstant !
	    CommTimeouts R> SetCommTimeouts ;


EXPORT
\ Открывает порт com1
: COM1 ( -> handle )
	S" COM1" ComOpen DUP TO com1 0<> 
	IF com1 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\ Открывает порт com2
: COM2 ( -> handle )
	S" COM2" ComOpen DUP TO com2 0<> 
	IF com2 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\ Открывает порт com3
: COM3 ( -> handle )
	S" COM3" ComOpen DUP TO com3 0<> 
	IF com3 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;
\ Открывает порт com4
: COM4 ( -> handle )
	S" COM4" ComOpen DUP TO com4 0<> 
	IF com4 DUP ComInit DROP 1000 Timeouts DROP -1 ELSE 0 THEN ;

\ Закрыть com порт
: COMClose ( handle -> ior )
	CloseHandle ;

\ Читать строку из com в буфер
: COMRead ( handle -> c-addr u )
	>R 0 tempcom 256 buffcom R> ReadFile DROP
	buffcom ASCIIZ> 1- DUP 0< IF DROP 0 THEN ;

\ Записать строку в com порт
: COMWrite ( c-addr u handle -> )
	>R SWAP 0 tempcom 2SWAP R> WriteFile DROP ;

\ Вывести на консоль строку из буфера com
: .COM ( c-addr u -> )
	TYPE 0 buffcom ! ;

\ Прием символа из порта
: COMIn ( handle -- char )
	0 ReadBuffer ! >R 0 tempcom 1 ReadBuffer R> ReadFile DROP
	ReadBuffer C@ ;

\ Передача символа в открытый порт
: COMOut ( char handle -- )
	TransmitCommChar DROP ;

\ Настройка порта
: COMSet ( handle BaudRate ByteSize StopBits Parity -> ior )
 MyDCB Parity C!
 MyDCB StopBits C!
 MyDCB ByteSize C!
 MyDCB BaudRate !
 MyDCB SetCommState 0 <> ;

\ Очищает очередь приема/передачи в драйвере com порта
: COMClear ( handle -> )
	DUP 12 SWAP PurgeComm DROP ;


;MODULE

: main
	COM1
	IF
	 BEGIN
	  \ com1 COMWait 1 .
	  com1 COMRead .COM
	  \ com1 COMIn .
	 AGAIN
	THEN
;

\EOF

По умолчанию com порты имеют настройки:
 - скорость: 9600
 - бит данных: 8
 - четность: нет
 - стоповые биты: 1

com1		( -> handle ) - хендл com1 после инициализации
com2		( -> handle ) - хендл com2 после инициализации
com3		( -> handle ) - хендл com3 после инициализации
com4		( -> handle ) - хендл com4 после инициализации

COM1		( -> handle ) - открывает порт com1
COM2		( -> handle ) - открывает порт com2
COM3		( -> handle ) - открывает порт com3
COM4		( -> handle ) - открывает порт com4
COMClose 	( handle -> ior ) - закрыть com порт
COMRead		( addr u handle -> c-addr u ) - читать строку из com в буфер
COMWrite	( c-addr u handle -> ) - записать строку в com порт
COMIn		( handle -- char ) - прием символа из порта
COMOut		( char handle -- ) - передача символа в открытый порт
COMSet 		( handle BaudRate ByteSize StopBits Parity -> ior ) - настройка
		порта
COMClear	( handle -> ) - очищает очередь приема/передачи в драйвере com порта
