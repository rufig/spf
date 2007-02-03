\ 20.Jan.2007 Sat 14:13

( Улучшенный дамп отчета аппаратных исключений:
  - сочетается с наличем множества хранилищ,
  - подправлена эвристика вычисления значения ESP на момент исключения,
  - позволяет выводить дополнительную информацию, привязываясь к AT-EXC-DUMP.

  Модуль определяет заново WordByAddr, 
  предоставляет ENUM-STORAGES, ставит <EXC-DUMP> на EXC-DUMP2

  Подключать после storage.f
)

REQUIRE NEW-STORAGE  ~pinka/spf/storage.f

REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] FOR-WORDLIST [IF]
: FOR-WORDLIST  ( wid xt -- ) \ xt ( nfa -- )
  SWAP @ BEGIN  DUP WHILE ( xt NFA ) 2DUP 2>R SWAP EXECUTE 2R> CDR REPEAT  2DROP
;
[THEN]

MODULE: exc-dump-support

REQUIRE BIND-NODE ~pinka/samples/2006/lib/plain-list.f

USER STORAGE-LIST \ список хранилищ, созданных потоком

: excide-this ( -- ) \ выкинуть
  STORAGE-ID STORAGE-LIST FIND-LIST IF UNBIND-NODE DROP THEN
;
: enroll-this ( -- ) \ вписать
  excide-this
  0 , HERE STORAGE-ID , STORAGE-LIST BIND-NODE
;

..: AT-FORMATING         enroll-this  ;..
..: AT-STORAGE-DELETING  excide-this  ;..

: (WITHIN-STORAGE) ( xt h -- xt )
  OVER DISMOUNT 2>R MOUNT EXECUTE 2R> MOUNT
;
EXPORT 

: ENUM-STORAGES ( xt -- ) \ xt ( h -- )
  >R FORTH-STORAGE R@ EXECUTE
  R> STORAGE-LIST ENUM-VALUES
;
: WITHIN-STORAGES ( xt -- ) \ xt ( -- )
  ['] (WITHIN-STORAGE) ENUM-STORAGES DROP
;

DEFINITIONS

: (NEAREST1) ( 0|nfa1 addr nfa2 -- 0|nfa1|nfa2 addr )
  DUP 0= IF DROP EXIT THEN
  \ сравниваем xt (адреса начала кода, cfa @)
  >R OVER DUP IF NAME> THEN 1- OVER
  R@ NAME> 1- WITHIN IF NIP R> SWAP EXIT THEN RDROP
  \ 1- т.к. WITHIN строгое здесь
;
: (NEAREST2) ( wid -- )
  ['] (NEAREST1) FOR-WORDLIST
;
: (NEAREST3) ( -- )
  ['] (NEAREST2) ENUM-FORTH-VOCS
;
: (NEAREST4) ( nfa1|0 addr -- nfa2|0 addr )
  ['] (NEAREST3) WITHIN-STORAGES
;

EXPORT

WARNING @  WARNING 0!

: NEAR_NFA ( addr -- nfa|0 addr )
  0 SWAP (NEAREST4)
;
: WordByAddr ( addr -- c-addr u )
  0 SWAP (NEAREST4) 
  OVER 0= IF 2DROP S" <not in the image>" EXIT THEN
  OVER - 4096 U< IF COUNT EXIT THEN
  DROP S" <not found>"
;

: STACK-ADDR. ( addr -- addr )
  DUP U. ." :  "
  DUP ['] @ CATCH IF DROP EXIT THEN
  DUP U. WordByAddr TYPE CR
;

WARNING !

: AT-EXC-DUMP ( -- ) ... ;

: EXC-DUMP2 ( exc-info -- ) 
  \ см. первоначальную реализацию в сырцах SPF3 и SPF4.
  IN-EXCEPTION @ IF DROP EXIT THEN   TRUE IN-EXCEPTION !  BASE @ >R HEX

  ." EXCEPTION! "
  DUP @ ."  CODE:" U.
  DUP 3 CELLS + @ ."  ADDRESS:" DUP U.  ."  WORD:" WordByAddr TYPE SPACE

  ."  REGISTERS:"
  DUP 4 CELLS + @ CELLS + \ может быть указано смещение структуры (обычно, на две ячейки вперед)
  176 + DUP 12 CELLS DUMP CR
  ." USER DATA: " TlsIndex@ U. ." THREAD ID: " 36 FS@ U.
  ." HANDLER: " HANDLER @ U.
  ." RETURN STACK:" CR

  HANDLER @ DUP 0= IF DROP R0 @ THEN ( up-border ) >R
  6 CELLS + DUP @  SWAP  4 CELLS + @ ( a1 a2 )
  \ берем ближайший снизу к up-border:
  2DUP U> IF SWAP THEN ( min max ) DUP R@ U< IF NIP ELSE DROP THEN ( low-border ) R>
  ( low-border up-border )
  2DUP U< IF OVER 25 CELLS + UMIN SWAP ELSE 2DROP R0 @ DUP 50 CELLS - THEN
  ( up low )
  BEGIN 2DUP U< 0= WHILE STACK-ADDR. CELL+ REPEAT 2DROP

  AT-EXC-DUMP
  ." END OF EXCEPTION REPORT" CR
  R> BASE !  FALSE IN-EXCEPTION !
;

' EXC-DUMP2 TO <EXC-DUMP>

;MODULE