\ Каскадные определения. Отделение словарных структур от кодофайла (хранилища).
\ Реализовано через виртуализацию словаря и представлением внутри его как хэша.
\ При создании словарных структур кодофайл (HERE) нисколько не задевается.

\ В результате мы получаем:
\ 1. Более быстрый поиск по словарю (например, в colorForth'е, где это было впервые
\ применено, поиск по словарю делается одной (!) цепочечной машинной командой).
\ 2. Существенное упрощение словарных структур (например, ненужными становятся поля 
\ связи, поля имени).
\ 3. Более лёгкая "расцепка" словарных структур от непосредственно работающего кода.
\ 4. Собственно, каскадные определения как побочный эффект (пример см. внизу). На самом
\ деле, это не так уж и полезно, но сам принцип возврата идентификаторам (словами)
\ старого значения меток -- очень интересно.

\ Проблемы:
\ Поля словарности (voc) и немедленности (imm) нарисованы пока что только для красоты.
\ Так как IMMEDIATE и VOCABULARY живут, не зная об существовании ~ac\lib\ns\ns.f
\ По той же самое причине DOES> даёт глюки.

\ Также не работает проход по словам (а нужно оно?), это prevWord lastWord ?VOC CAR CDR

\ REQUIRE SEE lib/ext/disasm.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE HASH@ ~pinka/lib/hash-table.f
REQUIRE INVOKE ~ac/lib/ns/ns.f
REQUIRE __ ~profit/lib/cellfield.f

\ Заготовка для прохода по словам
0
__ lastWord
__ hash
CONSTANT vocSize

\ Словарная статья
0
__ prevWord
__ imm
__ voc
__ xt
CONSTANT wordSize

<<: FORTH cascaded

\ Создаём словарную статью
: SHEADER ( addr u -- )
\ CR ." SHEADER: " 2DUP TYPE
GET-CURRENT OBJ-DATA@
?DUP 0= IF big-hash DUP GET-CURRENT OBJ-DATA! THEN \ если пусто -- создаём
( addr u h ) ROT wordSize SWAP 2SWAP ( wordSize addr u h )
HASH!R
0 OVER prevWord !
0 OVER imm !
0 OVER voc !
HERE OVER xt !
DROP ;

: SEARCH-WORDLIST ( c-addr u oid -- 0 | xt 1 | xt -1 )
\ >R 2DUP CR TYPE R>
OBJ-DATA@ DUP IF HASH@R DUP IF DUP imm @ IF 1 ELSE -1 THEN SWAP xt @ SWAP THEN ELSE NIP NIP THEN ;

>> CONSTANT cascaded-wl

MODULE: dontHide \ определяем словарь в котором изменены действия : и ;

:NONAME HEADER ] ;

:NONAME ( -- )
  RET, [COMPILE] [
  ClearJpBuff
  0 TO LAST-NON
;

->VECT ; IMMEDIATE \ определить эти слова через векторы проще всего
->VECT : IMMEDIATE \ чтобы не прибегать к ним самим

;MODULE

ALSO dontHide
ALSO cascaded NEW: casc DEFINITIONS

: 2*2. 2
: 2*. 2 *
: dot . ;

\ lib/ext/disasm.f SEE 2*2.
2*2.
12 dot

10 CONSTANT ten
ten .