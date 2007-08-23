\ -----------------------------------------------------------------------------
\ __          ___       ____ ___
\ \ \        / (_)     |___ \__ \   heap for Windows
\  \ \  /\  / / _ _ __   __) | ) |  pi@alarmomsk.ru
\   \ \/  \/ / | | '_ \ |__ < / /   Библиотека для работы с кучей
\    \  /\  /  | | | | |___) / /_   Pretorian 2007
\     \/  \/   |_|_| |_|____/____|  v 1.0
\ -----------------------------------------------------------------------------
MODULE: _HEAP

WINAPI: HeapLock		KERNEL32.DLL
WINAPI: HeapUnlock		KERNEL32.DLL
WINAPI: HeapValidate		KERNEL32.DLL
WINAPI: HeapCompact		KERNEL32.DLL
WINAPI: HeapSize		KERNEL32.DLL

EXPORT

\ Получить дескриптор кучи вызывающего процесса
: Heap ( -> handle )
	GetProcessHeap ;

\ Создать кучу ( 0 - ошибка )
: HeapNew ( -> handle )
	0 4096 4 HeapCreate ;

\ Удалить кучу ( 0 - ошибка )
: HeapDel ( handle -> flag )
        HeapDestroy ;

\ Сжимает кучу 
: HeapZip ( handle -> )
	1 SWAP HeapCompact DROP ;

\ Блокировать доступ к куче для других потоков
: HeapLK ( handle -> )
	HeapLock DROP ;

\ Разблокировать доступ к куче для других потоков
: HeapUL ( handle -> )
	HeapUnlock DROP ;

\ Проверить кучу на ошибки
: HeapTest ( handle -> flag )
	0 1 ROT HeapValidate ;

\ Выделяет память из кучи
: MemNew ( n handle -> addr )
	9 SWAP HeapAlloc ;

\ Удаляет выделенную память из кучи ( 0 - ошибка )
: MemDel ( addr handle -> flag ) 
	1 SWAP HeapFree ;

\ Получить размер выделенной памяти
: MemSize ( addr handle -> n )
	1 SWAP HeapSize ;

\ Изменить размер выделенной памяти
: MemResize ( n addr handle -> addr )
	9 SWAP HeapReAlloc ;

\ Проверить выделенную память на ошибки
: MemTest ( addr handle -> flag )
	1 SWAP HeapValidate ;

;MODULE

\EOF

Heap 		( -> handle ) - получить дескриптор кучи вызывающего процесса
HeapNew		( -> handle ) - создать кучу ( 0 - ошибка )
HeapDel		( handle -> flag ) - удалить кучу ( 0 - ошибка )
HeapZip		( handle -> ) - сжимает кучу
HeapLK		( handle -> ) - блокировать доступ к куче для других потоков
HeapUL		( handle -> ) - разблокировать доступ к куче для других потоков
HeapTest	( handle -> flag ) - проверить кучу на ошибки ( 0 - ошибка )
MemNew		( n handle -> addr ) - выделяет память из кучи
MemDel		( addr handle -> flag ) - удаляет выделенную память из кучи
MemSize		( addr handle -> n ) - получить размер выделенной памяти
MemResize	( n addr handle -> addr ) - изменить размер выделенной памяти
MemTest		( addr handle -> flag ) - проверить выделенную память на ошибки ( 0 - ошибка )
