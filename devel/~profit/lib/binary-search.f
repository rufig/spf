REQUIRE /TEST ~profit/lib/testing.f
REQUIRE LOCAL ~profit/lib/static.f

\ Двоичный поиск по функции. a , b -- это начальный диапазон 
\ целочисленных значений, аргументов функции f , которая 
\ представлена xt соотв. процедуры
\ При запуске процедура берёт одно проверочное значение со стека
\ и выдаёт +1|0|-1 , совпадение -- ноль, +1 -- больше, -1 -- 
\ меньше.
\ На выходе флаг и найденное значение аргумента функции f при котором
\ f=0, либо тоже 0 если такое значение аргумента не найдено.
: binary-search ( a b f -- i 0|-1 ) LOCAL f f ! \ f ( i -- +1|0|-1)
BEGIN 2DUP < WHILE
2DUP + 2/
DUP f @ EXECUTE ( +1|0|-1 ) \ теплее|попал|холоднее
DUP 0= IF DROP NIP NIP TRUE EXIT THEN \ есть совпадение
0< IF NIP 1- ELSE ROT DROP 1+ SWAP THEN \ вилка
REPEAT

DUP f @ EXECUTE 0= IF NIP TRUE EXIT THEN \ доп. проверка на краевой случай
2DROP 0 FALSE ;

/TEST

: SGN ( x -- sgn(x)
DUP 0= IF EXIT THEN
0< IF -1 EXIT THEN 1  ;

CREATE tmp
HERE
$> 0 , 1 , 3 , 5 , 6 , 10 , 20 , 33 , 123 , 231 , 400 ,
HERE SWAP - CELL / VALUE len

0 VALUE n

: 3DUP 2OVER 2OVER 3 ROLL DROP ;

0 len
:NONAME ( i -- f )  CELLS tmp + @ n - NEGATE SGN ;
3DUP 3DUP
$> 10 TO n binary-search . .
$> 400 TO n binary-search . .
$> 8 TO n binary-search . .