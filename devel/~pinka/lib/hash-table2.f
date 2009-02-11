\ Расстановочные таблицы ($Id$)
\ 11.Feb.2009 ruv, -- ветка от hash-table.f v1.4
\     * снято ограничение в 255 байт на ключи и значения
\     * итераторы прозрачны по стеку
\     * местами рефакторинг
\     + hcount, for-hash-txt

REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE EQUAL  ~pinka/lib/ext/basics.f
REQUIRE HASH   ~pinka/lib/hash.f
REQUIRE SALLOC ~pinka/lib/ext/alloc.f
REQUIRE XALLOC ~pinka/lib/xalloc.f

MODULE: HASH-TABLES-SUPPORT

\ Формат таблицы:
\ +0    cell    Число списков
\ +4    n cells Начала списков записей

\ Формат записи
0
/CELL -- :link   \ Указатель на следующую запись / 0
/CELL -- :key    \ указатель на строку - ключ
/CELL -- :value  \ Указатель на значение
1    -- :free   \ 0 - число, <>0 строка
CONSTANT /rec

EXPORT
: new-hash ( n -- h )
  DUP 1+ CELLS ALLOCATE THROW 2DUP ! NIP
  \ очистит хэш-таблицу ALLOCATE
;
DEFINITIONS

: lookup- ( h akey ukey -- last 0 | prevrec rec ) 
  2>R XCOUNT 2R@ ROT HASH CELLS + ( addr )
  BEGIN DUP @ DUP WHILE ( prevrec rec ) \ hack of ':link'
    DUP :key @ XCOUNT 2R@ EQUAL 0= WHILE NIP
  REPEAT THEN  RDROP RDROP
;
: lookup ( akey ukey h -- last 0 | prevrec rec ) -ROT lookup- ;

: del-value ( rec -- )
  DUP :free C@ IF DUP :value @ FREE THROW THEN DROP
;
: del-rec ( rec -- )
  DUP :key @ FREE THROW DUP del-value  FREE THROW 
;
: (rec-in-hash) ( akey ukey h -- rec )
  -ROT 2DUP 2>R lookup- DUP IF NIP DUP del-value RDROP RDROP EXIT THEN DROP
  /rec ALLOCATE THROW ( last new )
  2R> XALLOC OVER :key !
  DUP ROT ! \ hack of ':link'
;

EXPORT

: HASH! ( avalue uvalue akey ukey h -- )
  (rec-in-hash) TRUE OVER :free C! >R XALLOC R> :value !
;
: HASH!Z ( zvalue akey ukey h -- )
  (rec-in-hash) TRUE OVER :free C! SWAP ZALLOC SWAP :value !
;
: HASH!N ( value akey ukey h -- )
  (rec-in-hash) FALSE OVER :free C! :value !
;
: HASH!R ( size akey ukey h -- adr )
  (rec-in-hash) TRUE OVER :free C! >R ALLOCATE THROW DUP R> :value !
;
: -HASH ( akey ukey h -- )
  lookup DUP IF DUP :link @ SWAP del-rec SWAP :link ! EXIT THEN 2DROP
;
: HASH? ( akey ukey h -- true|false )
  lookup NIP 0<>
;
: HASH@ ( akey ukey h -- avalue uvalue | 0 0 ) 
  lookup NIP DUP IF :value @ XCOUNT ELSE 0 THEN
;
: HASH@R ( akey ukey h -- a|0 ) 
  lookup NIP DUP IF :value @ THEN
;
: HASH@Z ( akey ukey h -- a|0 ) HASH@R ;

: HASH@N ( akey ukey h -- n TRUE | FALSE ) 
  lookup NIP DUP IF :value @ TRUE THEN
;
: small-hash  ( -- h ) 32   new-hash ;
: large-hash  ( -- h) 256   new-hash ;
: big-hash    ( -- h) 1024  new-hash ;

: for-hash-rec ( h xt -- ) \ xt ( rec -- )
  SWAP XCOUNT CELLS OVER + SWAP ?DO ( xt )
    I @ SWAP >R BEGIN DUP WHILE ( rec )
    R@ OVER :link @ >R EXECUTE R>  REPEAT DROP R>
  /CELL +LOOP
  DROP
;
: clear-hash ( h -- )    \ очищает хэш, не удаляя основную таблицу
  DUP ['] del-rec for-hash-rec
  XCOUNT CELLS ERASE
;
: del-hash ( h -- )
  DUP ['] del-rec for-hash-rec
  FREE THROW 
;

DEFINITIONS

USER-VALUE do-it

: (all-hash) ( rec -- )
  >R R@ :key @ XCOUNT R> :value @  do-it EXECUTE
;
: (for-hash) ( rec -- nextrec )
  >R R@ :value @  R> :key @ XCOUNT do-it EXECUTE
;
: (for-hash-txt) ( rec -- nextrec )
  >R R@ :value @ XCOUNT R> :key @ XCOUNT do-it EXECUTE
;
: (hash-count) ( i rec -- i+1 )  DROP 1+ ;

EXPORT

: hcount ( addr -- a u ) XCOUNT ;

: all-hash ( xt h -- )
\ xt ( akey ukey a|value   -- )
  do-it >R  SWAP TO do-it  ['] (all-hash) for-hash-rec  R> TO do-it
;
: for-hash ( h xt -- )
\ xt ( a|value  akey ukey -- )
  do-it >R  TO do-it  ['] (for-hash) for-hash-rec   R> TO do-it
;
: for-hash-txt ( h xt -- )  \ xt ( a-txt u-txt a-key u-key -- )
  do-it >R  TO do-it  ['] (for-hash) for-hash-rec  R> TO do-it
;
: hash-count ( h -- n )    \ подсчитывает число элементов в хэше
  0 SWAP ['] (hash-count) for-hash-rec
;
: hash-empty? ( h -- flag ) \ проверяет, пуст хэш или нет
  hash-count 0=
;

;MODULE
