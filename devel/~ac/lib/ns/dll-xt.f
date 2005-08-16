( ~ac 16.08.2005
  $Id$

  Развитие идеи ns.f в части исключения необходимости использования 'WINAPI:'
  теперь имена функций DLL можно использовать и внутри компилируемых
  определений. При этом в код скомпилируется отложенный импорт и вызов 
  функции из DLL, а SFIND вернет адрес NOOP.

  Ни одно из определенных здесь слов не рекомендуется к использованию -
  они все работают за кадром [DL NEW:] как системное расширение транслятора.
  См. примеры в конце файла.

  Структура, компилируемая в словарную статью для отложенного
  выполнения функции DLL [своего рода inline WINAPI]

  CALL DLL-CALL
  1. размер_структуры_включая_asciiz_имя_функции
                                             \ аналог из __WIN:
  2. кэш_адрес_функции_в_dll                 \ = address of winproc
  3. dll_wid                                 \ вместо address of library name
  4. ссылка_на_asciiz_имя_функции            \ = address of function name
  5. число_параметров_если_известно_иначе_-1 \ # of parameters
  6. ссылка_на_предыдущую_подобную_структуру_импорта \ WINAPLINK
  asciiz_имя_функции

  Пояснения:

  размер_структуры_включая_asciiz_имя_функции:
  - сколько байт добавить к RP для перехода к следующей инструкции,
  т.е. 6 CELLS плюс длина имени функции плюс 1 [нулевой терминатор asciiz]

  кэш_адрес_функции_в_dll:
  - адрес функции для передачи в API-CALL; должен быть обнулен при
  сохранении EXE или при старте EXE и при любых выгрузках-загрузках DLL

  dll_wid:
  - ссылка на словарь, являющийся объявлением-привязкой данной DLL

  ссылка_на_asciiz_имя_функции:
  - в данном случая ссылка лишняя, но используется для совместимости с __WIN:

  число_параметров_если_известно_иначе_-1:
  - в зависимости от предварительных условий может быть известно число параметров...

  !!! в текущей версии "число параметров" не используется, работает API-CALL

  ссылка_на_предыдущую_подобную_структуру_импорта:
  - winaplink, необходимо для поиска структур для обнуления
  кэшированных адресов кэш_адрес_функции_в_dll

  asciiz_имя_функции:
  - имя функции с нулем на конце для передачи в DLSYM
)

REQUIRE NEW: ~ac/lib/ns/ns.f

: DLL-INIT ( addr -- )
  DUP >R 6 CELLS + ASCIIZ> R@ CELL+ CELL+ @
  [ ALSO DL ] SEARCH-WORDLIST [ PREVIOUS ]
\  S" SEARCH-WORDLIST-I" INVOKE ( то же самое, но медленнее :)
  0= IF ABORT THEN R> CELL+ !
;
: DLL-CALL ( на стеке возвратов адрес структуры импорта вызываемой функции )
  R@ CELL+ @
  DUP 0= IF DROP R@ DLL-INIT R@ CELL+ @ THEN
  R@ @ R> + >R API-CALL
;
: DLL-CALL, ( funa funu n dll-wid xt -- addr )
  ['] DLL-CALL _COMPILE,

  HERE >R
  0 , \ size
    , \ address of winproc
    , \ address of library name
  HERE CELL+ CELL+ CELL+ , \ address of function name
    , \ # of parameters
  IS-TEMP-WL 0=
  IF
    HERE WINAPLINK @ , WINAPLINK ! ( связь )
  ELSE 0 , THEN
  HERE SWAP DUP ALLOT MOVE 0 C, \ имя функции
  HERE R@ - R@ !
  R>
;

\ S" function" 5 0xDDD 0xCCC DLL-CALL, 80 DUMP

GET-CURRENT ALSO DL DEFINITIONS

\ : SEARCH-WORDLIST-I SEARCH-WORDLIST ; \ версия только для интерпретации

: SEARCH-WORDLIST ( c-addr u oid -- 0 | xt 1 | xt -1 )
  >R 2DUP ( c-addr u c-addr u )
  0 ROT ROT R@ ROT ROT R> ( c-addr u 0 oid  c-addr u oid )
  SEARCH-WORDLIST
  ?DUP
  IF ( c-addr u 0 oid xt [-]1 )
     >R HERE >R DLL-CALL, DROP 
     STATE @ 0= IF RET, THEN
     R> STATE @ IF DROP ['] NOOP THEN
     R>
  ELSE 2DROP 2DROP 0 THEN
;

SET-CURRENT PREVIOUS

: ERASE-DLL-HANDLES
  VOC-LIST @
  BEGIN
    DUP
  WHILE
    DUP CELL+ DUP CLASS@ [ ALSO DL CONTEXT @ PREVIOUS ] LITERAL =
              IF 0 OVER OBJ-DATA! THEN DROP
    @
  REPEAT DROP
;
: SAVE
  ERASE-DLL-HANDLES SAVE
;

( пример.
DL NEW: libxml2.dll

S" text.xml" DROP xmlRecoverFile

: TEST
  S" text.xml" DROP xmlRecoverFile
;
)