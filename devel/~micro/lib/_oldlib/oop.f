USER CREATING-CLASS
USER WAS-CURRENT

\ ===============  Описание классов  =================

: INTERPRET-METHOD ( wid -- )
\ Компилирует или исполняет слово из словаря wid
 NextWord ROT
  SEARCH-WORDLIST IF
    STATE @ IF
      COMPILE,
    ELSE
      EXECUTE
    THEN
  ELSE
    ABORT" Unknown field or method."
  THEN
;

: CLASS: ( -- addr )
\ Зоздаёт класс. Класс - слово типа CREATE DOES>. В поле параметров 2 CELL-а:
\ wid словаря и размер структуры. Класс имеет признак IMMEDIATE.
  CURRENT @ WAS-CURRENT !
  WORDLIST
  CREATE IMMEDIATE
  HERE CREATING-CLASS !
  DUP ,
  0 ,
  ALSO CONTEXT ! DEFINITIONS
  DOES>
  @ INTERPRET-METHOD
;

: ;CLASS ( addr -- )
\ Завершение описания класса
  PREVIOUS
  WAS-CURRENT @ CURRENT !
;

: SIZEOF
\ Определение размера экземпляра данного класса
  ' >BODY CELL+ @
;

: WIDOF
\ wid словаря класса
  ' >BODY @
;

: INST
  SIZEOF CREATE HERE OVER ALLOT SWAP ERASE
;

\ ================  Задание класса по умолчанию  =================

: WITH
  ' >BODY @ ALSO CONTEXT !
; IMMEDIATE

: ENDWITH
  PREVIOUS
; IMMEDIATE

\ =================  Описание полей  ====================

: FIELDS
  0
  BEGIN
    REFILL 0= ABORT" Structure not closed by ';'"
    NextWord S" ;" COMPARE
  WHILE
    INTERPRET
    0 >IN ! --
  REPEAT
  CREATING-CLASS @ CELL+ +!
;

\ ============  Описание чистых структур, без методов  ===============

: STRUCT:
  CLASS:
  FIELDS
  ;CLASS
;

\ ======================  Наследование  ========================

: CHILD
  ' >BODY ( parent )
  CLASS: ( parent )
  DUP CELL+ @
  CREATING-CLASS @ CELL+ !
  @ @
  CREATING-CLASS @ @ !
;

\ ==================  Описание объекта  ==================

: OBJECT
  ' >BODY
  CREATE
  DUP @ , CELL+ @ ALLOT
  DOES>
  DUP CELL+ SWAP @
  INTERPRET-METHOD
;

\ ======================  Debug  =========================

: SHOWCLASS
  >IN @
  WIDOF NLIST
  >IN !
  SIZEOF ." Size=" .
;
