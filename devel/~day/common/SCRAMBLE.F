\ Перемешиваем строку символов

CREATE Table C" abcdefghijklmnopqrstuvwxyz" ",

REQUIRE CHOOSE ~day\common\rnd.f

0 VALUE Count
0 VALUE AddrInTable
0 VALUE AddrOutTable

: Scramble ( addr u -- )
    1- TO Count
    TO AddrInTable
    BEGIN
      Count CHOOSE  >R
      AddrInTable Count + C@ 
      AddrInTable R@ + C@ 
      AddrInTable Count + C!
      AddrInTable R> + C!          
      Count 1- TO Count     
      Count 0= IF -1 ELSE 0 THEN
    UNTIL
;  
     
( \ Example
Table COUNT Scramble
Table COUNT TYPE
)