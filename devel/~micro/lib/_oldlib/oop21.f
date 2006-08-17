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

: CLASS: ( -- size )
\ Зоздаёт класс. Класс - слово типа CREATE DOES>. В поле параметров 2 CELL-а:
\ wid словаря и размер структуры. Класс имеет признак IMMEDIATE.
  CURRENT @ WAS-CURRENT !
  WORDLIST
  CREATE IMMEDIATE
  HERE CREATING-CLASS !
  DUP ,
  0 ,
  ALSO CONTEXT ! DEFINITIONS 0
  DOES>
  @ INTERPRET-METHOD
;

: VREST
  PREVIOUS
  WAS-CURRENT @ CURRENT !
;

: ;CLASS ( size -- )
\ Завершение описания класса
  CREATING-CLASS @ CELL+ !
  VREST
;

: >SIZEOF
  >BODY CELL+ ;

: SIZEOF
\ Определение размера экземпляра данного класса
  ' >SIZEOF @
;

: >WIDOF
  >BODY ;


: WIDOF
\ wid словаря класса
  ' >WIDOF @
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

\ ======================  Наследование  ========================

: CHILD ( -- size )
  ' >BODY ( parent )
  CLASS: SWAP ( size parent )
  DUP @ @
  CREATING-CLASS @ @ !
  CELL+ @ +
;
