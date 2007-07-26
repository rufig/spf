\ 07.Jan.2004 ruv
\ 12.Oct.2005 branch from quick-swl2.f,v 1.3
\ $Id$

( Расширение SPF [зависит от реализации!]
   воплощает быстрый поиск по словарю за счет использования хэш-таблиц.

  Дает 30-35% выигрыша на трансляции кэшированных системой файлов,
  до 43% вкупе с fix-refill.f.

  Хэш-таблицы создаются динамически, по SAVE не сохраняются.

  Особенности:
    Хэш-таблицы располагаются в общем хипе процесса
    [через механизм HEAP-ID  ~pinka/spf/mem.f]
    Возможна утечка хипа процесса, если не делать FREE-WORDLIST 
    на каждый TEMP-WORDLIST
)
( Модуль переопределяет FREE-WORDLIST [если нету AT-STORAGE-DELETING ],
  вектор SHEADER и слова ":" ";" [ловит события].
  Поэтому, его следует подгружать до того, 
  как эти слова могут быть использованы в определениях
  [ в том числе, до locals.f ], но после storage.f [!!!]

  Dec.2006: поддржека MARKER убрана, т.к. он все-равно не отслеживает списки слов.

  Заменяет вектор SEARCH-WORDLIST -- метод поиска в стандартных словарях SPF.
)

REQUIRE HEAP-ID     ~pinka\spf\mem.f
REQUIRE [UNDEFINED] lib\include\tools.f
REQUIRE HASH!       ~pinka\lib\hash-table.f 

REQUIRE WidExtraSupport ~pinka\spf\wid-extra.f

FORTH-WORDLIST VALUE w

[UNDEFINED] WL-#WORDS [IF]
: WL-#WORDS ( wid -- n )
  0 SWAP
  @     BEGIN
  DUP   WHILE
  SWAP 1+ SWAP
  CDR   REPEAT  DROP
;
[THEN]


MODULE: QuickSWL-Support

ALSO WidExtraSupport

: WID-CACHEA WID-CACHEA ;

PREVIOUS

EXPORT

 256 VALUE #WL-HASH
 \ размер хэш-таблиц для вновь создаваемых словарей.
 \ При инициализации на этапе AT-PROCESS-STARTING 
 \   размер таблиц берется как 3*n, где n -число слов в словаре.

DEFINITIONS

0 \ ext header  for wordlist \ allocating dinamically
 1 CELLS -- .hash
 1 CELLS -- .last
 1 CELLS -- .wid
CONSTANT /exth
( exth знает свой wid через атрибут .wid
  и из wid можно получить exth
)


: wid-exth? ( wid -- exth true | false )
  WID-CACHEA @ DUP IF TRUE EXIT THEN DROP FALSE
;

: wid-exth ( wid -- exth )
  DUP WID-CACHEA @ DUP IF NIP EXIT THEN  DROP
  ( wid )
  HEAP-ID >R  HEAP-GLOBAL

  DUP WL-#WORDS 3 * #WL-HASH UMAX new-hash
  /exth ALLOCATE THROW ( wid htbl exth )
  TUCK .hash !
  2DUP SWAP WID-CACHEA !
  TUCK .wid !  ( exth )

  R> HEAP-ID!
;
: WL-HASH ( wid -- hash-table )
  wid-exth .hash @
;
( внутри, т.к. способ использования хэш-таблицы - детали реализации )

USER-VALUE hash

: update-hash ( exth -- )
  >R
  R@ .last  @
  R@ .wid @ @  ( l2 l )
  2DUP = IF 2DROP RDROP EXIT THEN
  \ если словарь пуст - 0 0 - тоже выход

  DUP CHAR+ C@ 12 = IF CDR THEN
  2DUP = IF 2DROP RDROP EXIT THEN
  \ не добавляем последнее слово, если скрыто ( by HIDE )

  DUP R@ .last !
  R> .hash @ TO hash

  HEAP-ID >R  HEAP-GLOBAL

  0 >R
  ( l2 l )          BEGIN
  2DUP <>           WHILE
  DUP >R
  CDR DUP 0=        UNTIL THEN 2DROP
  ( )               BEGIN
  R> DUP            WHILE
  DUP COUNT 
  hash HASH!N       REPEAT DROP
  \ добавлять в хэш-таблицу надо в том же порядке, 
  \ в котором слова добавлялись в словарь

  R> HEAP-ID!
;

: update-wlhash ( wid -- )
  wid-exth update-hash
;

