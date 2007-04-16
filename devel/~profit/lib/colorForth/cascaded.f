\ Каскадные определения. Отделение словарных структур от кодофайла (хранилища).
\ Реализовано через виртуализацию словаря и представлением внутри его как хэша.
\ При создании словарных структур кодофайл (HERE) нисколько не задевается.

\ В результате мы получаем:
\ 1. Более быстрый поиск по словарю (например, в colorForth'е, где это было 
\ впервые применено, поиск по словарю делается одной (!) цепочечной 
\ машинной командой).
\ 2. Существенное упрощение словарных структур (например, ненужными становятся
\ поля связи, поля имени).
\ 3. Более лёгкая "расцепка" словарных структур от непосредственно работающего
\ кода.
\ 4. Собственно, каскадные определения как побочный эффект (пример см. внизу). 
\ На самом деле, это не так уж и полезно, но сам принцип возврата 
\ идентификаторам (словами) старого значения меток -- очень интересно.
\ 5. Возможность индивидуальной и полной зачистки словаря (см. слова 
\ FORGET-ALL и FORGET). При этом "забываются" только имена, HERE и вообще 
\ скомпилированное в кодофайле не трогается.

\ Проблемы (TODO):
\ Несовместимость с IMMEDIATE и VOC решена хаком, см. последнюю строчку 
\ SHEADER .
\ Может, надо совместить поля в хэше со словарной статьёй SPF чтобы снять все
\ вопросы несовместимости?

\ CREATE ... DOES> не работает.

\ Также не работает проход по словам (а нужно оно?), это:
\ prevWord lastWord ?VOC CAR CDR

\ REQUIRE SEE lib/ext/disasm.f
REQUIRE STR@ ~ac/lib/str4.f
REQUIRE HASH@ ~pinka/lib/hash-table.f
REQUIRE INVOKE ~ac/lib/ns/ns.f
REQUIRE __ ~profit/lib/cellfield.f
REQUIRE /TEST ~profit/lib/testing.f

MODULE: cascadedColons

0
__ lastWord \ Заготовка для прохода по словам
__ hash
CONSTANT vocSize

\ Словарная статья
0
__ prevWord ( word-id -- LFA )
__ flag     ( word-id -- FFA )
__ xt       ( word-id -- CFA )
CONSTANT wordSize

EXPORT

<<: FORTH cascaded

\ Создаём словарную статью
: SHEADER ( addr u -- )
\ CR ." SHEADER: " 2DUP TYPE
GET-CURRENT OBJ-DATA@
?DUP 0= IF big-hash DUP GET-CURRENT OBJ-DATA! THEN \ если пусто -- создаём
( addr u h ) ROT wordSize SWAP 2SWAP ( wordSize addr u h )
HASH!R
DUP prevWord 0!
DUP flag 0!
HERE OVER xt !
flag 0 NAME>F - LAST ! \ подстраиваемся под словарную структуру SPF
\ чтобы IMMEDIATE и VOC делали то что надо
\ при этом в переменной LAST оказывается что угодно только не NFA
;

: SEARCH-WORDLIST ( c-addr u oid -- 0 | xt 1 | xt -1 )
\ >R 2DUP CR TYPE R>
OBJ-DATA@ DUP IF HASH@R DUP IF DUP xt @ SWAP flag @ &IMMEDIATE AND IF 1 ELSE -1 THEN THEN ELSE NIP NIP THEN ;

>> CONSTANT cascaded-wl

: NO-WORDS ( wid -- f ) OBJ-DATA@ 0= ;

: FORGET-ALL ( wid -- )
\ "забыть" все слова в словаре wid
\ Проверки на то что словарь каскадный не делается
DUP NO-WORDS IF DROP EXIT THEN
  DUP  OBJ-DATA@ del-hash
0 SWAP OBJ-DATA! ;

: FORGET ( "word" -- ) NextWord
GET-CURRENT NO-WORDS IF 2DROP EXIT THEN
GET-CURRENT OBJ-DATA@ -HASH ;
\ взять из входного потока слово, "забыть" его (и только его)
\ в текущем каскадном словаре (опять же, без проверки)

;MODULE

MODULE: dontHide \ не прятать (HIDE SMUDGE) имя определяемого в данный момент слова

:NONAME HEADER ] ;

:NONAME ( -- )
  RET, [COMPILE] [
  ClearJpBuff
  0 TO LAST-NON
;

->VECT ; IMMEDIATE \ определить эти слова через векторы проще всего
->VECT : IMMEDIATE \ чтобы не прибегать к ним самим

;MODULE

/TEST

ALSO dontHide
ALSO cascaded NEW: casc DEFINITIONS

: 2*2. 2
: 2*. 2 *
: dot . ; IMMEDIATE

\ SEE 2*2.
$> 2*2.
$> 5 2*.
$> 12 dot
$> 12345 : r dot ;

$> 10 CONSTANT ten ten .

\ $> : var CREATE DOES> DROP ." bum" ; var b b

\ если FORGET работает правильно тут будет глюк
\                   v-------------|
$> FORGET dot  2*2. ' dot

\ убрать вообще все слова из словаря:
$> ' casc >BODY @ FORGET-ALL ' ten