( Реализация классов. Ver 3.04  24.11.2000
 Свойства:
 1. Полное отсутствие портабельности.
 2. Инкапсуляция.
 3. Наследование по одной линии.
 4. Полностью статическое связывание
 5. Виртуальные методы
 6. Поддержка полей-объектов

        Применение
        ~~~~~~~~~~
Определение класса:
    CLASS: class-name     \ начало определения класса
      <size-of-field> FIELD field-name  \ определение полей
      ...
      RECORD: struct-name   \ определение структур
        <size-of-field> FIELD str-fld-name
        <another-class-name> OBJ obj-fld-name
        <another-class-name> PTR ptr-fld-name
        ...
      ;RECORD /struct-name  \ это имя можно использовать как размер класса

      CONSTR: constructor-name ... ;    \ конструктор
      DESTR: destructor-name ... ;      \ деструктор
      M: method-name ... ;              \ метод
    ;CLASS                  \ завершение определения класса
    ...
    class-name REOPEN     \ доопределение класса
    ...
    ;CLASS                  \ завершение доопределения
    ...

Определение подкласса:
    CLASS: subclass-name <SUPER class-name
    \ или
    class-name SUBCLASS: subclass-name
        <size-of-field> FIELD subclass-field-name
        CONSTR: constructor-name ...
            constructor-name    \ вызов конструктора надкласса
            ... ;               \ имена совпадают не случайно.
        ...
        M: subclass-method-name ... ;
        M: method-name ... method-name ... ;
    ;CLASS

Создание объектов и манипуляции с ними:
    class-name OBJECT: object-name  \ создание статического объекта
    \ или
    0 VALUE p-obj
    class-name NEW TO p-obj         \ создание динамического объекта
    ...
    object-name field-name @ ...    \ обращение к полю
    object-name method-name ...     \ обращение к методу
    p-obj ->CLASS class-name field-name @ ...
    p-obj ->CLASS class-name method-name ...
    p-obj DELETE    \ удаление динамического объекта
    ...
    WITH class-name     \ установка контекста класса и всех его родителей
        p-obj => field-name @ ...
        p-obj => method-name ...
    ENDWITH

    subclass-name OBJECT: object1
    object1 subclass-field-name ...
    object1 field-name ...
    object1 subclass-method-name ...
    object1 method-name ...

Предопределенные поля:
    PARENT       - ссылка на класс объекта
    SELF         - адрес самого объекта
                   внутри определений также можно использовать this
)

\ HERE


ONLY FORTH DEFINITIONS


: +ORDER ( wid -- ) >R GET-ORDER 1+ R> SWAP SET-ORDER ;
\ : CELL- 1 CELLS - ;
: ?EXECUTE ?DUP IF EXECUTE THEN ;

VOCABULARY OOP
ALSO OOP DEFINITIONS

0
CELL -- .WID       \ wid класса
CELL -- .SUPER     \ родительский класс
CELL -- .SIZE      \ размер экземпляра
CELL -- .CONSTR    \ конструктор
CELL -- .DESTR     \ деструктор
CELL -- .VMT       \ таблица вирт. методов
CELL -- .#VM       \ размер таблицы
CELL -- .OBJS      \ список полей-объектов класса (для инициализации)
VALUE /CLASS

CONTEXT @
FORTH DEFINITIONS

CREATE SUPERCLASS
    ,               \ wid класса
    0 ,             \ parent class
    0 ,             \ размер экземпляра
    0 ,             \ конструктор
    0 ,             \ деструктор
    0 ,             \ vmt
    0 ,             \ #vm
    0 ,             \ objs
OOP DEFINITIONS

123 CONSTANT CL-TAG
124 CONSTANT WI-TAG
125 CONSTANT VM-TAG
126 CONSTANT M-TAG
127 CONSTANT REC-TAG

\ Адрес структуры создаваемого класса
SUPERCLASS VALUE CURR

