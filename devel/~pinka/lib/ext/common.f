\ 2004

REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] NDROP [IF]

\ Взять со стек n, затем убрать n значений со стека.

: NDROP ( x*n n -- )  1+ CELLS SP@ + SP! ;

\ 11.Jan.2007 Thu 17:40 added:
\ see http://www.taygeta.com/forth/dpansa16.htm
: DISCARD  ( x1 .. xu u -- ) NDROP ; \ Implementation factor DROP u+1 stack items

[THEN]
