\ 13.Dec.2005
\ 04.Nov.2006 Sat 21:37
\ $Id$

: IS-WHITE ( c -- flag )  \ or 'IsWhite' ?
  0x21 U<
;
: FINE-HEAD ( c-addr u -- c-addr1 u1 )
\ "очистить голову" - дать строку за вычетом пробельных символов вначале
  BEGIN DUP WHILE OVER C@ IS-WHITE WHILE SWAP CHAR+ SWAP 1- REPEAT THEN
;
: FINE-TAIL ( c-addr u -- c-addr u2 ) \ see also "-TRAILING"
\ "очистить хвост" - дать строку за вычетом пробельных символов в конце
  CHARS OVER + BEGIN 2DUP U< WHILE CHAR- DUP C@ IS-WHITE 0= UNTIL CHAR+ THEN OVER - >CHARS
;
: SPLIT-WHITE-FORCE ( c-addr u -- c-addr-left u-left  c-addr-right u-right )
\ 'FORCE' значит, что без флага
\ если разделитель не найден, то правая часть имеет длину 0.
\ white как бы имеет длину ноль (т.е., он остается в правой части)
  2DUP CHARS OVER + SWAP
  BEGIN 2DUP U> WHILE DUP CHAR+ SWAP C@ IS-WHITE UNTIL CHAR- THEN
  ( c-addr u  a2 a1 )
  DUP >R - >CHARS  DUP >R -  2R>
;
: -SPLIT-WHITE-FORCE ( c-addr u -- c-addr-left u-left  c-addr-right u-right )
\ поиск в обратном направлении,  начиная с конца строки
\ если разделитель не найден, то левая часть имеет длину 0.
\ если найден, то он остается в левой части.
  2DUP CHARS OVER +
  BEGIN 2DUP U< WHILE CHAR- DUP SWAP C@ IS-WHITE UNTIL CHAR+ THEN
  ( c-addr u  c-addr c-addr1 )
  TUCK >R - >CHARS TUCK - R> SWAP
;
: UNBROKEN ( c-addr u -- c-addr u2 )
\ Если в конце нет пробельных символов, но в строке они имеются,
\ то выкидывает последнее слово как сомнительное в целостности.
  -SPLIT-WHITE-FORCE 2 PICK IF 2DROP EXIT THEN 2SWAP 2DROP
;
: WORD|TAIL ( a u -- a u1 a-rest u-rest ) 
  FINE-HEAD SPLIT-WHITE-FORCE
;
