( Yet another oop extention for sp-forth - just oop :)
( Dmitry Yakimov 2000 [c] ver. 1.5 )

HERE

\ structure of class:
0
CELL -- .vtbl       \ for ActiveX
CELL -- .myself     \ link on myself
CELL -- .methods    \ wid of methods
CELL -- .size       \ size of class instance
CELL -- .parent     \ parent class
CELL -- .name       \ link to class name    
CELL -- .variables  \ wid of variables
CONSTANT /class

\ При компиляции класса ORDER: 
\ CONTEXT: wid_of_vars FORTH
\ CURRENT: wid_of_methods

USER-VALUE self
USER ERR-M

VOCABULARY ClassContext

: this self ;
: class ( oid - u) CELL+ @ ;
: len ( cid - u) class .size @ ;

: execMessage ( addr u wid -- ... )
  SEARCH-WORDLIST
  IF   EXECUTE
  ELSE S" :unknown" self class .methods @ RECURSE
  THEN
;

: sendMessage ( ... addr u oid -- ... )
  self >R
  DUP TO self
  class .methods @  
  execMessage
  R> TO self
;

0 VALUE message_does

: message, ( oid )
  CREATE LATEST ,
  [ HERE TO message_does ]
  DOES> @ DUP ERR-M !
        COUNT ROT sendMessage
;

: message: ( oid )
  >IN @ NextWord SFIND
  IF 2DROP
  ELSE 2DROP >IN ! 
       message,
  THEN
;

: sendVariable ( ... addr u oid -- ... )
    DUP >R class .variables @ 
    SEARCH-WORDLIST
    IF
      >BODY @ R> +
    ELSE
      R@ TO self
      S" :unknown" R> class .methods @ SEARCH-WORDLIST DROP EXECUTE
    THEN
;

: pvar,
    CREATE LATEST ,
    DOES> @ DUP ERR-M !
          DUP C@ 1- SWAP 2 + SWAP
          ROT sendVariable    
;

: pvar:
  >IN @ NextWord SFIND
  IF 2DROP
  ELSE 2DROP >IN ! 
       pvar,
  THEN
;
  
: << message: ;


VARIABLE _NVAR
VARIABLE _CURCLASS
VARIABLE _REC
VARIABLE _RECLEN
VARIABLE _OLDCURRENT

<< :new
<< :free

ALSO ClassContext DEFINITIONS

: [C] \ Установить current словарем текущего класса
   _CURCLASS @ .methods @ SET-CURRENT
;

: RECORD:
   _NVAR @ DUP _REC ! 
   DEFINITIONS
   CREATE , [C] HERE _RECLEN ! 0 , ['] 2DROP , ['] DROP ,
   DOES> @ self +
;

: /REC
   _NVAR @ _REC @ -
   _RECLEN @ !
;

: size: ( "rec" -- u)
    ' >BODY CELL+ @ LIT,
; IMMEDIATE


\ addr указывает на область данных переменной-экземпляра
\ oid - текущий экземпляр
: _OBJ ( oid addr)
   DUP CELL+ @ :new
   SWAP @ ROT + ! 
;
: _FREE-OBJ ( oid)
   :free
;

: _ARR ( oid addr)
   DUP CELL+ @ DUP ALLOCATE THROW
   DUP ROT ERASE
   SWAP @ ROT + !
;
: _FREE-ARR ( addr)
   FREE THROW
;

