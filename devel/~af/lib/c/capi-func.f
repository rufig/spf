\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ NOTFOUND для функций в dll, экспортированных по c-правилам -
\ стек чистит вызывающий.
\ Подключение dll - USES_C "name.dll". Имя dll может содержать путь и быть
\ заключенным в ковычки.
\ Все врапперы компилятся в словарь FORTH

REQUIRE ((	~af\lib\c\prefixfun.f
REQUIRE CAPI:	~af\lib\c\capi.f
REQUIRE USES	~af\lib\api-func.f

\ в этом словаре хранится список dll, в которых ищется функция
VOCABULARY CAPI-FUNC-VOC

GET-CURRENT ALSO APISupport DEFINITIONS

: SCAPI ( n NameLibAddr addrИмяПроцедуры u -- )
  <# ROT ASCIIZ> HOLDS S"  " HOLDS HOLDS
  S" CAPI: " HOLDS S"  " HOLDS S>D #S #> EVALUATE
;

\ Поиск функции, имя которой лежит в PAD, в подключенных длльках
: SEARCH-CFUNC ( -- NameLibAddr ProcAddr t | f )
  [ ALSO CAPI-FUNC-VOC CONTEXT @  PREVIOUS ] LITERAL (SEARCH-FUNC)
;

\ Выполнение найденной функции. В режиме компиляции функция заносится
\ в список для последующей компиляции. В режиме интерпретации - выполняется
: EXEC-CFUNC ( n NameLibAddr ProcAddr u -- )
  STATE @ IF
    NIP ,FUNC
  ELSE DROP NIP CAPI-CALL
  THEN
;

: (AddFuncNode2) ( node -- )
  NodeValue DUP >R
  @ ASCIIZ> FindWrap 0= IF
    GET-CURRENT FORTH-WORDLIST SET-CURRENT
    R@ 3 CELLS + @ DUP -1 = IF
      DROP R@ CELL+ @   R@ @ ASCIIZ>   SWINAPI
    ELSE
      R@ CELL+ @   R@ @ ASCIIZ>   SCAPI
    THEN
    SET-CURRENT
    R@ @ ASCIIZ> FindWrap DROP
  THEN
  R@ CELL+ CELL+ @ SWAP OVER CELL+ - SWAP !
  R@ @ FREE THROW
  R> FREE THROW
;
' (AddFuncNode2) TO AddFuncNode

SET-CURRENT

: USES_C ( "name.dll" -- ) \ подключение dll к списку поиска
  [ ALSO CAPI-FUNC-VOC CONTEXT @  PREVIOUS ] LITERAL (USES)
;

FALSE WARNING !
: NOTFOUND ( addr u -- )
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF
    API-FUNC @ IF
      PFSupport::curname IF
        2R@ COMPARE 0= IF
          NIP NIP  2R> PAD SWAP DUP >R MOVE
          0 PAD R@ + C!
          SEARCH-CFUNC IF ROT DROP PFSupport::count ROT ROT R> EXEC-CFUNC
          ELSE RDROP THROW
          THEN
        ELSE RDROP RDROP THROW
        THEN
      ELSE RDROP RDROP THROW
      THEN
    ELSE RDROP RDROP THROW
    THEN
  ELSE RDROP RDROP
  THEN
;

TRUE WARNING !

PREVIOUS
