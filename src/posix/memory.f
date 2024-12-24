\ $Id$
( Управление памятью.
  Windows-зависимые слова.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия - сентябрь 1999
)
\ 94 MEMORY


0 CONSTANT FORTH-START
.forth >VIRT ' FORTH-START >BODY !

0x80000 VALUE IMAGE-SIZE

VARIABLE THREAD-HEAP \ для совместимости с windows-версией, значение никакой нагрузки не несёт

USER THREAD-MEMORY   \ память текущего потока

VARIABLE USER-OFFS \ смещение в области данных потока, 
                   \ где создаются новые переменные

VARIABLE calloc-adr

: errno ( -- n )
  (()) __errno_location @
;

: ?ERR ( -1 -- -1 err | x -- x 0 )
  DUP -1 = IF errno ELSE 0 THEN
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

VARIABLE EXTRA-MEM
0x4000 ' EXTRA-MEM EXECUTE !

: ALLOCATE-THREAD-MEMORY ( -- )
  USER-OFFS @ EXTRA-MEM @ CELL+ + 1 2 calloc-adr @ 
  C-CALL DUP
  IF
     DUP CELL+ TlsIndex!
     THREAD-MEMORY !
     R> R@ TlsIndex@ CELL- ! >R
  ELSE
     -300 THROW
  THEN
;

: FREE-THREAD-MEMORY ( -- )
\ Уничтожить хип текущего потока или процесса
  (( THREAD-MEMORY @ )) free DROP
;


: (FIX-MEMTAG) ( addr -- addr ) 2R@ DROP OVER CELL- ! ;

: FIX-MEMTAG ( addr-allocated -- ) (FIX-MEMTAG) DROP ;

: ADD-SIZE ( u1 u2 -- u3 0 | u1 ior )
  2DUP 1+ NEGATE U< IF + 0 EXIT THEN DROP -24 \ "invalid numeric argument"
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

  \ Сразу возвратить ошибку, если добавление служебной ячейки даст переполнение
  CELL ADD-SIZE DUP IF EXIT THEN DROP ( u2 )

  1 SWAP 2 calloc-adr @ C-CALL
  DUP IF CELL+ (FIX-MEMTAG) 0 EXIT THEN -300
;

: FREE ( a-addr -- ior ) \ 94 MEMORY
\ Вернуть непрерывную область пространства данных, индицируемую a-addr, системе 
\ для дальнейшего распределения. a-addr должен индицировать область 
\ пространства данных, которая ранее была получена по ALLOCATE или RESIZE.
\ Указатель пространства данных не изменяется данной операцией.
\ Если операция успешна, ior ноль. Если операция не прошла, ior - зависящий от 
\ реализации код ввода-вывода.
  DUP 0= IF DROP -12 EXIT THEN \ -12 "argument type mismatch"
  CELL- 1 <( )) free DROP 0
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
  DUP 0= IF -12 EXIT THEN \ -12 "argument type mismatch"
  CELL+ SWAP CELL- SWAP 2 realloc-adr @ C-CALL
  DUP IF CELL+ 0 ELSE -300 THEN
;


PAGESIZE CONSTANT MEMORY-PAGESIZE
  \ NB: The "PAGESIZE" word is available only during building,
  \ and it isn't availabe in the target system.

: ALLOCATE-RWX ( +n -- a-addr 0 | x ior )
\ Allocate a memory region that can be read, modified, and executed
  \ add page size (to have at least one page), and one additional cell for MEMTAG
  MEMORY-PAGESIZE 1- CELL+ ADD-SIZE DUP IF EXIT THEN DROP ( n2 )
  DUP 0< IF -24 EXIT THEN \ "invalid numeric argument"
  \ Assertion: pagesize is a power of two, two's complement representation of signed integers
  MEMORY-PAGESIZE NEGATE AND ( u3 ) \ align u2 down on the page size
  \ Allocate a range on a pagesize-aligned address, and of pagesize-aligned size
  \ https://man7.org/linux/man-pages/man3/posix_memalign.3.html
  >R (( MEMORY-PAGESIZE R@ )) aligned_alloc  ( 0|a-addr1 )
  \ DUP 0= ?ERR NIP ( 0|a-addr1 ior|0 )
  DUP 0= -300 AND ( 0|a-addr1 -300|0 )
  DUP IF NIP R> SWAP ( u3 ior ) EXIT THEN DROP ( a-addr1 )
  \ Set protection, allow code execution
  \ https://man7.org/linux/man-pages/man2/mprotect.2.html#EXAMPLES
  (( DUP  R>  0 PROT_READ OR PROT_WRITE OR PROT_EXEC OR  )) mprotect ?ERR NIP ( a-addr1 ior )
  DUP IF >R  FREE  R>  ( ior2 ior ) EXIT THEN DROP ( a-addr1 )
  CELL+ (FIX-MEMTAG) 0 ( a-addr 0 )
;

: FREE-RWX ( a-addr -- ior )
  \ Assertion: a-addr is aligned to MEMORY-PAGESIZE
  DUP 0= IF DROP -12 EXIT THEN \ -12 "argument type mismatch"
  DUP MEMORY-PAGESIZE NEGATE AND OVER <> IF DROP -60 EXIT THEN
  FREE
;

: RESIZE-RWX ( a-addr -- a-addr ior ) -21 ; \ -21 "unsupported operation"
