REQUIRE /TEST ~profit/lib/testing.f

\ Двоичный поиск по функции. a , b -- это начальный диапазон 
\ целочисленных значений аргументов функции f , которая 
\ представлена xt соотв. процедуры
\ При запуске процедура берёт одно проверочное значение со стека
\ и выдаёт +1|0|-1 , совпадение -- ноль, +1 -- больше, -1 -- 
\ меньше.
\ На выходе флаг и найденное значение аргумента функции f при котором
\ f=0, либо если не было найдено, то последнее приближение к тому

\ Можно использовать и как для поиска по отсортированному массиву, так 
\ и для вычисления обратной функции.

: binary-search ( a b f -- i 0|-1 ) >R \ f ( i -- +1|0|-1)
BEGIN 2DUP < WHILE
2DUP + 2/
DUP R@ EXECUTE ( +1|0|-1 ) \ теплее|попал|холоднее
DUP 0= IF DROP NIP NIP TRUE RDROP EXIT THEN \ есть совпадение
0< IF NIP 1- ELSE ROT DROP 1+ SWAP THEN \ вилка
REPEAT

DUP R@ EXECUTE 0= IF NIP TRUE RDROP EXIT THEN \ доп. проверка на краевой случай
DROP FALSE RDROP ;

/TEST

: SGN ( x -- sgn(x)
DUP 0= IF EXIT THEN
 0< IF -1 EXIT THEN
1 ;

CREATE tmp
HERE
$> 0 , 1 , 3 , 5 , 6 , 10 , 20 , 33 , 123 , 231 , 400 ,
HERE SWAP - CELL / VALUE len

0 VALUE n

: 3DUP 2OVER 2OVER 3 ROLL DROP ;


:NONAME ( i -- f )  CELLS tmp + @ n - NEGATE SGN ; CONSTANT arrI
0 len arrI
$> 10 TO n binary-search . .
0 len arrI
$> 400 TO n binary-search . .
0 len arrI
$> 8 TO n binary-search . .

:NONAME ( x -- f ) DUP * n - NEGATE SGN ; CONSTANT sqrF

$> 1 1000 sqrF 400 TO n binary-search . .
$> 1 1000 sqrF 9 TO n binary-search . .
$> 1 1000 sqrF 1001 TO n binary-search . .