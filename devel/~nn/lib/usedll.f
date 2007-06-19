\ 
\ USEDLL.F
\ 
\ Written by Nicholas Nemtsev, 2000
\ 
\ Этот модуль упрощает работу с апишными функциями.
\ С его помощью можно избавиться от длинных списков импортируемых функций.
\ Чтобы стали видимы все функции из какой либо библиотеки, 
\ достаточно объявить ее при помощи  UseDLL <имя-библиотеки>
\ Для экономии памяти ее можно компилировать в верхнюю часть форт-пространства, 
\ например при помощи LH-INCLUDED из моей lh.f (http://www.forth.org.ru/~nemnick)
\ при сохранении (SAVE) ненужное просто отвалится.
\ 
\ Как это сделано.
\ Слово UseDLL добавляет библиотеку в список используемых библиотек.
\ При обнаружении слова, отсутствующего в словаре (NOTFOUND), 
\ производится поиск в известных библиотеках. Если функция найдена,
\ то в список неразрешенных ссылок добавляется соотв. элемент,
\ а в словаре резервируется 5 байт для ссылки вперед.
\ При выполнении слова ; ссылки разрешаются.
\ 

VOCABULARY USEDLL
GET-CURRENT
ALSO USEDLL DEFINITIONS

VARIABLE DLL-LIST
    \ List item: next dll-handle dll-name 0
0 
CELL -- DLL-NEXT
CELL -- DLL-HANDLE
0    -- DLL-NAME
CONSTANT /DLL-ITEM

VARIABLE NRES-API
    \ List item: next ref-list dll-item api-name 0
0 
CELL -- API-NEXT
CELL -- API-REFS
CELL -- API-DLL-ITEM
0    -- API-NAME
CONSTANT /API-ITEM

: IC-COMPARE ( addr1 u1 addr2 u2 -- flag )
  SWAP >R >R
  R@ <> IF DROP 2R> 2DROP TRUE EXIT THEN
  R> R> SWAP 0
  ?DO 2DUP I + C@ SWAP I + C@ - ABS DUP 0= SWAP 32 = OR
      0= IF 2DROP UNLOOP TRUE EXIT THEN
  LOOP 2DROP FALSE
;

: STR0+ ( a u -- ) + 0 SWAP C! ;
: place         ( addr len dest -- )
                SWAP 255 MIN SWAP
                2DUP 2>R
                CHAR+ SWAP MOVE
                2R> C! ;

: +place        ( addr len dest -- ) \ append string addr,len to counted
                                     \ string dest
                >R 255 MIN 255 R@ C@ - MIN R>
                                        \ clip total to MAXCOUNTED string
                2DUP 2>R
                COUNT CHARS + SWAP MOVE
                2R> DUP C@ ROT + SWAP C! ;

: DLL-EXIST ( a u -- dll-handle | 0)
    2>R
    DLL-LIST 
    BEGIN @ ?DUP WHILE
        DUP DLL-NAME ASCIIZ> 2R@ IC-COMPARE 0=
        IF  DLL-HANDLE @ 2R> 2DROP EXIT THEN
    REPEAT
    2R> 2DROP
    FALSE
;

: ADD-API-REF ( api-item --)
    2 CELLS ALLOCATE THROW >R
    API-REFS DUP @ R@ ! R@ SWAP !
    HERE R> CELL+ !
    5 ALLOT
;

: ADD-NRES-API ( a u -- ?)
    2DUP STR0+
    2>R
\    ." find existing apis" CR
    NRES-API
    BEGIN @ ?DUP WHILE
        DUP API-NAME ASCIIZ> 2R@ COMPARE 0=
        IF  \ Add to refs
            2R> 2DROP 
            ADD-API-REF TRUE EXIT
        THEN
    REPEAT
    \ yet not exist
\    ." finding at dlls..." CR
    DLL-LIST 
    BEGIN @ ?DUP WHILE
\      DUP DLL-NAME ASCIIZ> TYPE CR
      DUP DLL-HANDLE @ 2R@ DROP SWAP GetProcAddress
      IF
\        ." ok. found." CR
        2R> 1+ DUP /API-ITEM + ALLOCATE THROW >R
        R@ API-NAME SWAP CMOVE
        NRES-API @ R@ ! R@ NRES-API !
        R@ ADD-API-REF
        R> API-DLL-ITEM ! \ dll-item
        TRUE EXIT
      THEN
    REPEAT
    2R> 2DROP
    FALSE
;

: RESOLVE-API
    NRES-API
    BEGIN @ ?DUP WHILE
        S" WINAPI: " PAD place
        DUP API-NAME ASCIIZ> PAD +place S"  " PAD +place
        DUP API-DLL-ITEM @ DLL-NAME ASCIIZ> PAD +place
        PAD COUNT ( 2DUP TYPE CR) EVALUATE
        HERE >R
        DUP API-REFS
        BEGIN @ ?DUP WHILE
          DUP CELL+ @ HERE - ALLOT
          LATEST NAME> COMPILE, 
        REPEAT
        R> HERE - ALLOT
    REPEAT
    NRES-API 0!
;

DUP SET-CURRENT
: UseDLL 
    BL WORD   DUP COUNT STR0+
    DUP COUNT DLL-EXIST 0=
    IF
      DUP 1+ LoadLibraryA ?DUP
      IF
\          ." Ok. Library " OVER COUNT TYPE ." found." CR
          SWAP COUNT 1+ DUP /DLL-ITEM + ALLOCATE THROW >R
          R@ DLL-NAME SWAP CMOVE
          DLL-LIST @ R@ !
          R@ DLL-HANDLE !
          R> DLL-LIST !
      ELSE
        COUNT TYPE ."  - library not found." CR
      THEN
    ELSE
        DROP
    THEN
;
WARNING @ WARNING 0!

: NOTFOUND ( a u -- )
    STATE @ 
    IF 2>R
        2R@ ADD-NRES-API
        2R> ROT 0= 
        IF
            NOTFOUND 
        ELSE
            [ CONTEXT @ ] LITERAL CONTEXT @ -
            IF ALSO USEDLL THEN
            2DROP
        THEN
    ELSE NOTFOUND THEN
;

DEFINITIONS

: ; 
    PREVIOUS
    S" ;" EVALUATE
    RESOLVE-API 
; IMMEDIATE

WARNING !

PREVIOUS SET-CURRENT