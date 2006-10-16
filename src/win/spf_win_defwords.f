( Интерфейсы с Windows - определения в словаре импортируемых 
  функций Windows и экспортируемых функций [callback, wndproc и т.п.]
  Windows-зависимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

VARIABLE WINAPLINK
0  VALUE NEW-WINAPI?

: __WIN:  ( params "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  HERE >R
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  , \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  THEN
  HERE DUP R@ CELL+ CELL+ !
  PARSE-WORD HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE DUP R> CELL+ !
  PARSE-WORD HERE SWAP DUP ALLOT MOVE 0 C, \ имя библиотеки
  LoadLibraryA DUP 0= IF -2009 THROW THEN \ ABORT" Library not found"
  GetProcAddress 0= IF -2010 THROW THEN \ ABORT" Procedure not found"
;

: WINAPI: ( "ИмяПроцедуры" "ИмяБиблиотеки" -- )
  ( Используется для импорта WIN32-процедур.
    Полученное определение будет иметь имя "ИмяПроцедуры".
    Поле address of winproc будет заполнено в момент первого
    выполнения полученной словарной статьи.
    Для вызова полученной "импортной" процедуры параметры
    помещаются на стек данных в порядке, обратном описанному
    в Си-вызове этой процедуры. Результат выполнения функции
    будет положен на стек.
  )
  NEW-WINAPI?
  IF HEADER
  ELSE
    -1
    >IN @  HEADER  >IN !
  THEN
  ['] _WINAPI-CODE COMPILE,
  __WIN:
;

: EXTERN ( xt1 n -- xt2 )
  HERE
  SWAP LIT,
  ['] FORTH-INSTANCE> COMPILE,
  SWAP COMPILE,
  ['] <FORTH-INSTANCE COMPILE,
  RET,
;

: CALLBACK: ( xt n "name" -- )
\ Здесь n в байтах!
  EXTERN
  HEADER
  ['] _WNDPROC-CODE COMPILE,
  ,
;

: WNDPROC: ( xt "name" -- )
  4 CELLS CALLBACK:
;

: TASK ( xt1 -- xt2 )
  CELL EXTERN
  HERE SWAP
  ['] _WNDPROC-CODE COMPILE,
  ,
;
: TASK: ( xt "name" -- )
  TASK CONSTANT
;

: ERASE-IMPORTS
  \ обнуление адресов импортируемых процедур
  WINAPLINK
  BEGIN
    @ DUP
  WHILE
    DUP 4 CELLS - 0!
  REPEAT DROP
;
