\ Расстановочные таблицы
\ Ю. Жиловец, 18.12.2002, с добавлениями А. Черезова
\ Добавления Рувима Пинки и Игоря Панасенко

REQUIRE MGETMEM ~yz/lib/gmem.f

MODULE: HASH-TABLES

\ Формат таблицы:
\ +0	cell	Число списков
\ +4 	n cells	Начала списков записей

\ Формат записи

EXPORT

0 
CELL -- :hashlink   \ Указатель на следующую запись / 0
CELL -- :hashkey    \ указатель на строку - ключ
CELL -- :hashvalue  \ Указатель на значение
1    -- :hashfree   \ 0 - число, <>0 строка
== #rec

;MODULE

MODULE: HASH-TABLES

: make-hash ( n -- )
  \ очистит хэш-таблицу ALLOCATE
  DUP 1+ CELLS MGETMEM 2DUP ! PRESS ;

: (HASH) ( akey nkey n2 -- )
  OVER 0= IF DROP 2DROP 0 ELSE HASH THEN ;

: lookup ( akey nkey hash -- last 0 / prevrec rec) 
( ." look" s.)
  >R 2DUP R@ @ (HASH) 1+ CELLS R> +
  DUP @  0= IF PRESS PRESS 0 ( ." empty" s.) EXIT THEN
  DUP @
  BEGIN
    ( akey nkey prev rec)
    2>R ( akey nkey)
    2DUP R@ :hashkey @ COUNT COMPARE 0= IF ( нашли ключ) 2DROP 2R> ( ." found" s.) EXIT THEN
    R> RDROP  ( akey nkey rec)
    DUP :hashlink @ ?DUP 0= IF ( не нашли ключ) PRESS PRESS 0 ( ." notfound" s.) EXIT THEN
  AGAIN ;

: traverse-hash ( xt hash -- )
  DUP @ CELLS OVER + CELL+ SWAP CELL+ ?DO
    I @
    BEGIN ?DUP WHILE
      OVER EXECUTE 
    REPEAT
  CELL +LOOP
  DROP ;

: del-value ( rec -- )
  DUP :hashfree C@ IF DUP :hashvalue @ MFREEMEM THEN DROP ;

: del-rec ( rec -- link)
  DUP :hashkey @ MFREEMEM DUP del-value DUP :hashlink @ SWAP MFREEMEM ;

: del-all-recs ( hash -- )    \ освобождает все записи в таблице
  ['] del-rec SWAP traverse-hash ;

: (rec-in-hash) ( akey nkey hash -- rec)
  -ROT 2DUP 2>R ROT lookup ?DUP IF
    PRESS
    DUP del-value RDROP RDROP
  ELSE
     #rec MGETMEM ( last new)
     DUP ROT :hashlink !
     2R> CMGETMEM OVER :hashkey !
  THEN ;

USER-VALUE do-it

: (all-hash) ( rec -- nextrec )
  >R R@ :hashkey @ COUNT R@ :hashvalue @ R> :hashlink @ >R do-it EXECUTE R> ;

: (all-hash-records) ( rec -- nextrec )
  DUP :hashlink @ >R do-it EXECUTE R> ;

: (del-some-records) ( hash -- )
  DUP @ CELLS OVER + CELL+ SWAP CELL+ ?DO
    I
    BEGIN
      ( prevrec-a)
      DUP @ ?DUP 
    WHILE
      ( prevrec-a rec)
      >R
      R@ :hashkey @ COUNT  R@ :hashvalue @  do-it EXECUTE
      IF 
        R> del-rec ( prevrec link) OVER !
      ELSE
        DROP R> :hashlink
      THEN
    REPEAT DROP
  CELL +LOOP ;

EXPORT

: HASH! ( avalue nvalue akey nkey hash -- )
  (rec-in-hash) TRUE OVER :hashfree C! >R CMGETMEM R> :hashvalue ! ;

: HASH!Z ( zvalue akey nkey hash -- )
  (rec-in-hash) TRUE OVER :hashfree C! SWAP ZMGETMEM SWAP :hashvalue ! ;

: HASH!R ( size akey nkey hash -- adr )
  (rec-in-hash) TRUE OVER :hashfree C! >R MGETMEM DUP R> :hashvalue ! ;

: HASH!N ( akey nkey value hash -- )
  SWAP >R (rec-in-hash) FALSE OVER :hashfree C! R> SWAP :hashvalue ! ;

: -HASH ( akey nkey hash -- )
  lookup ?DUP IF del-rec SWAP :hashlink ! ELSE DROP THEN ;

: HASH@ ( akey nkey hash -- avalue nvalue / 0 0) 
  lookup PRESS DUP IF :hashvalue @ COUNT ELSE 0 THEN ;

: HASH@Z ( akey nkey hash -- z/0) 
  lookup PRESS DUP IF :hashvalue @ THEN ;

: HASH@R ( akey nkey hash -- a/0) HASH@Z ;

: HASH@N ( akey nkey hash -- n TRUE / FALSE) 
  lookup PRESS DUP IF :hashvalue @ TRUE THEN ;

: small-hash ( -- hash ) 32   make-hash ;
: big-hash   ( -- hash ) 256  make-hash ;
: large-hash ( -- hash ) 1024 make-hash ;

: clear-hash ( hash -- )    \ очищает хэш, не удаляя основную таблицу
  DUP del-all-recs DUP @ CELLS SWAP CELL+ SWAP ERASE ;

: del-hash ( hash -- )
  DUP del-all-recs MFREEMEM ;

: all-hash ( xt hash -- )
  \ xt ( akey ukey a|value   -- )
  >R TO do-it ['] (all-hash) R> traverse-hash ;

: all-hash-records ( xt hash -- )
  \ xt ( rec -- )
  >R TO do-it ['] (all-hash-records) R> traverse-hash ;

: del-some-records ( xt hash -- )
  \ xt ( akey nkey a|value -- ?)
  SWAP TO do-it (del-some-records)
;

: HASH? ( akey ukey h -- true|false )
  lookup NIP 0<>
;

;MODULE

