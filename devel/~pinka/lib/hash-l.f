\ Расстановочные таблицы
\ Ю. Жиловец, 18.12.2002, с добавлениями А. Черезова

REQUIRE CZMOVE ~yz/lib/common.f \ 18.Sep.2003 Thu 17:03 ruv

REQUIRE GMEMINIT ~yz/lib/gmem.f

MODULE: HASH-TABLES

\ Формат таблицы:
\ +0    cell    Число списков
\ +4    n cells Начала списков записей

\ Формат записи
0 
CELL -- :link   \ Указатель на следующую запись / 0
CELL -- :key    \ указатель на строку - ключ
CELL -- :value  \ Указатель на значение
1    -- :free   \ 0 - число, <>0 строка
== #rec

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
    2DUP R@ :key @ COUNT COMPARE 0= IF ( нашли ключ) 2DROP 2R> ( ." found" s.) EXIT THEN
    R> RDROP  ( akey nkey rec)
    DUP :link @ ?DUP 0= IF ( не нашли ключ) PRESS PRESS 0 ( ." notfound" s.) EXIT THEN
  AGAIN ;

: del-value ( rec -- )
  DUP :free C@ IF DUP :value @ MFREEMEM THEN DROP ;

: del-rec ( rec -- link)
  DUP :key @ MFREEMEM DUP del-value DUP :link @ SWAP MFREEMEM ;

: (rec-in-hash) ( akey nkey hash -- rec)
  -ROT 2DUP 2>R ROT lookup ?DUP IF
    PRESS
    DUP del-value RDROP RDROP
  ELSE
     #rec MGETMEM ( last new)
     DUP ROT :link !
     2R> CMGETMEM OVER :key !
  THEN ;

VECT do-it

EXPORT

: HASH! ( akey nkey avalue nvalue hash -- )
  -ROT 2>R (rec-in-hash) TRUE OVER :free C! 2R> CMGETMEM SWAP :value ! ;

: HASH!Z ( akey nkey zvalue hash -- )
  SWAP >R (rec-in-hash) TRUE OVER :free C! R> ZMGETMEM SWAP :value ! ;

: HASH!N ( akey nkey value hash -- )
  SWAP >R (rec-in-hash) FALSE OVER :free C! R> SWAP :value ! ;

: HASH!R ( akey nkey size hash -- adr )
  SWAP >R (rec-in-hash) TRUE OVER :free C! R> MGETMEM DUP ROT :value ! ;

: -HASH ( akey nkey hash -- )
  lookup ?DUP IF del-rec SWAP :link ! ELSE DROP THEN ;

: HASH@ ( akey nkey hash -- avalue nvalue / 0 0) 
  lookup PRESS DUP IF :value @ COUNT ELSE 0 THEN ;

: HASH@Z ( akey nkey hash -- z/0) 
  lookup PRESS DUP IF :value @ THEN ;

: HASH@R ( akey nkey hash -- a/0) HASH@Z ;

: HASH@N ( akey nkey hash -- n TRUE / FALSE) 
  lookup PRESS DUP IF :value @ TRUE THEN ;

: small-hash ( -- hash ) 32 make-hash ;
: large-hash ( -- hash) 256 make-hash ;

: traverse-hash ( xt hash -- )
  DUP @ CELLS OVER + CELL+ SWAP CELL+ ?DO
    I @ IF 
      I @
        BEGIN ?DUP WHILE
          OVER EXECUTE 
        REPEAT
    THEN
  CELL +LOOP
  DROP ;

: del-hash ( hash -- )
  ['] del-rec OVER traverse-hash MFREEMEM ;

: (all-hash) ( rec -- nextrec )
  >R R@ :key @ COUNT R@ :value @ do-it R> :link @ ;

: all-hash ( xt hash -- )
  >R TO do-it ['] (all-hash) R> traverse-hash ;

;MODULE
