\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ NOTFOUND для функций в dll
\ Избавляет от необходимости объявлять используемые API-функции.
\ Подключение dll - USES "name.dll"
\ Все врапперы компилятся в словарь FORTH

REQUIRE [DEFINED]  lib\include\tools.f
REQUIRE AddNode    devel\~ac\lib\list\str_list.f
REQUIRE ON         lib\ext\onoff.f

[UNDEFINED] SHEADER [IF]
  : SHEADER ( addr u -- )
    HERE 0 , ( cfa )
    0 C,     ( flags )
    ROT ROT WARNING @
    IF 2DUP GET-CURRENT SEARCH-WORDLIST
       IF DROP 2DUP TYPE ."  isn't unique" CR THEN
    THEN
    CURRENT @ +SWORD
    ALIGN
    HERE SWAP ! ( заполнили cfa )
  ;
  : CREATED ( addr u -- )
    SHEADER
    HERE DOES>A ! ( для DOES )
    ['] _CREATE-CODE COMPILE,
  ;
[THEN]

\ в этом словаре хранится список dll, в которых ищется функция
VOCABULARY API-FUNC-VOC
\ либа замедляет цикл интерпретации, поэтому нужна возможность отключать ее
USER API-FUNC
API-FUNC ON
\ Ищем функцию сначала в оригинальном написании. Если не нашли, то
\ ищем с добавленным суффиксом - если ANSIAPI ON то с A, иначе с W.
USER ANSIAPI
ANSIAPI ON

: USES ( "name.dll" -- ) \ подключение dll к списку поиска
\ Имя dll может содержать путь и быть заключенным в скобки
\ При выполнении слова name.dll  в стек кладется адрес 0-строки
\ с именем длл
  SkipDelimiters GetChar IF
    [CHAR] " = IF [CHAR] " DUP SKIP PARSE ELSE NextWord THEN
  ELSE DROP NextWord THEN
  2DUP
  [ ALSO API-FUNC-VOC CONTEXT @  PREVIOUS ] LITERAL
  SEARCH-WORDLIST 0= IF
    2DUP + 0 SWAP C!
    OVER LoadLibraryA 0= IF -2009 THROW THEN
    GET-CURRENT >R ALSO API-FUNC-VOC DEFINITIONS
    2DUP CREATED
    1+ HERE OVER ALLOT
    SWAP MOVE
    PREVIOUS R> SET-CURRENT
  ELSE
    DROP 2DROP
  THEN
;

VOCABULARY APISupport
GET-CURRENT ALSO APISupport DEFINITIONS

\ в режиме компиляции используется отложенная компиляция
\ врапперов впервые вызванных апи-функций. Список функций, которые надо
\ скомпилировать, хранится в динамическом списке ListFunc
USER ListFunc

: FreeListFunc ListFunc FreeList ;

\ Почти аналогично WINAPI: но в постфиксном стиле
: SWINAPI ( NameLibAddr addrИмяПроцедуры u -- )
  2DUP SHEADER
  ['] _WINAPI-CODE COMPILE,
  HERE WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  [ VERSION 400007 > [IF] ] -1 , [ [THEN] ] \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  THEN
  HERE WINAP @ CELL+ CELL+ !
  HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  WINAP @ CELL+ !
;

\ Поиск функции, имя которой лежит в PAD, в подключенных длльках
: SEARCH-FUNC ( -- NameLibAddr ProcAddr t | f )
  [ ALSO API-FUNC-VOC CONTEXT @  PREVIOUS ] LITERAL
  @
  BEGIN
    DUP
  WHILE
    DUP NAME> EXECUTE DUP LoadLibraryA DUP 0= IF -2009 THROW THEN
    PAD SWAP GetProcAddress
    ?DUP IF ROT DROP TRUE EXIT THEN
    DROP CDR
  REPEAT
  DROP
  FALSE
;

\ Выполнение найденной функции. В режиме компиляции функция заносится
\ в список для последующей компиляции. В режиме интерпретации - выполняется
: EXEC-FUNC ( coderr NameLibAddr ProcAddr u -- )
  STATE @ IF
    SWAP
    [ VERSION 400000 < [IF] ] COMPILE, [ [ELSE] ] _COMPILE, [ [THEN] ] 
    3 CELLS ALLOCATE THROW >R 
    PAD SWAP HEAP-COPY R@ ! \ 1-ячейка - ссылка на имя процедуры
    R@ CELL+ ! \ 2-ячейка - ссылка на имя библиотеки
    HERE 4 - R@ CELL+ CELL+ ! \ 3-ячейка - адрес для коррекции
    DROP
    R> ListFunc AddNode
  ELSE DROP NIP NIP API-CALL
  THEN
;

\ Компиляция функции из списка и коррекция слова в котором она используется
: AddFuncNode ( node -- )
  NodeValue >R
  R@ @ ASCIIZ> SFIND 0= IF
    2DROP
    GET-CURRENT FORTH-WORDLIST SET-CURRENT
    R@ CELL+ @
    R@ @ ASCIIZ>
    SWINAPI
    SET-CURRENT
  ELSE
    DROP
  THEN
  R@ @ ASCIIZ> SFIND DROP
  R@ CELL+ CELL+ @ SWAP OVER CELL+ - SWAP !
  R@ @ FREE THROW
  R> FREE THROW
;

SET-CURRENT

FALSE WARNING !
: NOTFOUND ( addr u -- )
  2DUP >R >R ['] NOTFOUND CATCH ?DUP
  IF
    API-FUNC @ IF
      NIP NIP  R> PAD R@ MOVE
      ANSIAPI IF [CHAR] A ELSE [CHAR] W THEN  PAD R@ + C!
      PAD R@ 1+ SFIND ?DUP IF
        ROT DROP RDROP STATE @ = IF COMPILE, ELSE EXECUTE THEN
      ELSE
        2DROP
        0 PAD R@ + C!
        SEARCH-FUNC IF R> EXEC-FUNC
        ELSE
          ANSIAPI IF [CHAR] A ELSE [CHAR] W THEN  PAD R@ + C!
          R> 1+ >R
          0 PAD R@ + C!
          SEARCH-FUNC IF R> EXEC-FUNC ELSE RDROP THROW THEN
        THEN
      THEN
    ELSE RDROP RDROP THROW
    THEN
  ELSE RDROP RDROP
  THEN
;

: ;
  POSTPONE ;
  ['] AddFuncNode ListFunc DoList
  FreeListFunc
; IMMEDIATE

TRUE WARNING !

PREVIOUS