: ARR ( len)
   DEFINITIONS
   CREATE
     [C] _NVAR @ ,
     ,
     CELL _NVAR +!
     ['] _ARR ,
     ['] _FREE-ARR ,
   DOES> @ self + @
;

: OBJ ( cid)
   DEFINITIONS
   CREATE
     [C] _NVAR @ ,
     ,
     CELL _NVAR +!
     ['] _OBJ ,
     ['] _FREE-OBJ ,
   DOES> @ self + @
;

: VAR ( u)
   DEFINITIONS 
   CREATE
     [C]
     _NVAR @ ,
     DUP ,
     _NVAR +!
     ['] 2DROP ,
     ['] DROP ,
   DOES> @ self +
;


: InitObj ( oid)
     class .variables @ @
     BEGIN
       DUP
     WHILE
       2DUP
       NAME> >BODY DUP CELL+
       CELL+ @ EXECUTE
       CDR
     REPEAT DROP
;

: <SUPER ( "name" )
   _CURCLASS @ >R
   ' >BODY
   DUP .size @ _NVAR !
   DUP .methods @ @ R@ .methods @ !
   DUP .variables @ @ R@ .variables @ !
   R> .parent !
;

: ;CLASS PREVIOUS PREVIOUS
         _OLDCURRENT @ SET-CURRENT
         _NVAR @ _CURCLASS @ .size !
;

WARNING @ WARNING 0!

: :
  >IN @
  NextWord SFIND
  IF
  DUP 1+ @ + message_does
  = IF
      WARNING @
      WARNING 0! SWAP >IN ! :
      WARNING !
    ELSE >IN ! :
    THEN
  ELSE 2DROP >IN ! :
  THEN
;

: abstract S" You can't call abstract method!" ER-U ! ER-A ! -2 THROW ;

: x: 
   : POSTPONE abstract
;

WARNING !

PREVIOUS FORTH DEFINITIONS

: CLASS: ( - )
   GET-CURRENT _OLDCURRENT !
   ALSO ClassContext
   WORDLIST DUP ALSO CONTEXT !  \ wid of variables
   WORDLIST DUP                 \ wid of methods
   CREATE
     LATEST SWAP SET-CURRENT
     HERE >R /class ALLOT
     R@ /class ERASE
     R@ DUP .myself !
     R@ _CURCLASS !
     R@ .name !
     R@ .methods !
     R> .variables !
;

: own
    ?COMP
    CONTEXT @
    GET-CURRENT CONTEXT !
    [COMPILE] '  COMPILE,
    CONTEXT !
; IMMEDIATE

\ from micro
: >CLASS ' >BODY .methods @ CONTEXT ! ;

: M:: ( c "WM_..." -- )
  \ определить обработчик сообщения
  \ c - символ типа сообщения
  BASE @ >R 
  NextWord EVALUATE HEX \ Для того чтобы Windows константы искались
  0 <# # # # #  # # # # ROT HOLD BL HOLD [CHAR] : HOLD #>
  EVALUATE
  R> BASE !
;

: W: [CHAR] W M:: ; \ WM_...
: C: [CHAR] C M:: ; \ WM_COMMAND 
: N: [CHAR] N M:: ; \ WM_NOTIFY  
: P: [CHAR] P M:: ; \ WM_PARENTNOTIFY
: M: [CHAR] M M:: ; \ меню

: SearchWM ( mess_id oid c -- xt -1 | 0)
  ROT BASE @ >R HEX
  0 <# # # # #  # # # # ROT HOLD #>
  ROT class .methods @ SEARCH-WORDLIST
  R> BASE !
;

: ExecuteMethod ( xt oid)
   self >R
   TO self
   EXECUTE
   R> TO self
;

: ->WM ( mess_id oid c)
\ Послать заданное сообщение объекту
  OVER >R SearchWM
  IF R> ExecuteMethod
  ELSE R> DROP
  THEN
;

: WM:
   [CHAR] W ->WM
;

: INHERITWM ( -- )
\ Наследование слов типа ->WM
   SMUDGE
   LATEST COUNT DUP >R
   PAD SWAP CMOVE
   HIDE PAD R>
   GET-CURRENT SEARCH-WORDLIST
   IF
     COMPILE,
   THEN
; IMMEDIATE

<< :unknown
<< :see
<< :name
<< :length
<< :super
<< :free
<< :new
<< :newLit
<< :methods
<< :variables
<< :init


pvar: <vVTBL

CLASS: Object

   CELL VAR vVTBL \ таблица методов интерфейса
   CELL VAR vClassID

: :length ( - u)
     self len
;

\ метод - заглушка
: :init
;

: :new ( - oid)
     self class len DUP ALLOCATE THROW
     DUP ROT ERASE
     self OVER CELL+ ! DUP TO self
     DUP CELL+ @ OVER CELL- !
     DUP InitObj
     self :init
;

: :newLit ( - oid)
     self class len HERE OVER ALLOT
     DUP ROT ERASE
     self OVER CELL+ ! DUP TO self
     DUP InitObj
     self :init
;

: :free 
     self class .variables @ @
     BEGIN
       DUP
     WHILE
       DUP NAME> >BODY
       DUP @ self + @ \ получили экземпляр
       SWAP 3 CELLS + @ EXECUTE
       CDR
     REPEAT DROP 
     self IMAGE-BASE <
     self HERE > OR
     IF self FREE THROW THEN
;

: :super
     self class .parent @
;

: :name ( - addr u)
     self class .name @ COUNT
;

: :unknown
     ." Unknown message " ERR-M @ COUNT TYPE
     ."  for class " own :name TYPE
     ABORT
;

: :see ( c-addr u - addr true | false )
    self class .variables @
    SEARCH-WORDLIST
    IF >BODY @ self + TRUE
    ELSE FALSE
    THEN
;

: :methods
\ распечатать методы класса
   self class .methods @ NLIST
;
: :variables
\ распечатать переменные класса
  self class .variables @ NLIST
;  

;CLASS

.( Length of Just OOP is ) HERE SWAP - . .( bytes) CR
