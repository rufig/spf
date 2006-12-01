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
\ С ними проще сделать, а работает на 15-20% медленней (см. split-test.f)

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

: SEAT- ( a-dst u-dst a-src u-src -- )
  ROT UMIN >R SWAP R> MOVE
;
: SEATED- ( a-dst u-dst a-src u-src -- a-dst u )
  ROT UMIN >R OVER R@ MOVE R>
;
\ see also  ~mak\place.f 


\ 01.Dec.2006 added:

: REPLACE- ( a u a-k u-k a-new u-new -- a u3 )
\ заменяет "на месте". Перемещает на каждом шаге весь оставшийся кусок. Без проверки границ.
  5 PICK >R 2>R 2SWAP
  ( a-k u-k  a-rest u-rest )
  BEGIN 2OVER SPLIT- WHILE ( a-k u-k  a-r u-r a-l u-l )
    + R@ OVER >R + SWAP ( a-k u-k   a-r a-dest2 u-r )
    2DUP 2>R MOVE 2R> ( a-k u-k   a-rest u-rest )
    R> ( a-k u-k  a-rest u-rest   a-dest1 )
    2R> 2DUP 2>R  ( a-k u-k  a-rest u-rest   a-dest1 a-src u-src )
    ROT SWAP MOVE
  REPEAT ( a-k u-k  a-rest u-rest )
  + NIP NIP RDROP RDROP
  R> TUCK -
;
\ S" How are you?" ( placeholder )  S" How" S" Where, where" REPLACE- TYPE CR SOURCE TYPE CR

: ENLARGE ( a1 u1 a-dst u-dst-max -- a-rest u-rest )
  DUP >R ROT UMIN DUP >R 2DUP + >R  MOVE R> 2R> -
;
: REPLACE-TO ( a u a-k u-k a-new u-new a-dst u-dst-max -- a-dst u )
\ делает замену в указанный буфер  с проверкой границ.
  OVER >R  2SWAP 2>R 2>R  2SWAP
  BEGIN 2OVER SPLIT- WHILE 2R> ENLARGE 2R@ 2SWAP ENLARGE 2>R REPEAT 2SWAP 2DROP
  2R> ENLARGE DROP ( a2 ) RDROP RDROP R> TUCK -
;
\ S" How are you?" S" How" S" Where" S" placeholder to place string here" REPLACE-TO TYPE
