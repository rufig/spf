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

\ в режиме компиляции используется отложенная компиляция врапперов впервые
\ вызванных апи-функций. Список функций, которые надо скомпилировать,
\ хранится во временном словаре widListFunc
USER widListFunc

\ Почти аналогично WINAPI: но в постфиксном стиле
: SWINAPI ( NameLibAddr addrИмяПроцедуры u -- )
  2DUP SHEADER
  ['] _WINAPI-CODE COMPILE,
  HERE WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  [ VERSION 400007 > [IF] ] -1 , [ [THEN] ] \ # of parameters
  HERE WINAPLINK @ , WINAPLINK ! ( связь )
  HERE WINAP @ CELL+ CELL+ !
  HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  WINAP @ CELL+ !
;

: STEMPWINAPI ( NameLibAddr addrИмяПроцедуры u -- )
  SHEADER
  , \ address of library name
;

\ Поиск функции, имя которой лежит в PAD, в подключенных длльках
: SEARCH-FUNC ( -- NameLibAddr ProcAddr t | f )
  [ ALSO API-FUNC-VOC CONTEXT @  PREVIOUS ] LITERAL
  @
  BEGIN
    ?DUP
  WHILE
    DUP NAME> EXECUTE DUP LoadLibraryA DUP 0= IF -2009 THROW THEN
    PAD SWAP GetProcAddress
    ?DUP IF ROT DROP TRUE EXIT THEN
    DROP CDR
  REPEAT
  FALSE
;

\ Выполнение найденной функции. В режиме компиляции функция заносится
\ в список для последующей компиляции. В режиме интерпретации - выполняется
: EXEC-FUNC ( coderr NameLibAddr ProcAddr u -- )
  STATE @ IF
    0 [ VERSION 400000 < [IF] ] COMPILE, [ [ELSE] ] _COMPILE, [ [THEN] ] 
    WARNING @ >R  FALSE WARNING !  GET-CURRENT >R  HERE 4 - >R
    widListFunc @ 0= IF TEMP-WORDLIST widListFunc ! THEN
    ALSO widListFunc @ CONTEXT ! DEFINITIONS
    NIP PAD SWAP STEMPWINAPI
    R> ,
    PREVIOUS
    R> SET-CURRENT R> WARNING !
    DROP
  ELSE DROP NIP NIP API-CALL
  THEN
;

: FindWrap ( a u -- FALSE | xt TRUE )
  2>R
  WINAPLINK
  BEGIN
    @ DUP
  WHILE
    DUP 2 CELLS - @ ASCIIZ> 2R@ COMPARE
    0= IF
      RDROP RDROP
      NEAR_NFA
      DROP NAME> TRUE EXIT
    THEN
  REPEAT DROP RDROP RDROP
  FALSE
;

\ Компиляция функции из списка и коррекция слова в котором она используется
: AddNodes ( widListFunc -- )
  @
  BEGIN
    ?DUP
  WHILE
    DUP >R
    COUNT FindWrap 0= IF
      GET-CURRENT FORTH-WORDLIST SET-CURRENT
      R@ NAME> @ R@ COUNT SWINAPI
      SET-CURRENT
      R@ COUNT FindWrap DROP
    THEN
    R@ NAME> CELL+ @ SWAP OVER CELL+ - SWAP !
    R> CDR
  REPEAT
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
          SEARCH-FUNC IF R> EXEC-FUNC
          ELSE
            ANSIAPI IF [CHAR] A ELSE [CHAR] W THEN  PAD R@ + C!
            R> 1+ >R
            0 PAD R@ + C!
            SEARCH-FUNC IF R> EXEC-FUNC ELSE RDROP THROW THEN
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
  widListFunc @ ?DUP IF
    DUP AddNodes
    FREE-WORDLIST
    widListFunc 0!
  THEN
; IMMEDIATE

TRUE WARNING !

PREVIOUS