: update1-wlhash ( nfa wid -- )
  wid-exth DUP .last @     IF
  HEAP-ID >R  HEAP-GLOBAL
    .hash @    >R
    DUP COUNT  R> HASH!N
  R> HEAP-ID!              ELSE
  \ чтобы при сцеплении списков все слова добавлялись
  NIP update-hash          THEN
;

EXPORT

\ SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH

: QuickSWL ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ SWL
  WL-HASH ( c-addr u  h )
  HASH@N            IF
  DUP  NAME> 
  SWAP NAME>F C@
  &IMMEDIATE AND
  IF 1 ELSE -1 THEN 
  EXIT              ELSE 0 THEN
;

: REFRESH-WLHASH ( wid -- )
\ Обновить хэш-таблицу словаря (на случай, если она стала неадекватной..)
\ Неопределенная ситуация, если во время выполнения REFRESH-WLHASH 
\  происходит поиск по словарю wid.
  DUP
  HEAP-ID >R  HEAP-GLOBAL

  wid-exth DUP
  .last 0!
  .hash @ clear-hash

  R> HEAP-ID!
  update-wlhash
;
: REFRESH-WLCACHE REFRESH-WLHASH ;

: DEL-WLHASH ( wid -- )
  wid-exth? 0= IF EXIT THEN
  HEAP-ID >R  HEAP-GLOBAL
     ( exth ) >R
     R@ .hash @ del-hash
     R@ .wid  @ WID-CACHEA 0!
     R> FREE THROW
  R> HEAP-ID!
;


[DEFINED] AT-STORAGE-DELETING [IF]

..: AT-STORAGE-DELETING ['] DEL-WLHASH ENUM-VOCS-FORTH ;..

[ELSE]

WARNING @ WARNING 0!

: FREE-WORDLIST ( wid -- )
  DUP DEL-WLHASH  FREE-WORDLIST
;

WARNING !

[THEN]


DEFINITIONS

: WID-CACHEA0! ( wid -- )
  WID-CACHEA 0!
;
: erase-refer ( -- )
\ ( аналогично ERASE-IMPORTS )
\ хэш-таблицы динамические, живут только в ОП,
\ поэтому после запуска процесса ссылки на exth в заголовках словарей
\ будут не действительны. Их надо обнулить. 
  ['] WID-CACHEA0! ENUM-VOCS-FORTH
;

: update-hashes ( -- )
\ инициирует хэш-таблицы для всех словарей (по списку VOC-LIST)
  ['] update-wlhash ENUM-VOCS-FORTH
;
( заполнение хэш-таблицы по первому поиску в словаре
  требует синхронизации для реентерабельности к многопоточности,
  не используется.

  Использование локального хипа потока наложило бы ограничения
  на режимы разнопоточной компиляции.

  Как вариант, можно использовать хип, в котором создано хранилище,
  в котором словарь.
)

VECT 0SWL  \ иниц.-ия модуля QuickSWL  при запуске системы..

: 0SWL1 ( -- )
  erase-refer
  update-hashes
; ' 0SWL1 TO 0SWL

..: AT-PROCESS-STARTING 0SWL ;..

\ -------------------------------

USER LAST-WID

: LastWord2Hash ( -- )
  LAST @ LAST-WID @ update1-wlhash
;
: LatestWord2Hash ( -- )
  LATEST ?DUP IF GET-CURRENT update1-wlhash THEN
;

USER-VALUE NOW-COLON?

: SHEADER(SWL) ( addr u -- )
  GET-CURRENT LAST-WID !

  [ ' SHEADER BEHAVIOR COMPILE, ]
  NOW-COLON?
  IF FALSE TO NOW-COLON?  ELSE  LastWord2Hash THEN
;

EXPORT

WARNING @ WARNING 0!

: ;
    POSTPONE ;
    LatestWord2Hash
    ( если было NONAME, то передобавит слово, которое уже есть
      - ситуация штатная. )
    FALSE TO NOW-COLON?
; IMMEDIATE

: : ( C: "<spaces>name" -- colon-sys ) \ 94
  TRUE TO NOW-COLON?
  :
; \ ';' вызовет уже LatestWord2Hash (!!!)


\ Создание кэш-заголовка (exth) для вновь-создаваемых словарей:

..: AT-WORDLIST-CREATING DUP update-wlhash ;..

WARNING !

    [DEFINED] SHEADER1                          [IF]
    ' SHEADER(SWL) TO SHEADER                   [ELSE]
    .( need a later version of SPF4 ) CR ABORT  [THEN]

 0SWL  \ иниц.ия

    [DEFINED] SEARCH-WORDLIST1                  [IF]
    ' QuickSWL TO SEARCH-WORDLIST               [ELSE]
    .( need a later version of SPF4 ) CR ABORT  [THEN]

;MODULE