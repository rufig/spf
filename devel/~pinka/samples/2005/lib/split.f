\ Dec.2004
\ $Id$

: SPLIT- ( a u a-key u-key -- a-right u-right  a-left u-left  true  |  a u false )
\ разделить строку a u на часть слева от подстроки a-key u-key
\ и на часть справа от этой подстроки.

  2OVER DROP >R DUP >R ( R: a u1 )
  SEARCH   IF  ( aa uu )
  OVER R@ + SWAP R> - \ aa+u1 uu-u1  - right part
  ROT R@ - R> SWAP    \ a aa-a       - left part
  TRUE EXIT THEN

  2R> 2DROP FALSE
;
\ Без локальных переменных. 
\ С ними проще сделать, а работает на 20-30% медленней (см. split-test.f)

: SPLIT ( a u a-key u-key -- a-left u-left  a-right u-right  true  |  a u false )
\ вариант дает более 'логичный' порядок на выходе: левая_часть правая_часть
  DUP >R 2OVER DROP >R ( R: u1 a )
  SEARCH   IF  ( aa uu )
  SWAP R@ OVER R> -     \ a aa-a       - left part
  2SWAP R@ + SWAP R> -  \ aa+u1 uu-u1  - right part
  TRUE EXIT THEN

  2R> 2DROP FALSE
;
: MOVE- ( a-dst  a-src u-src -- )
  ROT SWAP MOVE
;
: INPLACE- ( a u a-key u-key a-value u-value -- )
  \ записывает value по всем key
  2>R 2SWAP
  BEGIN  2OVER SPLIT-
  WHILE  + 2R@ MOVE-
  REPEAT 2DROP 2DROP 2R> 2DROP
;

: PLACED- ( a-dst u-dst a-src u-src -- )
  ROT UMIN >R SWAP R> MOVE
;
: PLACE- ( a-dst u-dst a-src u-src -- a-dst u )
  ROT UMIN >R OVER R@ MOVE R>
;
\ see also  ~mak\place.f 
