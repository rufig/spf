\ Концепт алгоритма Forth-Wizard'а с перебором в ширину.

REQUIRE FOR ~profit/lib/for-next.f
REQUIRE состояние ~profit/lib/chartable.f

состояние операции
символ: 1 ." DUP " ;
символ: 2 ." SWAP " ;
символ: 3 ." OVER " ;
символ: 4 ." DROP " ;
символ: 5 ." ROT " ;
символ: 6 ." >R " ;
символ: 7 ." R> " ;

: str ( n -- addr u ) S>D <# #S #> ;

: convertNumber2Operations ( n -- )
str SWAP операции поставить-курсор -символов-обработать ;

: r BASE @
8 BASE !

BASE @
3 ( кол-во макс. шагов ) 1 DO BASE @ * LOOP
0 DO CR I convertNumber2Operations LOOP
BASE !
;
STARTLOG r