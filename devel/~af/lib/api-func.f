\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ NOTFOUND для функций в dll
\ Избавляет от необходимости объявлять используемые API-функции.
\ Подключение dll - USES "name.dll". Имя dll может содержать путь и быть
\ заключенным в ковычки. При выполнении слова name.dll в стек кладется
\ адрес 0-строки с именем длл.
\ Порядок поиска: сначала ищется враппер функции в оригинальном написании.
\ Если не найден, то ищем враппер с добавленным суффиксом - сначала с A, потом
\ с W. Если враппера нет - ищем в подключенных dll-ка. Сначала в оригинальном
\ написании, затем с суффиксом - если ANSIAPI ON то с A, иначе с W.
\ Все врапперы компилятся в словарь FORTH

REQUIRE [DEFINED]  lib\include\tools.f
REQUIRE AddNode    ~ac\lib\list\str_list.f
REQUIRE ON         lib\ext\onoff.f

[UNDEFINED] HOLDS [IF]
  : HOLDS ( addr u -- ) \ from eserv src
    SWAP OVER + SWAP 0 ?DO DUP I - 1- C@ HOLD LOOP DROP
  ;
[THEN]
[UNDEFINED] SEARCH-IN-LIST [IF]
  : SEARCH-IN-LIST ( a u list -- FALSE | addr TRUE )
    ROT ROT 2>R
    BEGIN
      @ DUP
    WHILE
      DUP CELL+ ASCIIZ> 2R@ COMPARE
      0= IF
        RDROP RDROP
        CELL+ TRUE EXIT
      THEN
    REPEAT DROP RDROP RDROP
    FALSE
  ;
[THEN]

\ в этом списке хранятся имена dll, в которых ищется функция
VARIABLE DLL-LIST
VARIABLE ANSIAPI
ANSIAPI ON
\ либа замедляет цикл интерпретации, поэтому нужна возможность отключать ее
VARIABLE API-FUNC
API-FUNC ON

: USES ( "name.dll" -- ) \ подключение dll к списку поиска
  SkipDelimiters GetChar IF
    [CHAR] " = IF [CHAR] " DUP SKIP PARSE ELSE NextWord THEN
  ELSE DROP NextWord THEN
  2DUP
  DLL-LIST SEARCH-IN-LIST 0= IF
    2DUP + 0 SWAP C!
    OVER LoadLibraryA 0= IF -2009 THROW THEN
    GET-CURRENT >R FORTH-WORDLIST SET-CURRENT
    HERE DLL-LIST @ , DLL-LIST ! ( связь )
    1+ HERE SWAP DUP ALLOT MOVE
    R> SET-CURRENT
  ELSE
    DROP 2DROP
  THEN
;

VOCABULARY APISupport
GET-CURRENT ALSO APISupport DEFINITIONS

\ в режиме компиляции используется отложенная компиляция врапперов впервые
\ вызванных апи-функций. Список функций, которые надо скомпилировать,
\ хранится в динамическом списке ListFunc
USER ListFunc

: FreeListFunc ListFunc FreeList ;

: SWINAPI ( NameLibAddr addrИмяПроцедуры u -- )
  <# ROT ASCIIZ> HOLDS S"  " HOLDS HOLDS S" WINAPI: " HOLDS 0 0 #> EVALUATE
;

\ Поиск функции, имя которой лежит в PAD, в подключенных длльках
: SEARCH-FUNC ( -- NameLibAddr ProcAddr t | f )
  DLL-LIST
  BEGIN
    @ ?DUP
  WHILE
    DUP CELL+ LoadLibraryA DUP 0= IF -2009 THROW THEN
    PAD SWAP GetProcAddress
    ?DUP IF SWAP CELL+ SWAP TRUE EXIT THEN
  REPEAT
  FALSE
;

\ Выполнение найденной функции. В режиме компиляции функция заносится
\ в список для последующей компиляции. В режиме интерпретации - выполняется
: EXEC-FUNC ( NameLibAddr ProcAddr u -- )
  STATE @ IF
    NIP
    0 [ VERSION 400000 < [IF] ] COMPILE, [ [ELSE] ] _COMPILE, [ [THEN] ]
    3 CELLS ALLOCATE THROW >R
    PAD SWAP HEAP-COPY R@ ! \ 1-ячейка - ссылка на имя процедуры
    R@ CELL+ !               \ 2-ячейка - ссылка на имя библиотеки
    HERE 4 - R@ CELL+ CELL+ ! \ 3-ячейка - адрес для коррекции
    R> ListFunc AddNode
  ELSE DROP NIP API-CALL
  THEN
;

: FindWrap ( a u -- FALSE | xt TRUE )
  2>R
  WINAPLINK
  BEGIN
    @ DUP
  WHILE
    DUP
    [ VERSION 400007 > [IF] ] 2 CELLS - [ [ELSE] ] CELL- [ [THEN] ]
    @ ASCIIZ> 2R@ COMPARE
    0= IF
      RDROP RDROP
      WordByAddr
      DROP 1- NAME> TRUE EXIT
    THEN
  REPEAT DROP RDROP RDROP
  FALSE
;

\ Компиляция функции из списка и коррекция слова в котором она используется
: AddFuncNode ( node -- )
  NodeValue DUP >R
  @ ASCIIZ> FindWrap 0= IF
    GET-CURRENT FORTH-WORDLIST SET-CURRENT
    R@ CELL+ @   R@ @ ASCIIZ>   SWINAPI
    SET-CURRENT
    R@ @ ASCIIZ> FindWrap DROP
  THEN
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
      [CHAR] A  PAD R@ + C!
      PAD R@ 1+ FindWrap IF
        NIP RDROP STATE @ IF COMPILE, ELSE EXECUTE THEN
      ELSE
        [CHAR] W  PAD R@ + C!
        PAD R@ 1+ FindWrap IF
          NIP RDROP STATE @ IF COMPILE, ELSE EXECUTE THEN
        ELSE
          0 PAD R@ + C!
          SEARCH-FUNC IF ROT DROP R> EXEC-FUNC
          ELSE
            ANSIAPI IF [CHAR] A ELSE [CHAR] W THEN  PAD R@ + C!
            R> 1+ >R
            0 PAD R@ + C!
            SEARCH-FUNC IF ROT DROP R> EXEC-FUNC ELSE RDROP THROW THEN
          THEN
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
