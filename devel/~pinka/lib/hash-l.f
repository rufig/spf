\ Расстановочные таблицы
\ Ю. Жиловец, 18.12.2002, с добавлениями А. Черезова
\ 18.Sep.2003 ruvim@forth.org.ru  версия оригинального ~yz\lib\hash.f 
\     распределяющая память стандартным образом ALLOCATE/FREE
\     (по умолчанию, локальную память потока)

REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] SALLOC [IF]
: SALLOC ( a u -- a1 )
  DUP ALLOCATE THROW DUP >R SWAP CMOVE R>
;                  
: CALLOC ( a u -- a1 )
  TUCK DUP 2+ ALLOCATE THROW DUP >R 1+ SWAP CMOVE R@ C! R> 
;
: ZALLOC ( az -- a1 )
  ASCIIZ> 1+ SALLOC
;                  [THEN]

MODULE: HASH-TABLES-SUPPORT

\ Формат таблицы:
\ +0    cell    Число списков
\ +4    n cells Начала списков записей

\ Формат записи
0 
CELL -- :link   \ Указатель на следующую запись / 0
CELL -- :key    \ указатель на строку - ключ
CELL -- :value  \ Указатель на значение
1    -- :free   \ 0 - число, <>0 строка
CONSTANT #rec

: make-hash ( n -- h )
  DUP 1+ CELLS ALLOCATE THROW 2DUP ! NIP
  \ очистит хэш-таблицу ALLOCATE
;
: (HASH) ( akey nkey n2 -- hash )
  OVER 0= IF DROP 2DROP 0 ELSE HASH THEN ;

: lookup ( akey nkey h -- last 0 / prevrec rec) 
( ." look" s.)
  >R 2DUP R@ @ (HASH) 1+ CELLS R> +
  DUP @  0= IF NIP NIP 0 ( ." empty" s.) EXIT THEN
  DUP @
  BEGIN
    ( akey nkey prev rec)
    2>R ( akey nkey)
    2DUP R@ :key @ COUNT COMPARE 0= IF ( нашли ключ) 2DROP 2R> ( ." found" s.) EXIT THEN
    R> RDROP  ( akey nkey rec)
    DUP :link @ ?DUP 0= IF ( не нашли ключ) NIP NIP 0 ( ." notfound" s.) EXIT THEN
  AGAIN ;

: del-value ( rec -- )
  DUP :free C@ IF DUP :value @ FREE THROW THEN DROP ;

: del-rec ( rec -- link)
  DUP :key @ FREE THROW DUP del-value DUP :link @ SWAP FREE THROW ;

: (rec-in-hash) ( akey nkey h -- rec)
  -ROT 2DUP 2>R ROT lookup ?DUP IF
    NIP
    DUP del-value RDROP RDROP
  ELSE
     #rec ALLOCATE THROW ( last new)
     DUP ROT :link !
     2R> CALLOC OVER :key !
  THEN ;

USER-VALUE do-it

EXPORT

: HASH! ( akey nkey avalue nvalue h -- )
  -ROT 2>R (rec-in-hash) TRUE OVER :free C! 2R> CALLOC SWAP :value ! ;

: HASH!Z ( akey nkey zvalue h -- )
  SWAP >R (rec-in-hash) TRUE OVER :free C! R> ZALLOC SWAP :value ! ;

: HASH!N ( akey nkey value h -- )
  SWAP >R (rec-in-hash) FALSE OVER :free C! R> SWAP :value ! ;

: HASH!R ( akey nkey size h -- adr )
  SWAP >R (rec-in-hash) TRUE OVER :free C! R> ALLOCATE THROW DUP ROT :value ! ;

: -HASH ( akey nkey h -- )
  lookup ?DUP IF del-rec SWAP :link ! ELSE DROP THEN ;

: HASH@ ( akey nkey h -- avalue nvalue / 0 0) 
  lookup NIP DUP IF :value @ COUNT ELSE 0 THEN ;

: HASH@Z ( akey nkey h -- z/0) 
  lookup NIP DUP IF :value @ THEN ;

: HASH@R ( akey nkey h -- a/0) HASH@Z ;

: HASH@N ( akey nkey h -- n TRUE / FALSE) 
  lookup NIP DUP IF :value @ TRUE THEN ;

: small-hash ( -- h ) 32 make-hash ;
: large-hash ( -- h) 256 make-hash ;

: traverse-hash ( xt h -- )
  DUP @ CELLS OVER + CELL+ SWAP CELL+ ?DO
    I @ IF
      I @
        BEGIN ?DUP WHILE
          OVER EXECUTE
        REPEAT
    THEN
  CELL +LOOP
  DROP ;

: del-hash ( h -- )
  ['] del-rec OVER traverse-hash FREE THROW ;

: (all-hash) ( rec -- nextrec )
  >R R@ :key @ COUNT R@ :value @ R> :link @ >R do-it EXECUTE R>
;

: all-hash ( xt h -- )
  >R TO do-it ['] (all-hash) R> traverse-hash ;

;MODULE
