\ $Id$
\
\ јвтодополнение в консоли SPF
\ ¬ременно перебор истории - Ctrl-B Ctrl-N

REQUIRE /STRING lib/include/string.f
REQUIRE AT-XY ~day/common/console.f
REQUIRE InsertNodeEnd ~day/lib/staticlist.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE ATTACH-LINE-CATCH ~pinka/samples/2005/lib/append-file.f

WINAPI: GetConsoleScreenBufferInfo KERNEL32.DLL


MODULE: ACCEPT-Autocompletion

0 VALUE _addr \ адрес буфера дл€ ACCEPT
0 VALUE _n1 \ длина буфера дл€ ACCEPT
0 VALUE _in \ длина текста
0 VALUE _last \ позици€ последнего символа введЄнного руками (не автодополнением)
0 VALUE _y \ номер строки на консоли
0 VALUE in-history \ состо€ние перебора истории
0 VALUE history \ список строк истории

: history-file S" history" +ModuleDirName ;

/node 
CELL -- .val
CONSTANT /history

CREATE CONSOLE_SCREEN_BUFFER_INFO 22 ALLOT

: AT-XY? ( -- x y )
\ определение координат курсора
  CONSOLE_SCREEN_BUFFER_INFO H-STDOUT GetConsoleScreenBufferInfo DROP
  CONSOLE_SCREEN_BUFFER_INFO 4 + DUP W@ SWAP 2+ W@ ;

: CLEAR-LINE ( y -- )
\ очистить строку
   0 SWAP 16 LSHIFT OR 0 >R RP@ SWAP MAX-XY NIP BL H-STDOUT FillConsoleOutputCharacterA R> 2DROP ;

: scanback ( addr u -- a' u' )
\ найти начало слова (сканирование назад по строке)
  2DUP
  BEGIN
    1-
    2DUP + C@ IsDelimiter IF NIP 1+ /STRING EXIT THEN
    DUP 0=
  UNTIL
  2DROP
;

: SUBSTART ( a u a1 u1 -- 0 | -1 )
\ подстрока с начала строки
   2>R OVER 2R> ROT >R  
   ( a u a1 u1 ) ( R: a ) \ %)
   SEARCH NIP IF R> <> ELSE DROP RDROP -1 THEN ;

: CDR-BY-NAME-START ( a u nfa1|0 -- a u nfa2|0 )
\ найти следующее слово в списке начинающеес€ на a u
 BEGIN  ( a u NFA | a u 0 )
   DUP
 WHILE  ( a u NFA )
   >R 2DUP R@ COUNT 2SWAP SUBSTART R> SWAP
 WHILE
   CDR  ( a u NFA2 )
 REPEAT THEN 
;

: expand ( a a1 u1 -- a a1+u1-a )
   + OVER - ;

: put ( a u -- in )
\ поместить строку начина€ от _last
   _last OVER + _n1 > IF 2DROP _in EXIT THEN
   >R _addr _last scanback DROP R> 2DUP + >R CMOVE 
   R> _addr -
;

: accept-one ( c -- )
\ обработка одного символа
   DUP 9 = \ tab
   IF 
     DROP
     0 TO in-history
     _addr _in scanback \ last full word
     CONTEXT @ SEARCH-WORDLIST-NFA 0= IF CONTEXT @ @ THEN 
     _addr _last scanback \ last realpart word
     ROT
     CDR
     CDR-BY-NAME-START
     NIP NIP ?DUP IF COUNT put TO _in ELSE _last TO _in THEN
     EXIT 
   THEN
   DUP 8 = \ bksp
   IF
     0 TO in-history
     DROP
     _in 1 MAX 1- TO _in 
     _in TO _last
     EXIT
   THEN
   DUP 14 = IF \ C-N
     in-history DUP 0= IF DROP history firstNode THEN
     0 TO _last
     DUP .val @ STR@ put DUP TO _in TO _last
         NextCircleNode TO in-history
   THEN
   DUP 2 = IF \ C-B
     in-history DUP 0= IF DROP history firstNode THEN
     0 TO _last
     DUP .val @ STR@ put DUP TO _in TO _last
         PrevCircleNode TO in-history
   THEN
   DUP 32 < IF DROP EXIT THEN
   0 TO in-history
   \ put one char
   _addr _in + C!
   _in 1 + TO _in
   _in TO _last
;

: \STRING ( a u n -- a+u-n n ) OVER MIN >R + R@ - R> ;

: MAX-X MAX-XY DROP 1- ;

: display
\ показать буфер
\   LT LTL @ TO-LOG _y .TO-LOG _in .TO-LOG
   0 _y AT-XY
   _y CLEAR-LINE
   _addr _in DUP MAX-X > IF MAX-X \STRING THEN TYPE 
;

: skey
\ получить подход€щий символ
   BEGIN
    EKEY
    EKEY>CHAR IF EXIT THEN
    DROP
   AGAIN
;

\ --------------------------------

: List=> ( list -- ) R> SWAP ForEach ;

: load-history
  /history CreateList TO history
  START{
   history-file FileLines=>
   DUP
   STR@
   "" >R R@ STR+ R>
   history AllocateNodeEnd .val !
  }EMERGE 
  "" history AllocateNodeEnd .val ! \ всегда есть один элемент в списке!
  ;

: htype history List=> .val @ STR@ CR TYPE ;

: SAFE-COMPARE { a u a1 u1 -- ? }
   a 0= IF TRUE EXIT THEN
   a1 0= IF TRUE EXIT THEN
   a u a1 u1 COMPARE ;

EXPORT

: ACCEPT2 ( a u -- n )
   TO _n1
   TO _addr
   0 TO in-history
   0 TO _in
   0 TO _last
   AT-XY? TO _y DROP
  BEGIN
   _in 1+ _n1 > IF _in EXIT THEN
   skey 
   DUP 13 <>
  WHILE
   accept-one 
   display
\   CR _in . _last . 
  REPEAT
  CR
  DROP
  START{
   history List=> .val @ STR@ _addr _in SAFE-COMPARE 0= ONTRUE 0 TO _addr
  }EMERGE
  _addr IF
   _addr _in " {s}" history AllocateNodeBegin .val ! \ добавили в историю
   _addr _in history-file ATTACH-LINE-CATCH DROP
  THEN
  _in
;

load-history
' ACCEPT2 TO ACCEPT

;MODULE
