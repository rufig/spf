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

REQUIRE {  ~af/lib/locals.f

VOCABULARY MicroClass
GET-CURRENT ALSO MicroClass DEFINITIONS
( wid.prev-compilation )
\ MicroClass private words

USER uObj
USER uObjMethodShadowed  \ ( xt.shadowed-method | 0 )

\ Определяем поля структур объектов
: FIELD
  \ ( u.offset1 u.size "name" -- u.offset2 )
  \ name Interpretation: ( -- never )
  \ name Compilation: ( -- ; Germ: xt.method -- xt.method )
  \ name Run-time: ( -- addr.field )
  CREATE IMMEDIATE OVER , +
  DOES> ?COMP  @ LIT, S" _mc +" EVALUATE
;

\ Так определяется метод
: M:
  \ ( "name" -- ; C: -- colon-sys.method ; Compilation: false -- true ; Germ: -- xt.method )
  \ name Initiation: ( addr.obj -- )
  WARNING @ >R WARNING 0!
  >IN @ >R  PARSE-NAME  R> >IN !
  uObj @ SEARCH-WORDLIST 0= IF 0 THEN uObjMethodShadowed !
  :
  R> WARNING !
  S" { _mc } " EVALUATE
;

: ;CLASS ( wid -- )  PREVIOUS PREVIOUS SET-CURRENT ;

: LOOK-INIT (  -- 0 | xt 1 | xt -1   ;  Order: wid.class -- wid.class )
  S" INIT" CONTEXT @ SEARCH-WORDLIST
;

: LOOK-DESTROY ( -- 0 | xt 1 | xt -1 ; Order: wid.class -- wid.class )
  S" DESTROY" CONTEXT @ SEARCH-WORDLIST
;

: (NEW) ( u.obj-size -- addr.obj )
  DUP ALLOCATE THROW
  DUP ROT ERASE
;

\ Наследование форт слов
: INHERIT ( -- )
  \ Interpretation: ( -- never )
  \ Compilation: ( -- ; Germ: xt.method -- xt.method )
  \ Run-time: ( any1 -- any2 ) \ the parent's method semantics ( any1 addr.obj -- any2 )
  ?COMP
  uObjMethodShadowed @ ?DUP
  IF
    S" _mc" EVALUATE
    COMPILE,
  THEN
; IMMEDIATE

: DO-IT-DEF ( -- wid.prev-compilation ; Order: -- wid.microclass wid.class ; Current: wid.prev-compilation -- wid.class )
  ALSO MicroClass
  ALSO LATEST-NAME ( nt.vocabulary ) NAME> EXECUTE \ занесли новый словарь в CONTEXT
  GET-CURRENT DEFINITIONS  \ сделали его текущим
  GET-CURRENT uObj !
;

( wid.prev-compilation )
SET-CURRENT
\ MicroClass public words

: CLASS: ( "name" -- wid.prev-compilation ; Order: -- wid.microclass wid.class ; Current: wid.prev-compilation -- wid.class )
  VOCABULARY DO-IT-DEF
;

: CHILD: ( "name.parent" "name.new" -- wid.prev-compilation ; Order: -- wid.microclass wid.class ; Current: wid.prev-compilation -- wid.class )
  '  XTVOC>WID  CLASS:  SWAP ( wid.prev-compilation wid.parent-class )
  GET-CURRENT CHAIN-WORDLIST \ новый словарь начинается с головы родительского
;

\ Создание объекта в словарном пространстве
: OBJECT  ( any1 u.obj-size -- addr.obj ; Order: wid.class -- wid.class )
  \ MethodOfInit: ( any1 addr.obj -- )
  HERE OVER ALLOT
  DUP ROT ERASE
  LOOK-INIT IF OVER >R EXECUTE R> THEN
;

\ Создание объекта в куче
: NEWOBJ
  \ Interpretation: ( any1 u.obj-size -- addr.obj ; Order: wid.class -- wid.class )
  \ Compilation: ( -- ; Order: wid.class -- wid.class )
  \ Run-time: ( any1 u.obj-size -- addr.obj )
  \ MethodOfInit: ( any1 addr.obj -- )
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
: DELETEOBJ
  \ Interpretation: ( addr.obj --  ; Order: wid.class -- wid.class )
  \ Compilation: ( -- ; Order: wid.class -- wid.class )
  \ Run-time: ( addr.obj -- )
  STATE @
  IF
    LOOK-DESTROY IF POSTPONE DUP COMPILE, THEN POSTPONE FREE POSTPONE THROW
  ELSE
    LOOK-DESTROY IF OVER >R EXECUTE R> THEN FREE THROW
  THEN
; IMMEDIATE

PREVIOUS  \ End of the MicroClass private scope
