\ Подключение процедур из динамических библиотек
\ без использования WINAPI: 
\ Ю. Жиловец, 11.04.2003

REQUIRE "              ~yz/lib/common.f
REQUIRE LOAD-NAMETABLE ~yz/lib/nametable.f
REQUIRE DYNSIZE        ~yz/lib/dynbuf.f

MODULE: USEDLL

\ Формат файла имен. Дополнительные данные:
\ CELL ссылка на элемент каталога импорта
\ ...  имя библиотеки
\ В конце каждого имени имеется лишний нулевой байт
\ (чтобы не возиться с преобразованием строк)

VARIABLE import-chain  import-chain 0!

VECT prevNOTFOUND

\ ----------------------------------
: >footer DUP CELL+ @ + ;

EXPORT

0 VALUE IMPORT-DIR
0 VALUE IMPORT-RELOC

0
CELL -- :idlist1    \ интерпретация: список ссылок на имена
CELL -- :iddatetime \ интерпретация: счетчик загруженных функций
CELL -- :idfwdchain \ интерпретация: дескриптор библиотеки
CELL -- :idlibname  \ интерпретация: ссылка на загруженный .names файл
CELL -- :idlist2    \ интерпретация: список загруженных функций
CONSTANT /importdir

\ формат вызова: hiword - номер библиотеки в каталоге, 
\ loword - номер функции в нашем списке загруженных процедур (не ординал)

: DLLGetAddrLoc ( procid -- addr) 
  DUP HIWORD /importdir * IMPORT-DIR + :idlist2 @ IMPORT-RELOC +
  SWAP LOWORD CELLS + ;

: DLLCALL ( ... n -- res ) DLLGetAddrLoc @ API-CALL ;

: USE ( ->bl; -- )
  IMPORT-DIR 0= IF /importdir 5 * CREATE-DYNBUF TO IMPORT-DIR THEN
  \ конструируем имя файла таблицы имен и грузим его
  HERE 0 ModuleDirName SAPPEND S" devel\~yz\dll\" SAPPEND
  BL PARSE SAPPEND S" .names" 1+ SAPPEND LOAD-NAMETABLE 
  \ прошиваем цепь каталогов импорта
  DUP import-chain STITCH-NAMETABLE-CHAIN 
  \ заводим новый каталог импорта
  ( nt) /importdir IMPORT-DIR DYNALLOC TO IMPORT-DIR >R
  \ ставим в таблице обратную ссылку на каталог импорта
  ( nt) R@ OVER >footer !
  \ заполняем каталог импорта
  ( nt) R@ :idlibname !
  20 CELLS CREATE-DYNBUF R@ :idlist1 !
  20 CELLS CREATE-DYNBUF R@ :idlist2 !
  R@ :idlibname @ >footer CELL+ LoadLibraryA
  ?DUP 0= ABORT" Не могу загрузить динамическую библиотеку"
  R> :idfwdchain ! ;

: bind-proc ( namerec-a -- procid ) 
  >R THIS-NAMETABLE >footer @ ( idir) >R
  \ в первый список ставим ссылку на имя процедуры
  CELL R@ :idlist1 @ DYNALLOC R@ :idlist1 ! 
  ( 2-й элемент стека возвратов - адрес записи с именем)
  RP@ CELL+ @ CELL+ 1+ DUP >R SWAP !
  \ во второй список ставим реальный адрес загруженной процедуры
  R> R@ :idfwdchain @ GetProcAddress
  ?DUP 0= ABORT" Не могу загрузить процедуру"
  CELL R@ :idlist2 @ DYNALLOC R@ :idlist2 ! !
  \ узнаем номер каталога в таблице импорта
  R@ IMPORT-DIR - /importdir /
  \ конструируем код процедуры
  16 LSHIFT R@ :iddatetime @ OR
  \ увеличиваем счетчик процедур
  R> :iddatetime 1+!
  \ запоминаем код процедуры в записи таблицы имен
  DUP R> ! ;

: DLLProcID ( name-a name-n -- procid/-1)
  import-chain @ -ROT SEARCH-NAMETABLE-CHAIN
  ?DUP 0= IF -1 EXIT THEN
  DUP @ DUP -1 = IF DROP bind-proc ELSE PRESS THEN ;

' NOTFOUND TO prevNOTFOUND

WARNING 0!

: NOTFOUND ( a n -- )
  2DUP DLLProcID 
  DUP -1 = IF 
    DROP prevNOTFOUND
  ELSE
    PRESS PRESS STATE @ IF [COMPILE] LITERAL POSTPONE DLLCALL ELSE DLLCALL THEN
  THEN
; IMMEDIATE

TRUE WARNING !

\ Забиваем две функции, которые требуются для правильной работы WINAPI:
\ Они, конечно, и без нас загружены, но потребуются в сохраненном РЕ-файле

USE KERNEL32
S" LoadLibraryA" DLLProcID DROP
S" GetProcAddress" DLLProcID DROP

;MODULE
