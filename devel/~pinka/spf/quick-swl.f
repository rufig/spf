\ 07.Jan.2004 ruv
\ $Id$

( Расширение SPF [зависит от реализации!]
   воплощает быстрый поиск по словарю за счет использования хэш-таблиц.

  Хэш-таблицы создаются динамически, по SAVE не сохраняются.

  Ограничения:
   в каждый словарь должен компилировать только один поток 
   /для временных - создатель-владелец словаря/

   Если будут несколько - то возможно неверное распределение 
    памяти -  хэш-таблица в хипе одного потока будет иметь
    элементы, располагающиеся в хипе другого потока. 
)

( Переопределяет FREE-WORDLIST  и MARKER /если он есть/
  Поэтому, следует подгружать quick-swl.f до того, 
   как эти слова могут быть использованы в определениях.
  [ в том числе, до locals.f ]

  Заменяет вектор SEARCH-WORDLIST - метод поиска в стандартных словарях SPF
  Использует ячейку "класс словаря" в заголовке словаря
  для хранения ссылки на экстра-заголовок.
)

REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE HASH!       ~pinka/lib/hash-table.f 

MODULE: QuickSWL-Support

EXPORT

 1024 VALUE #WL-HASH
 \ размер хэш-таблицы 

DEFINITIONS

0 \ ext header  for wordlist
 1 CELLS -- .hash
 1 CELLS -- .last
 1 CELLS -- .wid
CONSTANT /exth

: wid-exth ( wid -- exth )
  3 CELLS +  \ использовал ячейку "класс словаря"
  DUP @   DUP IF  NIP EXIT THEN  DROP
  ( ~wid )

  /exth ALLOCATE THROW
  SWAP 2DUP !    ( exth ~wid )
  3 CELLS - OVER .wid ! ( exth )
  #WL-HASH  new-hash  OVER !
;
: WL-HASH ( wid -- hash-table )
  wid-exth .hash @
;
( внутри, т.к. способ использования хэш-таблица - детали реализации )

USER-VALUE hash

: update-hash ( exth -- )
  >R
  R@ .last  @
  R@ .wid @ @  ( l2 l )
  2DUP = IF 2DROP RDROP EXIT THEN
  \ если словарь пуст - 0 0 - тоже выход

  DUP CHAR+ C@ 12 = IF CDR THEN
  \ не добавляем последнее слово, если скрыто ( by HIDE )
  DUP R@ .last !
  R> .hash @ TO hash

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
;

: reduce-hash ( last  wid  -- )
\ Исключить из хэш-таблицы слова от wid @ до last
\ last должно иметь место в цепочке словаря wid
\ ( для MARKER )

  DUP wid-exth ?DUP 0= IF 2DROP EXIT THEN >R
  @ ( l2  l )
  OVER R@ .last  !
  R> .hash @ TO hash

  ( l2 l )          BEGIN
  2DUP <>           WHILE
  DUP COUNT hash -HASH
  CDR DUP 0=        UNTIL THEN 2DROP
;

EXPORT

\ SEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ 94 SEARCH

: QuickSWL ( c-addr u wid -- 0 | xt 1 | xt -1 ) \ SWL
  DUP GET-CURRENT <>                IF
  GET-CURRENT  wid-exth update-hash THEN

  wid-exth DUP update-hash
  @  ( c-addr u  h )
  HASH@N            IF
  \ last OVER U<  IF DROP RDROP 0 EXIT THEN
  \  такая проверка криво работает 
  \       при сцеплении списков в порядке, отличном от следования в ОП

  DUP  NAME> 
  SWAP NAME>F C@
  &IMMEDIATE AND
  IF 1 ELSE -1 THEN ELSE
  0                 THEN
;

: CLEAR-WLHASH ( wid -- )
\ очистить хэш-таблицу словаря. На случай, если она стала не адекватной..
  wid-exth DUP
  .last 0!
  .hash @ clear-hash
;

: FREE-WORDLIST ( wid -- )
  DUP wid-exth DUP 
    .hash @ del-hash 
    FREE THROW
  FREE-WORDLIST
;

[DEFINED] MARKER [IF]

: MARKER
  WARNING @ >R WARNING 0!
  LATEST
  >IN @ >R  MARKER LATEST NAME>  R> >IN ! 
  ( last marker-xt  )
  CREATE
   , , GET-CURRENT ,
  R> WARNING !
  DOES> DUP CELL+ DUP @ SWAP CELL+ @ ( a last wid )
            reduce-hash
        @ EXECUTE
;

[THEN]

DEFINITIONS

: erase-refer ( -- )
\ ( аналогично ERASE-IMPORTS )
\ хэш-таблицы динамические, живут только в ОП,
\ поэтому после запуска процесса ссылки на exth в заголовках словарей
\ будут не действительны. Их надо обнулить. 
  VOC-LIST @ BEGIN
  DUP        WHILE
  DUP CELL+ ( a wid )
  3 CELLS + 0!  \ ячейка "класс словаря"
  @          REPEAT  DROP
;

: update-hashes ( -- )
( если к стационарному словарю первым обращается коротко живущий поток,
  то хэш инициируется из хипа этого потока... а поток потом завершается
  и наступает облом.
  Это слово принудительно инициирует все словари/хэш-таблицы/ при запуске.
    Правда, словари могут и после запуска расширится/добавится
     - поэтому добавил в SWL проверку CURRENT
)
  VOC-LIST @ BEGIN
  DUP        WHILE
  DUP CELL+ ( a wid )
  wid-exth update-hash
  @          REPEAT  DROP
;

..: AT-PROCESS-STARTING erase-refer update-hashes ;..


EXPORT

    [DEFINED] SEARCH-WORDLIST1                  [IF]
    ' QuickSWL TO SEARCH-WORDLIST               [ELSE]

    REQUIRE REPLACE-WORD lib/ext/patch.f
    ' QuickSWL ' SEARCH-WORDLIST REPLACE-WORD   [THEN]

;MODULE
