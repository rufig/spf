\ Windows loadable constants support for spf375
\ (c) Dmitry Yakimov 30.05.2000

\ Windows loadable constants compiler for spf375
\ (c) Dmitry Yakimov 30.05.2000

(

Компилятор констант. 

Если встречаем константу, которая
уже есть в дереве, то она игнорируется.

Строим бинарное дерево в непрерывном прстранстве данных.
Все смещения относительно начала словаря.

Можно искать по бинарному дереву [как и было в первой версии], но
дерево получается неравновесное и поиск иногда может быть долгим
[при поиске порядка 100000 значений].

Поэтому итоговый файл в формате ~yz.
Мои словари прекрасно подходят к ~yz\wincons.f
Хотя для порядка сделал свой форт модуль для подключения.

)


0 VALUE CURRENT-VOC
VARIABLE CONST-COUNT

500000 TO WL_SIZE
TEMP-WORDLIST VALUE tt

: BEGIN-CONST
   S" Wait a bit..." TYPE
   tt SET-CURRENT
   HERE TO CURRENT-VOC
   CONST-COUNT 0!
;


\ Формат дерева:
\ Ссылка на левый son - 4
\ Ссылка на правый son - 4
\ Значение константы  - 4
\ Размер имени константы - 1
\ Тело имени константы

0
CELL -- .lson
CELL -- .rson
CELL -- .value
   1 -- .length
DROP   
   
: ADD-NODE ( u1 addr u2 -- addr2 )
     HERE >R
     0 ,  \ lson
     0 ,  \ rson
     ROT , \ value
     DUP C, HERE OVER ALLOT
     SWAP CMOVE
     R>
;

: ADD-LEFT ( u1 addr u2 dad -- )
     >R ADD-NODE R> .lson !
;

: ADD-RIGHT ( u1 addr u2 dad -- )
     >R ADD-NODE R> .rson !
;

: INSERT-NODE ( u1 addr u2 dad -- )
    HERE CURRENT-VOC -
    IF
      >R 2DUP
      R@ .length 1+ 
      R@ .length C@ COMPARE -1 =
      IF \ left
        R@ .lson @ 0=
        IF
           R> ADD-LEFT
        ELSE
           R> .lson @ RECURSE 
        THEN
      ELSE \ right
        R@ .rson @ 0=
        IF
          R> ADD-RIGHT
        ELSE
          R> .rson @ RECURSE
        THEN
      THEN
    ELSE \ первая константа
      DROP ADD-NODE DROP
    THEN
;


\ Эту функцию можно в INSERT-NODE вставить, но все-равно необходимо иметь
\ слово для поиска констант

: _SEARCH-NODE ( addr u node -- u -1 | 0 )
    >R 2DUP
    R@ .length 1+
    R@ .length C@ COMPARE ?DUP
    IF
       -1 = IF
              R@ .lson @ 0=
              IF \ не нашли
                RDROP 2DROP 0
              ELSE
                R> .lson @ RECURSE
              THEN
            ELSE
              R@ .rson @ 0=
              IF \ не нашли
                RDROP 2DROP 0
              ELSE
                R> .rson @ RECURSE
              THEN
            THEN
    ELSE
      2DROP R> .value @ -1
    THEN
;

: SEARCH-NODE ( addr u -- u -1 | 0 )
    CURRENT-VOC HERE =
    IF
      2DROP 0
    ELSE
      CURRENT-VOC _SEARCH-NODE
    THEN
;

0 VALUE CURR-STUB
0 VALUE CONST-BODIES
VARIABLE COUNT-COMPILED

: ADD-TO-STUB ( node -- )
     HERE CURR-STUB - 8 +
     COUNT-COMPILED @ CELLS CURR-STUB + !
     DUP .value @ , 
     .length DUP 1+ SWAP C@ \ addr u
     DUP C,
     HERE OVER ALLOT
     SWAP CMOVE
     COUNT-COMPILED 1+!
;

: MAKE-STUB ( node -- )
    ?DUP
    IF
      DUP .lson @ RECURSE
      DUP ADD-TO-STUB
      .rson @ RECURSE
    THEN
;

: FORM-STUB
    [CHAR] C C, [CHAR] O C,
    [CHAR] N C, [CHAR] S C,
    CONST-COUNT @ ,
    HERE TO CURR-STUB        
    CONST-COUNT @ CELLS ALLOT
    HERE TO CONST-BODIES
    COUNT-COMPILED 0!
    CURRENT-VOC MAKE-STUB
;

: SAVE-CONST ( c-addr u -- )
   FORM-STUB
   W/O CREATE-FILE THROW >R
   HERE CURR-STUB - 8 +
   CURR-STUB 8 - SWAP R@ WRITE-FILE THROW DROP
   R> CLOSE-FILE
   CONST-COUNT @ . ."  constants was written" CR
;

: _CONSTANT ( u1 addr u2 -- )
    2DUP SEARCH-NODE
    IF
       2DROP 2DROP
    ELSE
       CURRENT-VOC INSERT-NODE
       CONST-COUNT 1+!
    THEN
;

: CONSTANT
    NextWord _CONSTANT
;

: #define
    BASE @ >R
    NextWord NextWord S" 0x" SEARCH
    IF HEX ELSE DECIMAL THEN
    EVALUATE R> BASE !
    ROT ROT  _CONSTANT
    0 PARSE 2DROP
;

\ На случай когда одна константа через другую переопределяется

: NOTFOUND ( addr u -- )
  2DUP 2>R ['] ?SLITERAL2 CATCH ?DUP
  IF
    NIP NIP 2R>
    SEARCH-NODE
    IF NIP [COMPILE] LITERAL
    ELSE
       THROW
    THEN
  ELSE 2R> 2DROP
  THEN
;

\ Example

(
BEGIN-CONST

4 CONSTANT xx
5 CONSTANT xxx
6 CONSTANT xxxxx
7 CONSTANT x

#define x1 xxx


\ Или файл сюда вставить

 S" test.dat" SAVE-CONST


)
(
BEGIN-CONST

stealconst.f
winsock.f

S" windows.const" SAVE-CONST )