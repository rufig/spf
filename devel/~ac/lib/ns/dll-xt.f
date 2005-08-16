( Структура, компилируемая в словарную статью для отложенного
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

  ссылка_на_предыдущую_подобную_структуру_импорта:
  - winaplink, необходимо для поиска структур для обнуления
  кэшированных адресов кэш_адрес_функции_в_dll

  asciiz_имя_функции:
  - имя функции с нулем на конце для передачи в DLSYM
)

: DLL-CALL ( на стеке возвратов адрес структуры импорта вызываемой функции )
  R@ CELL+ @
  ?DUP IF R@ @ R> + >R API-CALL
       ELSE ." need initialize" ABORT THEN
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

ns.f


GET-CURRENT ALSO DL DEFINITIONS

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

DL NEW: libxml2.dll

S" text.xml" DROP xmlRecoverFile

: TEST
S" text.xml" DROP xmlRecoverFile
;
