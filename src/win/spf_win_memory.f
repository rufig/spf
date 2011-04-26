\ $Id$

( Управление памятью.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия - сентябрь 1999
)
\ 94 MEMORY

USER THREAD-HEAP   \ хэндл хипа текущего потока

VARIABLE USER-OFFS \ смещение в области данных потока, 
                   \ где создаются новые переменные

: ERR ( 0 -- ior | x -- 0 )
  IF 0 ELSE GetLastError THEN
;
: USER-ALLOT ( n -- )
  USER-OFFS +!

\ выровняем в USER-CREATE ~day 
\  USER-OFFS @ +   \ с начала прибавляем
\  CELL 1- +  [ CELL NEGATE ] LITERAL AND \ потом выравниваем
\  USER-OFFS !
;
: USER-HERE ( -- n )
  USER-OFFS @
;

HEX

VARIABLE EXTRA-MEM
4000 ' EXTRA-MEM EXECUTE !

DECIMAL

: SET-HEAP ( heap-id -- )
  >R
  USER-OFFS @ EXTRA-MEM @ CELL+ + 8 R@ 
  HeapAlloc DUP
  IF
     CELL+ TlsIndex!
     R> THREAD-HEAP !
     R> R@ TlsIndex@ CELL- ! >R
  ELSE
     -300 THROW
  THEN
;

HEX

: CREATE-HEAP ( -- )
\ Создать хип текущего потока.
  0 8000 1 HeapCreate SET-HEAP
;

: CREATE-PROCESS-HEAP ( -- )
\ Создать хип процесса
 \ MSDN recommends using serialization for process heap
  \ Heap returned by GetProcessHeap caused problems with forth GUI and we want 
   \ to completely control our process heap
  0 8000 0 HeapCreate SET-HEAP
;

DECIMAL

: DESTROY-HEAP ( -- )
\ Уничтожить хип текущего потока или процесса
  THREAD-HEAP @ HeapDestroy DROP
;

: ALLOCATE ( u -- a-addr ior ) \ 94 MEMORY
\ Распределить u байт непрерывного пространства данных. Указатель пространства 
\ данных не изменяется этой операцией. Первоначальное содержимое выделенного 
\ участка памяти неопределено.
\ Если распределение успешно, a-addr - выровненный адрес начала распределенной 
\ области и ior ноль.
\ Если операция не прошла, a-addr не представляет правильный адрес и ior - 
\ зависящий от реализации код ввода-вывода.

\ SPF: ALLOCATE выделяет одну лишнюю ячейку перед областью данных
\ для "служебных целей" (например, хранения класса созданного объекта)
\ по умолчанию заполняется адресом тела процедуры, вызвавшей ALLOCATE

  CELL+ 8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapAlloc
  DUP IF R@ OVER ! CELL+ 0 ELSE -300 THEN
;

: (FIX-MEMTAG) ( addr -- addr ) 2R@ DROP OVER CELL- ! ;

: FIX-MEMTAG ( addr-allocated -- ) (FIX-MEMTAG) DROP ;

: ALLOCATE ( u -- a-addr ior )
  CELL+ 8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapAlloc
  DUP IF R@ OVER ! CELL+ ( ~~ FIX-MEMTAG ) 0 ELSE -300 THEN
;


: FREE ( a-addr -- ior ) \ 94 MEMORY
\ Вернуть непрерывную область пространства данных, индицируемую a-addr, системе 
\ для дальнейшего распределения. a-addr должен индицировать область 
\ пространства данных, которая ранее была получена по ALLOCATE или RESIZE.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, ior ноль. Если операция не прошла, ior - зависящий от 
\ реализации код ввода-вывода.
  CELL- 0 THREAD-HEAP @ HeapFree ERR
;
: RESIZE ( a-addr1 u -- a-addr2 ior ) \ 94 MEMORY
\ Изменить распределение непрерывного пространства данных, начинающегося с 
\ адреса a-addr1, ранее распределенного по ALLOCATE или RESIZE, на u байт.
\ u может быть больше или меньше, чем текущий размер области.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, a-addr2 - выровненный адрес начала u байт 
\ распределенной памяти и ior ноль. a-addr2 может, но не должен, быть тем же 
\ самым, что и a-addr1. Если они неодинаковы, значения, содержащиеся в области 
\ a-addr1, копируются в a-addr2 в количестве минимального из размеров этих 
\ двух областей. Если они одинаковы, значения, содержащиеся в области, 
\ сохраняются до минимального из u или первоначального размера. Если a-addr2 не 
\ тот же, что и a-addr1, область памяти по a-addr1 возвращается системе 
\ согласно операции FREE.
\ Если операция не прошла, a-addr2 равен a-addr1, область памяти a-addr1 не 
\ изменяется, и ior - зависящий от реализации код ввода-вывода.
  CELL+ SWAP CELL- 8 ( HEAP_ZERO_MEMORY) THREAD-HEAP @ HeapReAlloc
  DUP IF CELL+ 0 ELSE -300 THEN
;