USER-VALUE this             \ Адрес текущего экземпляра


: >EXT-ENTRY >BODY ;
: ext-field-entry R> 1+ @ + ;  \ обращение к переменной класса снаружи

: FIELD
    CREATE
    POSTPONE ext-field-entry
    M-TAG C,
    CURR .SIZE @ DUP , + CURR .SIZE !
    DOES>  >BODY 1+ @ this + ;

: var CELL FIELD ;
: dvar 2 CELLS FIELD ;
: char 1 FIELD ;
: chars FIELD ;

: CFIELD ( class -- )  \ поле-объект
    .SIZE @ FIELD ;

CELL NEGATE FIELD SELF
CELL        FIELD PARENT

: RECORD: 0 FIELD HERE 0 , REC-TAG ;
: ;RECORD \ size-rec-name ( addr-rec rec-tag -- )
    REC-TAG - -22 ?ERROR
    CURR .SIZE @ OVER CELL- @ - DUP CONSTANT
    SWAP !
;

: >CURR CURR SWAP TO CURR ;
: CURR> TO CURR ;

: GENEALOGY ( class -- )
    0 SWAP
    BEGIN ?DUP WHILE
      DUP @ >R
      .SUPER @
      SWAP 1+ SWAP
    REPEAT
    >R GET-ORDER R>
    BEGIN ?DUP WHILE
      1- SWAP 1+ SWAP
      R> ROT ROT
    REPEAT
    SET-ORDER ;

: ?CLASS CL-TAG - -22 ?ERROR ;


