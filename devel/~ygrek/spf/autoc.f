\ $Id$
\
\ ƒополнение слов в консоли SPF
\
\ ѕеребор вариантов дополнени€ - Tab
\ »стори€ ввода - стрелки вниз/вверх
\ ќчистить текущий ввод - Esc
\ Ќавигаци€ - Home, End, стрелки влево/вправо
\ ”даление - Bksp, Del

REQUIRE /STRING lib/include/string.f
REQUIRE AT-XY ~day/common/console.f
REQUIRE InsertNodeEnd ~day/lib/staticlist.f
REQUIRE FileLines=> ~ygrek/lib/filelines.f
REQUIRE ATTACH-LINE-CATCH ~pinka/samples/2005/lib/append-file.f
REQUIRE [IF] lib/include/tools.f
REQUIRE LAMBDA{ ~pinka/lib/lambda.f

\ повторна€ загрузка не нужна
C" ACCEPT-Autocompletion" FIND NIP [IF] \EOF [THEN]

WINAPI: GetConsoleScreenBufferInfo KERNEL32.DLL

MODULE: ACCEPT-Autocompletion

0 VALUE _addr \ адрес буфера дл€ ACCEPT
0 VALUE _n1 \ длина буфера дл€ ACCEPT
0 VALUE _in \ длина текста
0 VALUE _last \ позици€ последнего символа введЄнного руками (не автодополнением)
0 VALUE _y \ номер строки на консоли
0 VALUE _x \ номер колонки
0 VALUE in-history \ состо€ние перебора истории
0 VALUE history \ список строк истории
0 VALUE _cursor \ позици€ в строке на которую указывает видимый курсор

: history-file S" spf.history" +ModuleDirName ;

/node 
CELL -- .val
CONSTANT /history

CREATE CONSOLE_SCREEN_BUFFER_INFO 22 ALLOT

: AT-XY? ( -- x y )
\ определение координат курсора
  CONSOLE_SCREEN_BUFFER_INFO H-STDOUT GetConsoleScreenBufferInfo DROP
  CONSOLE_SCREEN_BUFFER_INFO 4 + DUP W@ SWAP 2+ W@ ;

: CLEAR-LINE ( x y -- )
\ очистить строку
   16 LSHIFT OR 0 >R RP@ SWAP MAX-XY NIP BL H-STDOUT FillConsoleOutputCharacterA R> 2DROP ;

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
\ найти следующее слово в списке слов начинающеес€ на a u
 BEGIN  ( a u NFA | a u 0 )
   DUP
 WHILE  ( a u NFA )
   >R 2DUP R@ COUNT 2SWAP SUBSTART R> SWAP
 WHILE
   CDR  ( a u NFA2 )
 REPEAT THEN 
;

: put ( a u -- in )
\ поместить строку начина€ от _last
   _last OVER + _n1 > IF 2DROP _in EXIT THEN
   >R _addr _last scanback DROP R> 2DUP + >R CMOVE 
   R> _addr - ;

: nfa-of-input ( -- nfa -1 | 0 )
   _addr _in scanback \ last full word
   CONTEXT @ SEARCH-WORDLIST-NFA ;

: completion ( nfa1 -- nfa2 )
   _addr _last scanback \ last realpart word
   ROT
   CDR-BY-NAME-START
   NIP NIP ;

: accept-ascii ( c -- ? )
   DUP 9 = \ tab
   IF 
     0 TO in-history
     nfa-of-input 0= IF CONTEXT @ @ ELSE CDR THEN 
     completion DUP IF COUNT put TO _in ELSE DROP _last TO _in THEN
     _in TO _cursor
   THEN

   DUP 8 = \ bksp
   IF
     0 TO in-history
     _cursor 0= IF DROP EXIT THEN
     _addr _cursor + DUP 1- _in _cursor - CMOVE
     _in 1 MAX 1- TO _in
     _in TO _last
     _cursor 1- TO _cursor
   THEN

   DUP 13 = IF
     0 TO in-history
   THEN
        
   DUP 27 = IF \ Esc - очистить ввод
     0 TO in-history
     0 TO _cursor
     0 TO _in
     0 TO _last
   THEN

   DUP 32 < IF DROP EXIT THEN

   \ put one char
   0 TO in-history
   _addr _cursor + DUP 1+ _in _cursor - CMOVE>
   _addr _cursor + C!
   _in 1+ TO _in
   _cursor 1+ TO _cursor
   _in TO _last 

   EXIT \ эксперименатльна€ фича %)
   
   \ ?AUTOCOMPLETION 0= IF EXIT THEN
   \ если на вводе готовое слово - ничего не делаем
   nfa-of-input IF DROP EXIT THEN
   \ иначе ищем дополнение
   CONTEXT @ @ completion DUP 0= IF DROP EXIT THEN \ если их нет - выходим
   DUP CDR completion IF DROP EXIT THEN \ если их больше одного - тоже выходим
   \ иначе подставл€ем сразу!
   COUNT put TO _in 
   _in TO _cursor ;

