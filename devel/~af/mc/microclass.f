\ $Id$
\ Andrey Filatkin, af@forth.org.ru
\ Переделка ~day\mc\microclass.f
( 13.05.2000 Dmitry Yakimov
  ver. 1.5.
  Эта библиотека была частично взята у ~1001bytes, доработана и исправлена [!].
)
( Либа организует статический ООП поверх словарей. Дает возможность
  наследования, динамического создания\уничтожения объектов.
  Эта либа тесно связана с локалсами. В начале каждого метода создается
  один локалс _mc, в котором хранится self. Так намного быстрее работает,
  чем при хранении self в USER-переменной.

  Создание классов:
     CLASS: Test
        0
          CELL FIELD x
          CELL FIELD y
        CONSTANT /Test

        M: INIT   x ! y ! ;
     ;CLASS

     CHILD: Test Test1
        /Test
          CELL FIELD z
        CONSTANT /Test1
        M: INIT   INHERIT z ! ;
     ;CLASS
      
  Создание статического объекта:
     ALSO Test 1 2 /Test OBJECT 
       ...
     PREVIOUS

  Создание динамического объекта:
     : foo
       [ ALSO Test ] 1 2 /Test NEWOBJ
         ...
       DELETEOBJ [ PREVIOUS ]
     ;
)

REQUIRE {  devel\~af\lib\locals.f

VOCABULARY MicroClass
GET-CURRENT ALSO MicroClass DEFINITIONS

USER uObj

\ Определяем поля структур объектов
: FIELD
  CREATE IMMEDIATE OVER , +
  DOES> @ LIT, S" _mc +" EVALUATE
;

\ Так определяется метод
: M:
  WARNING @ >R WARNING 0!
  :
  R> WARNING !
  S" { _mc } " EVALUATE
;

: ;CLASS ( wid -- )  PREVIOUS PREVIOUS SET-CURRENT ;

: LOOK-INIT (  -- 0 | xt 1 | xt -1 )
  S" INIT" CONTEXT @ SEARCH-WORDLIST
;

: LOOK-DESTROY ( wid -- 0 | xt 1 | xt -1 )
  S" DESTROY" CONTEXT @ SEARCH-WORDLIST
;

: (NEW) ( length  -- addr )
  DUP ALLOCATE THROW
  DUP ROT ERASE
;

\ Наследование форт слов
: INHERIT ( -- )
  SMUDGE
  LATEST COUNT DUP >R
  PAD SWAP CMOVE
  HIDE PAD R>
  uObj @ SEARCH-WORDLIST
  IF
    S" _mc" EVALUATE
    COMPILE,
  THEN
; IMMEDIATE

: DO-IT-DEF ( -- wid )
  ALSO MicroClass
  ALSO LATEST COUNT EVALUATE \ занесли новый словарь в CONTEXT
  GET-CURRENT DEFINITIONS  \ сделали его текущим
  GET-CURRENT uObj !
;

SET-CURRENT

: CLASS: ( "name" -- 0 )
  VOCABULARY DO-IT-DEF
;

: CHILD: ( -- u )
  ALSO ' EXECUTE \ родитель
  CONTEXT @ @ PREVIOUS
  CLASS:
  SWAP GET-CURRENT ! \ новый словарь начинается с хвоста родительского
;

\ Создание объекта в словарном пространстве
: OBJECT  ( length  -- addr )
  HERE OVER ALLOT
  DUP ROT ERASE
  LOOK-INIT IF OVER >R EXECUTE R> THEN
;

\ Создание объекта в куче
: NEWOBJ ( -- addr )
  STATE @
  IF
    POSTPONE (NEW)
    LOOK-INIT IF POSTPONE DUP POSTPONE >R COMPILE, POSTPONE R> THEN
  ELSE
    (NEW)
    LOOK-INIT IF OVER >R EXECUTE R> THEN
  THEN
; IMMEDIATE

\ Удаление объекта
: DELETEOBJ ( addr -- )
  STATE @
  IF
    LOOK-DESTROY IF POSTPONE DUP COMPILE, THEN POSTPONE FREE POSTPONE THROW
  ELSE
    LOOK-DESTROY IF OVER >R EXECUTE R> THEN FREE THROW
  THEN
; IMMEDIATE

PREVIOUS PREVIOUS
