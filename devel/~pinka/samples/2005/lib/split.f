\ Dec.2004
\ $Id$

: SPLIT ( a u a1 u1 -- a3 u3 a2 u2 true | a u false )
\ разделить строку a u на часть слева (a2 u2) от подстроки a1 u1
\ и на часть справа (a3 u3) от этой подстроки.

  2OVER DROP >R DUP >R ( R: a u1 )
  SEARCH   IF  ( aa uu )
  OVER R@ + SWAP R> - \ aa+u1 uu-u1  - right part
  ROT R@ - R> SWAP    \ a aa-a       - left part
  TRUE               ELSE
  2R> 2DROP FALSE    THEN
;

\EOF
\ Ниже вариант с локальными переменными.
\ Сделать проще. Работает на 19% медленней.

REQUIRE { lib/ext/locals.f

: SPLIT ( a u a1 u1 -- a3 u3 a2 u2 true | a u false )
\ разделить строку a u на часть слева (a2 u2) от подстроки a1 u1
\ и на часть справа (a3 u3) от этой подстроки.

  { a u a1 u1 \ aa uu }
  a u a1 u1 SEARCH   IF
  -> uu -> aa
  aa u1 + uu u1 -
  aa a - a SWAP
  TRUE               ELSE
  FALSE              THEN
;
: SPLIT2 ( a u a1 u1 -- a2 u2 a3 u3 true | a u false )
\ разделить строку a u на часть слева (a2 u2) от подстроки a1 u1
\ и на часть справа (a3 u3) от этой подстроки.

  { a u a1 u1 \ aa uu }
  a u a1 u1 SEARCH   IF
  -> uu -> aa
  aa a - a SWAP
  aa u1 + uu u1 - 
  TRUE               ELSE
  FALSE              THEN
;
