\ 05.Apr.2004  (p) ruvim@forth.org.ru
\ сравнение строки и маски, содержащей метасимволы (wildcards)  * ?
\ Сделал по другому старую либу ~pinka\lib\mask.f
\ ( на что сподвигнул меня ~pig  ;-)

\ Данная библиотека использует возможности парсера SPF4
\ $Id$

\ слово LIKE и ULIKE ( a u  a-mask u-mask -- flag )
\  сопоставляет  строку a u  с маской,
\  возвращает TRUE при успехе
\  и FALSE, если сопоставление невозможно.
\  Wildcards:
\  *  - любое количество любых символов
\  ?  - любой символ
\  \  - префикс "квотирования" специальных символов:
\       \\ -> \
\       \* -> *
\       \? -> ?
\       \q -> " ( предложение ~pig )
\  Особенности: для ускорения работы бэктрекинг сведен к минимуму 
\  и сделан через обычный цикл; используется SEARCH и COMPARE

REQUIRE SALLOC      ~pinka\lib\ext\alloc.f 
REQUIRE PARSE-AREA@ ~pinka\lib\ext\parse.f
REQUIRE UPPERCASE   ~ac\lib\string\uppercase.f 

: SEARCH&SKIP ( a u  a-subs u-subs -- a2 u2 true | a u false )
    DUP >R   SEARCH         IF
    SWAP R@ +  
    SWAP R@ -       TRUE    ELSE

    FALSE                   THEN
    RDROP
;
: MATCH-SIMPLE ( a u apat upat -- a1 u1 flag )
  DUP >R 
  2OVER ROT U< IF 2DROP RDROP FALSE EXIT THEN
  R@ TUCK COMPARE IF RDROP FALSE EXIT THEN
  SWAP R@ + SWAP R> -  TRUE
;

MODULE: WildCardsSupport

CHAR \ VALUE quote-char

\ GetChar ( -- char flag )

: IsCharWild ( c -- flag )
  DUP [CHAR] * = IF DROP TRUE EXIT THEN
  DUP [CHAR] ? = IF DROP TRUE EXIT THEN
  DROP FALSE
;
: ProcessQuote ( -- )
\ удаляет quote-char в шаблоне
  CharAddr    >IN 1+!
  PARSE-AREA@
  DUP 0= IF 2DROP DROP EXIT THEN
  ( a1  a u )
  ROT SWAP   2DUP SOURCE!   CMOVE
  GetChar IF
   DUP [CHAR] q = IF
     [CHAR] " CharAddr C!
   THEN ( c )
   >IN 1+!
  THEN DROP
;
: NextPat ( -- a u )
\ дает подстроку из шаблона   (и скипает ее)
  CharAddr
  BEGIN
   GetChar
  WHILE
   DUP IsCharWild 0=
  WHILE ( c )
   quote-char =  IF
   ProcessQuote  ELSE
    >IN 1+!      THEN
  REPEAT THEN ( addr c ) DROP
  CharAddr OVER -
;
: QMatch ( a u -- a1 u1 f )
\ сопоставляет с шаблоном, содержащим '?'
  BEGIN
    NextPat DUP IF
      MATCH-SIMPLE 0= IF FALSE EXIT THEN
    ELSE 2DROP THEN
    GetChar
  WHILE
    DUP [CHAR] ? =
  WHILE
    DROP >IN 1+!
    DUP IF  SWAP 1+  SWAP 1- ELSE FALSE EXIT THEN
  REPEAT THEN DROP  TRUE
;
: QMatch2 ( a u -- a1 u1 f )
\ при неуспехе  счетчики оставляет неизменными
  2DUP PARSE-AREA@ 2>R
  QMatch IF 2SWAP 2DROP 2R> 2DROP TRUE EXIT THEN
  2DROP 2R> SOURCE! FALSE
;
: Process(*) ( a u -- a1 u1 flag )
\ ищет по под-шаблону
  NextPat DUP 0= IF 2DROP TRUE EXIT THEN
  2>R
  BEGIN ( a u )
    2R@  SEARCH&SKIP
  WHILE
    QMatch2
    DUP IF EndOfChunk IF DROP DUP 0=  THEN THEN
  UNTIL TRUE ELSE FALSE THEN   2R> 2DROP
;
: (LIKE-MASK) ( a1 u1 -- a2 u2 flag )
  BEGIN
    GetChar
  WHILE
    [CHAR] * =   IF
    >IN 1+!  EndOfChunk IF TRUE EXIT THEN
    Process(*)   ELSE
    QMatch       THEN
    0=
  UNTIL FALSE ELSE DROP DUP 0= THEN
;

EXPORT

: LIKE-MASK\  ( a1 u1 -- flag )
\ остаток чанка - маска
  (LIKE-MASK) NIP NIP POSTPONE \
;
: LIKE ( a1 u1 a-mask u-mask -- flag )
  TUCK SALLOC DUP >R SWAP
  ['] LIKE-MASK\ EVALUATE-WITH
  R> FREE THROW
;
: ULIKE ( a1 u1 a-mask u-mask -- flag )
  2SWAP  TUCK SALLOC DUP >R SWAP 2DUP UPPERCASE
  2SWAP  TUCK SALLOC DUP >R SWAP 2DUP UPPERCASE
  ['] LIKE-MASK\ EVALUATE-WITH
  R> FREE THROW  R> FREE THROW
;

;MODULE \ WildCardsSupport

 ( example
  S" Zbaabbb777778" S" ?b*7*8" LIKE .
  S" 012WebMaster" S" ???w??mas*" ULIKE .
  S" INBOX" S" INBOX*" ULIKE .
  S" http://blablabla.html?.newshub.eserv.ru/" S" http://*\?.*/"  ULIKE .
\ )
