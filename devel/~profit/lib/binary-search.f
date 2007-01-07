REQUIRE LOCAL ~profit/lib/static.f

: binary-search ( a b f -- i 0|-1 ) LOCAL f f ! \ f ( i -- +1|0|-1)
BEGIN 2DUP < WHILE
2DUP + 2/
DUP f @ EXECUTE ( +1|0|-1 ) \ теплее|попал|холоднее
DUP 0= IF DROP NIP NIP TRUE EXIT THEN \ есть совпадение
0< IF NIP 1- ELSE ROT DROP 1+ SWAP THEN \ вилка
REPEAT

DUP f @ EXECUTE 0= IF NIP TRUE EXIT THEN \ доп. проверка на краевой случай
2DROP 0 FALSE ;

\EOF

: SGN ( x -- sgn(x)
DUP 0= IF EXIT THEN
0< IF -1 EXIT THEN 1  ;

CREATE tmp
HERE
0 , 1 , 3 , 5 , 6 , 10 , 20 , 33 , 123 , 231 , 400 ,
HERE SWAP - CELL / ( len )

0 VALUE n

10 TO n

0 SWAP
:NONAME ( i -- f )  CELLS tmp + @ n - NEGATE SGN ;
binary-search