: accept-scan ( c -- )
   DUP 72 = IF \ up arrow
     in-history DUP 0= IF DROP history firstNode THEN
     PrevCircleNode TO in-history
     0 TO _last
     in-history .val @ STR@ put DUP TO _in TO _last
     _in TO _cursor
   THEN
   DUP 80 = IF \ down arrow
     in-history DUP 0= IF DROP history firstNode THEN
     NextCircleNode TO in-history
     0 TO _last
     in-history .val @ STR@ put DUP TO _in TO _last
     _in TO _cursor
   THEN
   DUP 75 = IF \ left arrow
     _cursor 1 MAX 1- TO _cursor
   THEN
   DUP 77 = IF \ right arrow
     _cursor 1+ _in MIN TO _cursor
   THEN
   DUP 71 = IF \ Home
     0 TO _cursor
   THEN
   DUP 79 = IF \ End
     _in TO _cursor
   THEN
   DUP 83 = IF \ Delete
     0 TO in-history
     _addr _cursor + DUP 1+ SWAP _in _cursor - CMOVE
     _in 1 MAX 1- TO _in
     _in TO _last
   THEN
   DROP ;

: accept-one ( c -1|0 -- ? )
\ обработка одного символа
   IF DUP accept-ascii 13 <> ELSE accept-scan TRUE THEN ;

: \STRING ( a u n -- a+u-n n ) OVER MIN >R + R@ - R> ;
: MAX-X MAX-XY DROP 1- ;

: display
\ показать буфер
\   LT LTL @ TO-LOG _y .TO-LOG _in .TO-LOG
   _x _y AT-XY
   _x _y CLEAR-LINE
   _addr _in TYPE
   _cursor _x + _y AT-XY
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
: dump-history ( -- ) \ всю историю в файл заново
   \ очистить файл
   history-file R/W CREATE-FILE THROW CLOSE-FILE THROW 
   \ записать весь список
   LAMBDA{ .val @ STR@ history-file ATTACH-LINE-CATCH DROP } history ForEach ;

: load-history
  /history CreateList TO history
  START{
   history-file FileLines=>
   DUP
   STR@ >STR add-history
  }EMERGE 
  history listSize 0= IF
   "" add-history \ всегда есть один элемент в списке!
  THEN ;

: htype history List=> .val @ STR@ CR TYPE ;

: SAFE-COMPARE { a u a1 u1 -- ? }
   a 0= IF TRUE EXIT THEN
   a1 0= IF TRUE EXIT THEN
   a u a1 u1 COMPARE ;

: ACCEPT-WITH-AUTOCOMPLETION ( a u -- n )
   TO _n1
   TO _addr
   0 TO in-history
   0 TO _in
   0 TO _last
   0 TO _cursor
   AT-XY? TO _y TO _x
  BEGIN
   _in 1+ _n1 > IF _in EXIT THEN
   skey accept-one 
  WHILE
   display
  REPEAT
  CR
  _in 0= IF _in EXIT THEN
  LAMBDA{
   DUP .val @ STR@ _addr _in SAFE-COMPARE 0= IF .val @ add-history FALSE ELSE DROP TRUE THEN
  } history ?ForEach
  DUP 
  IF
    FreeNode 
    dump-history
  ELSE
   DROP
   _addr _in " {s}" add-history \ добавили в историю
   _addr _in history-file ATTACH-LINE-CATCH DROP
  THEN
  _in
;

load-history
' ACCEPT-WITH-AUTOCOMPLETION TO ACCEPT
CR .( Autocompletion loaded) CR

;MODULE
