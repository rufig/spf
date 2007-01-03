\ $Id$
\
\ Автодополнение в консоли SPF
\ Временно перебор истории - Ctrl-B Ctrl-N

REQUIRE /STRING lib/include/string.f
REQUIRE AT-XY ~day/common/console.f
REQUIRE InsertNodeEnd ~day/lib/staticlist.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE ATTACH-LINE-CATCH ~pinka/samples/2005/lib/append-file.f

WINAPI: GetConsoleScreenBufferInfo KERNEL32.DLL


MODULE: ACCEPT-Autocompletion

0 VALUE _addr \ адрес буфера для ACCEPT
0 VALUE _n1 \ длина буфера для ACCEPT
0 VALUE _in \ длина текста
0 VALUE _last \ позиция последнего символа введённого руками (не автодополнением)
0 VALUE _y \ номер строки на консоли
0 VALUE in-history \ состояние перебора истории
0 VALUE history \ список строк истории
0 VALUE _cursor

: history-file S" spf.history" +ModuleDirName ;

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
\ найти следующее слово в списке начинающееся на a u
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
\ поместить строку начиная от _last
   _last OVER + _n1 > IF 2DROP _in EXIT THEN
   >R _addr _last scanback DROP R> 2DUP + >R CMOVE 
   R> _addr -
;

: accept-ascii ( c -- ? )
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
     _in TO _cursor
     TRUE EXIT
   THEN

   DUP 8 = \ bksp
   IF
     DROP
     0 TO in-history
     _cursor 0= IF TRUE EXIT THEN
     _addr _cursor + DUP 1- _in _cursor - CMOVE
     _in 1 MAX 1- TO _in
     _in TO _last
     _cursor 1- TO _cursor
     TRUE EXIT
   THEN

   DUP 13 = IF
     DROP
     0 TO in-history
     FALSE EXIT 
   THEN

   DUP 32 < IF DROP FALSE EXIT THEN

   \ put one char
   0 TO in-history
   _addr _cursor + DUP 1+ _in _cursor - CMOVE>
   _addr _cursor + C!
   _in 1+ TO _in
   _cursor 1+ TO _cursor
   _in TO _last
   TRUE ;

: accept-scan ( c -- )
   DUP 72 = IF \ up arrow
     DROP
     in-history DUP 0= IF DROP history firstNode THEN
     PrevCircleNode TO in-history
     0 TO _last
     in-history .val @ STR@ put DUP TO _in TO _last
     _in TO _cursor
     EXIT
   THEN
   DUP 80 = IF \ down arrow
     DROP
     in-history DUP 0= IF DROP history firstNode THEN
     NextCircleNode TO in-history
     0 TO _last
     in-history .val @ STR@ put DUP TO _in TO _last
     _in TO _cursor
     EXIT
   THEN
   DUP 75 = IF \ left arrow
     DROP
     _cursor 1 MAX 1- TO _cursor
     EXIT
   THEN
   DUP 77 = IF
     DROP
     _cursor 1+ _in MIN TO _cursor
     EXIT
   THEN
   DROP ;

: accept-one ( c -1|0 -- ? )
\ обработка одного символа
   IF accept-ascii ELSE accept-scan TRUE THEN ;

: \STRING ( a u n -- a+u-n n ) OVER MIN >R + R@ - R> ;

: MAX-X MAX-XY DROP 1- ;

: display
\ показать буфер
\   LT LTL @ TO-LOG _y .TO-LOG _in .TO-LOG
   0 _y AT-XY
   _y CLEAR-LINE
   _addr _in TYPE
   _cursor _y AT-XY
\   _addr _in DUP MAX-X > IF MAX-X \STRING THEN TYPE 
;

: skey ( -- c -1|0 )
\ получить событие с клавиатуры
\ -1 - код ASCII
\  0 - скан код
   BEGIN
    EKEY
    EKEY>CHAR IF TRUE EXIT THEN
    EKEY>SCAN IF FALSE EXIT ELSE DROP THEN
   AGAIN ;

\ --------------------------------

: List=> ( list -- ) R> SWAP ForEach ;

: >STR ( a u -- s ) "" >R R@ STR+ R> ;

: add-history ( s -- ) history AllocateNodeEnd .val ! ;

: load-history
  /history CreateList TO history
  START{
   history-file FileLines=>
   DUP
   STR@ >STR add-history
  }EMERGE 
  history listSize 0= IF
   "" add-history \ всегда есть один элемент в списке!
  THEN
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
   0 TO _cursor
   AT-XY? TO _y DROP
  BEGIN
   _in 1+ _n1 > IF _in EXIT THEN
   skey accept-one 
  WHILE
   display
  REPEAT
  CR
  START{
   history List=> .val @ STR@ _addr _in SAFE-COMPARE 0= ONTRUE 0 TO _addr
  }EMERGE
  _addr _in AND 
  IF
   _addr _in " {s}" add-history \ добавили в историю
   _addr _in history-file ATTACH-LINE-CATCH DROP
  THEN
  _in
;

load-history
' ACCEPT2 TO ACCEPT

;MODULE