FORTH DEFINITIONS
ALSO OOP
: REOPEN ( class -- ...)    \ возобновить определение класса
    >CURR
    WARNING @ WARNING 0!
    GET-ORDER GET-CURRENT 0 ( #vm) CL-TAG ( this is a tag)
    CURR GENEALOGY DEFINITIONS ;
PREVIOUS
OOP DEFINITIONS

: VMT! ( xt index -- )  CELLS CURR .VMT @ +   ! ;

: VMT ( ... #vm -- )
    ?DUP
    IF
        HERE >R
        CURR .#VM @   +  DUP CELLS ALLOT  ( ... new-#vm)
        CURR .VMT @  R@  CURR .#VM @ CELLS  CMOVE
        CURR .#VM @  ( ... new-#vm old-#vm) OVER CURR .#VM !
        R> CURR .VMT !
        1+ SWAP
        DO I 1- VMT!  -1 +LOOP

    THEN
;
: ;CLASS ?CLASS VMT SET-CURRENT SET-ORDER WARNING ! CURR> ;

: SUPER ( class -- )        \ наследование
    CURR >R >R ;CLASS
    R> DUP R@ .SUPER !
    .SIZE R@ .SIZE 5 CELLS CMOVE
    R@ .#VM @
    IF
        R@ .VMT @ ( from)
        HERE ( from to)
        R@ .#VM @ CELLS ALLOT
        DUP R@ .VMT !
        R@ .#VM @ CELLS CMOVE
    THEN
    R> REOPEN
;

: <SUPER ' EXECUTE SUPER ;

0 VALUE LAST-M

    : ?METHOD ( xt ) >BODY >BODY C@
        DUP M-TAG = SWAP VM-TAG = OR
        0= ABORT" is not a class member." ;

    FORTH DEFINITIONS
    ALSO OOP

    : =>
        ' DUP ?METHOD
        >EXT-ENTRY
        STATE @ IF  COMPILE,  ELSE  >R  THEN ;  IMMEDIATE

    DEFINITIONS

: ext-exec ( ... object xt -- )
    this >R  SWAP TO this
    CATCH R> TO this THROW ;
: ext-entry R> 1+  ext-exec ;
: int-entry R> >BODY 1+ >R ;

: M:
    : HERE TO LAST-M
    POSTPONE int-entry
    POSTPONE ext-entry
    M-TAG C,
;

: VM-xt ( addr object -- xt )
    CELL- @ .VMT @  SWAP @ + @ ;

: vm-ext-entry ( object -- )
    R> ( 'vm-tag)   1+ ( 'offset)
    OVER VM-xt ext-exec ;
: vm-int-entry  R> >BODY 1+ this VM-xt >R ;

: VM ( -- offs t= | -- f=)
    >IN @  BL WORD FIND
    IF >BODY >BODY DUP C@ VM-TAG =
       IF  1+ @ NIP TRUE EXIT THEN
    THEN
    DROP >IN ! FALSE
;

: VM:
    VM IF :NONAME SWAP CURR .VMT @ + !
    ELSE : HERE TO LAST-M
        POSTPONE vm-int-entry
        POSTPONE vm-ext-entry  VM-TAG C,
        ?CLASS
        DUP CURR .#VM @ + CELLS ,
        1+  HERE SWAP
        CL-TAG
    THEN
;

0
CELL -- obj.link
CELL -- obj.class
CELL -- obj.offset
CELL -- obj.init
CONSTANT /OBJ

USER-VALUE jthis            \ Адрес экземпляра, который объемлет текущий

: OBJ@  R> obj.offset @ this + ;

: OBJ
    CREATE IMMEDIATE
    POSTPONE OBJ@
    HERE 0 , \ link
    CURR .OBJS BEGIN DUP @ ?DUP WHILE NIP REPEAT  !
    DUP , \ class
    CURR .SIZE @ CELL+ ,
    ( class ) .SIZE @ CELL+ CURR .SIZE +!
    0 , ( init code)
    DOES>
         CONTEXT >R
         DUP COMPILE,
         >BODY obj.class @ GENEALOGY
         POSTPONE =>
         R> TO CONTEXT
;

M: CONSTR PARENT @ .CONSTR @ ?EXECUTE ;
M: DESTR  PARENT @ .DESTR @ ?EXECUTE ;
: CONSTR: M: LAST-M CURR .CONSTR ! ; IMMEDIATE
: DESTR:  M: LAST-M CURR .DESTR ! ; IMMEDIATE
M: >PARENT PARENT @ @ +ORDER ;    \ установить контекст класса
M: SIZE PARENT @ .SIZE @ ;    \ размер экземпляра (без parent)



: ENUM-OBJS ( instance xt -- )
    >R >R R@ CELL- @ .OBJS
    BEGIN @ ?DUP WHILE
      DUP obj.offset @ R@ +  ( obj instance+offset)
      OVER obj.class @ OVER CELL- !
      OVER >R
      RP@ 2 CELLS + @ EXECUTE
      R>
    REPEAT
    RDROP RDROP
;
: (WITH) ( class-name -- ...)  >R GET-ORDER WI-TAG R> GENEALOGY ;
PREVIOUS DEFINITIONS
ALSO OOP

: WITH \ class-name ( -- )
    ' EXECUTE (WITH) ; IMMEDIATE
: ENDWITH WI-TAG -  -22 ?ERROR
    SET-ORDER ; IMMEDIATE

ONLY FORTH ALSO OOP DEFINITIONS

VOCABULARY ;OBJ
ALSO ;OBJ DEFINITIONS
WARNING @ WARNING 0!
: ; POSTPONE ENDWITH
    POSTPONE ;
    ; IMMEDIATE
WARNING !
PREVIOUS DEFINITIONS

: :init HERE DUP CELL- :NONAME SWAP !
        /OBJ - obj.class @ (WITH)
        ALSO ;OBJ ;

: obj-constr ( obj instance -- ) DUP => CONSTR
    SWAP obj.init @ ?DUP
        IF this >R SWAP TO this EXECUTE
           R> TO this
        ELSE DROP THEN
    ;
: obj-destr ( obj instance -- ) => DESTR DROP ;

: INIT-OBJS ( instance -- )
    jthis >R DUP TO jthis
    ['] obj-constr ENUM-OBJS
    R> TO jthis
;
: DEL-OBJS  ( instance -- )  ['] obj-destr  ENUM-OBJS ;


PREVIOUS DEFINITIONS

ALSO OOP
: CLASS:
    WORDLIST CREATE HERE >R
    , ( wid) SUPERCLASS ,
    SUPERCLASS 2 CELLS +
    HERE /CLASS 2 CELLS - DUP ALLOT CMOVE
    R> REOPEN
;
PREVIOUS

    : ->CLASS
        STATE @
        IF
            POSTPONE WITH     POSTPONE =>   POSTPONE ENDWITH
        ELSE  >R
            POSTPONE WITH  R> POSTPONE =>   POSTPONE ENDWITH
        THEN
        ; IMMEDIATE

    : OBJECT@ R> CELL+ ;

    : NEWHERE ( class -- object)
        WITH SUPERCLASS
            DUP ,
            HERE DUP ROT .SIZE @ DUP ALLOT ERASE
            >R R@ INIT-OBJS
            R@ => CONSTR
            R>
        ENDWITH
    ;
    : OBJECT: ( class -- )
        WITH SUPERCLASS
            >R
            CREATE
            IMMEDIATE ['] OBJECT@ COMPILE,
\              R@ ,
\              HERE DUP R> .SIZE @ DUP ALLOT ERASE
\              >R R@ INIT-OBJS
\              R> => CONSTR
               R> NEWHERE DROP
            DOES>
                CONTEXT >R  \ Запоминаем текущее положение. Только SPF
                DUP >BODY @ GENEALOGY
                STATE @ IF COMPILE, ELSE EXECUTE THEN
                POSTPONE =>
                R> TO CONTEXT \ Востанавливаем
        ENDWITH
    ;


: SUBCLASS: ( class -- ...)
    >R CLASS: R>
    WITH SUPERCLASS
        SUPER
    ENDWITH
;

: NEW ( class -- object )
    WITH SUPERCLASS
        DUP .SIZE @ CELL+ DUP ALLOCATE THROW >R
        R@ SWAP ERASE R@ !
        R> CELL+ >R
        R@ INIT-OBJS
        R@ => CONSTR R>
    ENDWITH
;

: DELETE ( address-of-instance -- )
    WITH SUPERCLASS
        >R
        R@ DEL-OBJS
        R@ => DESTR
\        R@ IMAGE-BASE <
 \       R@ IMAGE-BASE IMAGE-SIZE + > OR
\        IF
            R@ => PARENT FREE THROW

\        THEN
        R> DROP
    ENDWITH
;

SUPERCLASS REOPEN
M: Delete this DELETE ;
;CLASS

: SIZEOF ( class -- size-of-instance )
    WITH SUPERCLASS
        .SIZE @
    ENDWITH
;

\ : CLASS-FIND ( addr class -- xt ?)
\   WITH SUPERCLASS
\       CONTEXT >R
\       GENEALOGY FIND
\       R> TO CONTEXT
\   ENDWITH
\ ;
\ REQUIRE >NAME lib\EXT\to-name.f
\ : .class ( pfa -- )  5 - >NAME COUNT TYPE CR ;
\ CREATE x-buf 32 ALLOT
\ : .x HLD @ x-buf 32 CMOVE HLD @ >R
\     . x-buf R> DUP HLD ! 32 CMOVE ;
: CLASS-FIND ( addr class -- xt ?)
\     DUP .x
     WITH SUPERCLASS
        BEGIN ?DUP WHILE
\          DUP .class
          OVER OVER @
          SWAP COUNT ROT SEARCH-WORDLIST ?DUP
          IF 2SWAP 2DROP EXIT THEN
          CELL+ @
        REPEAT
        0
    ENDWITH
;

S" ~nn/class/pointer.f" INCLUDED

\ HERE SWAP - .( Size of class implementation is ) . CR
