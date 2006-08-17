USER CREATING-CLASS
USER WAS-CURRENT
USER ALSO-FOR-ONE

\ ===============  Описание классов  =================

: ?PREVIOUS
  ALSO-FOR-ONE @ IF
    PREVIOUS
    ALSO-FOR-ONE 0!
  THEN
;

: |CLASS
  ?PREVIOUS
; IMMEDIATE

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
  ?PREVIOUS
  ALSO
  @ CONTEXT !
  1 ALSO-FOR-ONE !
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
  ?PREVIOUS
  ' EXECUTE
  ALSO-FOR-ONE 0!
; IMMEDIATE

: ENDWITH
  ?PREVIOUS
  PREVIOUS
; IMMEDIATE

\ ======================  Наследование  ========================

: CHILD: ( -- size )
  ' >BODY ( parent )
  CLASS: SWAP ( size parent )
  DUP @ @
  CREATING-CLASS @ @ !
  CELL+ @ +
;
