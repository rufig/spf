\ $Id$
\
\ Автодополнение в консоли SPF
\ На жаль пока без истории ввода..

REQUIRE /STRING lib/include/string.f

0 VALUE _addr 
0 VALUE _n1 
0 VALUE _in
0 VALUE _last
0 VALUE _y

REQUIRE AT-XY ~day/common/console.f

WINAPI: GetConsoleScreenBufferInfo KERNEL32.DLL
CREATE CONSOLE_SCREEN_BUFFER_INFO 22 ALLOT

: AT-XY? ( -- x y )
\ определение координаты курсора
  CONSOLE_SCREEN_BUFFER_INFO H-STDOUT GetConsoleScreenBufferInfo DROP
  CONSOLE_SCREEN_BUFFER_INFO 4 + DUP W@ SWAP 2+ W@ ;

: CLEAR-LINE ( y -- )
   0 SWAP 16 LSHIFT OR 0 >R RP@ SWAP MAX-XY NIP BL H-STDOUT FillConsoleOutputCharacterA R> 2DROP ;

: scanback ( addr u -- a' u' )
  2DUP
  BEGIN
    1-
    2DUP + C@ IsDelimiter IF NIP 1+ /STRING EXIT THEN
    DUP 0=
  UNTIL
  2DROP
;

: SUBSTART ( a u a1 u1 -- 0 | -1 )
   2>R OVER 2R> ROT >R  ( a u a1 u1 ) ( R: a ) \ %)
   SEARCH NIP IF R> <> ELSE DROP RDROP -1 THEN ;

: CDR-BY-NAME-START ( a u nfa1|0 -- a u nfa2|0 )
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
   _last OVER + _n1 > IF 2DROP _in EXIT THEN
   >R _addr _last scanback DROP R> 2DUP + >R CMOVE 
   R> _addr -
;

: accept-one ( c -- )
   DUP 9 = \ tab
   IF 
     DROP
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
     DROP
     _in 1 MAX 1- TO _in 
     _in TO _last
     EXIT
   THEN
   DUP 32 < IF DROP EXIT THEN
   \ put one char
   _addr _in + C!
   _in 1 + TO _in
   _in TO _last
;

: display
   0 _y AT-XY 
   _y CLEAR-LINE
   _addr _in TYPE ;

: skey 
   BEGIN
    EKEY
    EKEY>CHAR IF EXIT THEN
    DROP 
   AGAIN
;

: ACCEPT2 
   0 TO _in
   0 TO _last
   AT-XY? TO _y DROP
   TO _n1
   TO _addr
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
  _in
;

' ACCEPT2 TO ACCEPT

