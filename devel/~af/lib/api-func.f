\ NOTFOUND для функций в dll  v1.3.2
\ Andrey Filatkin, 2001
\ Избавляет от необходимости объявлять используемые API-функции.
\ Подключение dll - USES "name.dll"
\ Все врапперы компилятся в словарь FORTH

REQUIRE [IF]     lib\include\tools.f
REQUIRE AddNode  ~ac\lib\list\str_list.f
REQUIRE ON       lib\ext\onoff.f

VOCABULARY API-FUNC-VOC \ в этом словаре хранится список dll,
\ в которых ищется функция
ALSO API-FUNC-VOC CONTEXT @  VALUE API-FUNC-WORDLIST
PREVIOUS

VARIABLE API-FUNC \ это либа сильно замедляет цикл интерпретации,
\ поэтому нужна возможность отключать ее
API-FUNC ON

VARIABLE ListFunc \ в режиме компиляции используется отложенная компиляция
\ врапперов впервые вызванных апи-функций. Список функций, которые надо
\ скомпилировать, хранится в динамическом списке ListFunc

: FreeListFunc ListFunc FreeList ;

: USES ( "name.dll" -- ) \ подключение dll к списку поиска
\ Имя dll может содержать путь и быть заключенным в скобки
\ При выполнении слова name.dll  в стек кладется адрес 0-строки
\ с именем длл
  SkipDelimiters GetChar IF
    [CHAR] " = IF [CHAR] " DUP SKIP PARSE ELSE NextWord THEN
  ELSE DROP NextWord THEN
  2DUP API-FUNC-WORDLIST SEARCH-WORDLIST 0= IF
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

\ Почти аналогично WINAPI: но в постфиксном стиле
: SWINAPI ( NameLibAddr addrИмяПроцедуры u -- )
  2DUP SHEADER
  ['] _WINAPI-CODE COMPILE,
  HERE WINAP !
  0 , \ address of winproc
  0 , \ address of library name
  0 , \ address of function name
  [ S" FORTH-SYS" ENVIRONMENT? DROP S" SPF4+" COMPARE 0= [IF] ] 
    0 , \ # of parameters
  [ [THEN] ] 
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
  API-FUNC-WORDLIST @
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
    SWAP _COMPILE,
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
  R@ CELL+ CELL+ @ TUCK CELL+ - SWAP !
  R@ @ FREE THROW
  R> FREE THROW
;

FALSE WARNING !
: NOTFOUND ( addr u -- )
  2DUP >R >R ['] NOTFOUND CATCH ?DUP
  IF
    API-FUNC @ IF
      NIP NIP  R> PAD R@ MOVE
      PAD R@ + 0 SWAP C!
      SEARCH-FUNC IF R> EXEC-FUNC
      ELSE
        PAD R@ + [CHAR] A SWAP C!
        R> 1+ >R
        PAD R@ + 0 SWAP C!
        PAD R@ SFIND ?DUP IF
          ROT DROP RDROP STATE @ = IF COMPILE, ELSE EXECUTE THEN
        ELSE
          2DROP SEARCH-FUNC IF R> EXEC-FUNC
          ELSE
            PAD R@ 1- + [CHAR] W SWAP C!
            PAD R@ SFIND ?DUP IF
              ROT DROP RDROP STATE @ = IF COMPILE, ELSE EXECUTE THEN
            ELSE
              2DROP SEARCH-FUNC IF R> EXEC-FUNC ELSE RDROP THROW THEN
            THEN
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
