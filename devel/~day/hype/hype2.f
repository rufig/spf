( Отличия от оригинального Hype:
  http://home.munich.netsurf.de/Helge.Horch/hype.html

  - наследуются wordlists в SUBCLASS, это позволило
    a\ упростить слово MFIND 
    b\ ускорить компиляцию
    c\ при наследовании стали доступны методы класса "деда"
       и всех вышележащих
  - переменная LASTCLASS
  - изменен SUBCLASS
  - экземпляры инициализируются нулем
  - END -> ENDCLASS
  - IV  -> OBJ
  Dmitry Yakimov, 2001  ftech@tula.net

  Формат объекта:
  cell - указатель на класс
  n    - данные

  Формат класса:
  cell - размер объекта
  cell - wid лексикона
  cell - wid лексикона предка [super]

  Здесь есть:
  1. Инкапсуляция. Лексикон описывает структуру данных и функции.
     Ну, этим в форте никого не удивишь, взять хотя бы обычный словарь.
  2. Наследование.
     В ANS есть только наследование функций.
     Здесь же добавлено и наследование структур данных. Очень важное свойство
  3. Полиморфизм.
     Раз все методы компилируются статически, то можно подумать,
     что полиморфизма нет. 
     А вот и есть! Только достигается он не динамическим поиском
     по словарю или VMT, а просто использованием механизма векторных
     слов, только применительно к объектам.
     То есть:
     VAR vFunc

     : FUNC vFunc @ EXECUTE ;
     Чем не полиморфизм?

  Кроме того мною добавлена возможность работы с динамическими объектами, 
  то есть которые во время работы программы уничтожаются/создаются 
  неоднократно. Это слово -> для вызова методов и ALLOC для создания
  объекта.

  Hype использует пространство имен только при компиляции.
  Большая часть работы выполняется на этапе компиляции программы -
  показатель хорошего форт стиля.
)

HERE

USER-VALUE SELF

: SELF+ ( n - a) SELF + ;
: SEND ( a xt) SELF >R  SWAP TO SELF EXECUTE  R> TO SELF ;

VARIABLE CLS ( contains ta -> |size|wid|super|)

: SIZE^ ( - aa) CLS @ ?DUP 0= ABORT" scope?" ;

: MFIND ( ta ca u - xt n)  
   ROT CELL+ @ SEARCH-WORDLIST
   DUP 0= ABORT" no such method?"
;

: SEND' ( a ta "m ")  BL WORD COUNT MFIND 0 <> STATE @ AND
   IF SWAP LIT, LIT, POSTPONE SEND ELSE SEND THEN ;

: SUPER ( "m ") SIZE^ CELL+ CELL+ @ BL WORD COUNT MFIND 0<
   IF COMPILE, ELSE EXECUTE THEN ; IMMEDIATE

: DEFS ( n "f ") CREATE SIZE^ @ CELL+ , SIZE^ +! IMMEDIATE
   DOES> @ STATE @ IF LIT, POSTPONE SELF+ ELSE SELF+ THEN ;

: METHODS ( ta) DUP CLS ! CELL+ @ DUP SET-CURRENT
   ALSO CONTEXT ! ;

VARIABLE LASTCLASS

: CLASS ( "c ") CREATE HERE DUP LASTCLASS ! 0 , 0 , 0 ,
   WORDLIST OVER CELL+ ! METHODS ;

: SUBCLASS ( ta "c ") DUP CLASS SIZE^ OVER @ OVER ! CELL+ CELL+ ! 
      1 CELLS + @ @ ( last nfa in super wl)
      LASTCLASS @ CELL+ @ ( wl) !
;

: ENDCLASS ( ) SIZE^ DROP PREVIOUS DEFINITIONS 0 CLS ! ;

: INSTANCE ( ta) DUP , @ HERE OVER ALLOT SWAP ERASE
                 DOES> DUP SWAP @ SEND' ;

: NEW ( ta "name ") CREATE INSTANCE IMMEDIATE ;

\ Вызвать слово лексикона для
\ динамических объектов
: -> ( OBJ "WORD" )
    [CHAR] . PARSE SFIND 0= IF ABORT" ??" THEN
    EXECUTE
    NextWord MFIND DROP 
    STATE @
    IF LIT, POSTPONE SEND
    ELSE SEND THEN
; IMMEDIATE

: ALLOC ( ta -- obj )
\ создать неименованый динамический объект
    DUP @ CELL+ DUP ALLOCATE THROW
    TUCK SWAP ERASE
    TUCK !
;

: VAR 1 CELLS DEFS ;

: OBJ ( ta "name ") DUP @ DEFS ,
   DOES> 2@ SELF+ SWAP SEND' ;

: REF ( ta "name ") VAR ,
   DOES> 2@ SELF+ @ SWAP SEND' ;

.( Size of hype2.f is ) HERE SWAP - . CR

\ EOF
  
CLASS BUTTON
   VAR X
   VAR Y
 : DRAW ( )  ." X=" X @ . SPACE ." Y=" Y @ . CR ;
 : INIT ( x y )  Y ! X !  ;

ENDCLASS

BUTTON NEW abc

1 2 abc INIT

abc X @ .

: test abc X @ . ;

test


BUTTON ALLOC VALUE testObj


3 4 testObj -> BUTTON.INIT


: test
  testObj -> BUTTON.X @ .
;

test

testObj -> BUTTON.X @ .


\EOF

BUTTON NEW Obj
3 4 Obj INIT
Obj DRAW


BUTTON SUBCLASS BCHILD
: DRAW ." child: " SUPER DRAW ;
ENDCLASS

BCHILD SUBCLASS ASD
  BUTTON OBJ bobj
ENDCLASS

