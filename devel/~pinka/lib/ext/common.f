REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] NDROP [IF]

\ Взять со стек n, затем убрать n значений со стека.

: NDROP ( x*n n -- )  1+ CELLS SP@ + SP! ;

[THEN]
