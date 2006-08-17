USER CREATING-CLASS
USER WAS-CURRENT
USER ALSO-FOR-ONE
USER SIZE-ADDR

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

: ALSO-IT ( wid )
  ALSO
  CONTEXT !
  1 ALSO-FOR-ONE !
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
  SP@ SIZE-ADDR !
  DOES>
  ?PREVIOUS
  @ ALSO-IT
;

: VREST
  PREVIOUS
  WAS-CURRENT @ CURRENT !
;

: MYSIZE
  SIZE-ADDR @ @ POSTPONE LITERAL
; IMMEDIATE

: ;CLASS ( size -- )
\ Завершение описания класса
  ?PREVIOUS
  CREATING-CLASS @ CELL+ !
  VREST
;

: >SIZEOF
  >BODY CELL+ ;

: SIZEOF
\ Определение размера экземпляра данного класса
  ' >SIZEOF @ POSTPONE LITERAL
; IMMEDIATE

: >WIDOF
  >BODY ;


: WIDOF
\ wid словаря класса
  ' >WIDOF @ POSTPONE LITERAL
; IMMEDIATE

: INST
  ' >SIZEOF @ CREATE HERE OVER ALLOT SWAP ERASE
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
