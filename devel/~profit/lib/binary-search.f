REQUIRE /TEST ~profit/lib/testing.f
REQUIRE <= ~profit/lib/logic.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE PRO ~profit/lib/bac4th.f

\ Двоичный поиск по функции. a , b -- это начальный диапазон 
\ целочисленных значений аргументов функции f , которая 
\ представлена xt соотв. процедуры
\ При запуске процедура берёт одно проверочное значение со стека
\ и выдаёт +1|0|-1 , совпадение -- ноль, +1 -- больше, -1 -- 
\ меньше.
\ На выходе флаг и найденное значение аргумента функции f при котором
\ f=0, либо если не было найдено, то последнее приближение к тому

\ Можно использовать и как для поиска по отсортированному массиву, так 
\ и для вычисления обратной функции (см. примеры внизу).

\ binary-search неудобный! Используйте reverse-function
: binary-search ( a b f -- i 0|-1 ) >R \ f ( i -- +1|0|-1)
BEGIN 2DUP < WHILE
2DUP + 2/
DUP R@ EXECUTE ( +x|0|-x ) \ перелёт|попал|недолёт
DUP 0= IF DROP NIP NIP TRUE RDROP EXIT THEN \ есть совпадение
0< IF NIP 1- ELSE ROT DROP 1+ SWAP THEN \ вилка
REPEAT

DUP R@ EXECUTE 0= IF NIP TRUE RDROP EXIT THEN \ доп. проверка на краевой случай
DROP FALSE RDROP ;

\ Цикл двоичного поиска. Выдаёт значения c и ожидает получить флаг, 
\ указывающий куда ему идти дальше (если щуп найдёт то что нужно,
\ то это должна будет обработать внешняя процедура).
\ Каждый нырок этого слова -- это закидывание щупа и определение
\ где его кинуть в следующий раз
\ На входе: начальный диапазон (a,b)
: fork-cycle ( a b --> c \ <-- flag ) PRO
BEGIN
2DUP <= WHILE
2DUP + 2/ ( a b c )
DUP CONT ( flag )
IF NIP 1- ELSE ROT DROP 1+ SWAP THEN \ вилка
REPEAT ;
\ TODO: Выходы из этого слова не полностью проконтролированы

\ Ищет в диапазоне (a,b) такое значение x, что функция 
\ (записанная в шитом коде после неё) равна res
\ Если найдено flag=TRUE и x -- значение, где f(x)=res
\ Если не найдено, то flag=FALSE и x -- равно либо
\ floor(x'), где f(x')=res, либо равно одному из краевых
\ значений если искомого значения аргумента вообще нет в
\ заданном диапазоне.
\ Только для линейных функций, само собой.
: reverse-function ( a b res --> x \ x flag <-- x' )
R> LOCAL f f ! \ PRO .. CONT не работают из-за того что PREDICATE .. SUCCEEDS тоже используют L-стек
\ поэтому адрес успеха сохраняем в локальной переменной и вызываем вручную
LOCAL res res !
PREDICATE
fork-cycle f @ ENTER \ над полученным от fork-cycle c выполняем функцию 
( fc ) \ В ответ получаем значение f(c)
res @ - ( delta ) \ Находим насколько он соответствует
BACK 0 > TRACKING \ Если не попали, значит надо для отката в fork-cycle 
\ указать направление, где щупать дальше
DUP 0= \ Прямое попадание?
ONTRUE
SUCCEEDS
DUP IF NIP 2SWAP 2DROP ELSE ROT DROP THEN ;
\ Некоторое стековое шаманство здесь... Зависимость от деталей 
\ реализации fork-cycle чего быть не должно (TODO)

/TEST

CREATE tmp
HERE
$> 0 , 1 , 3 , 5 , 6 , 10 , 20 , 33 , 123 , 231 , 400 ,
HERE SWAP - CELL / VALUE len

0 VALUE n

: 3DUP 2OVER 2OVER 3 ROLL DROP ;


:NONAME ( i -- f )  CELLS tmp + @ n - NEGATE ; CONSTANT arrI
0 len arrI
$> 10 TO n binary-search . .
0 len arrI
$> 400 TO n binary-search . .
0 len arrI
$> 8 TO n binary-search . .

:NONAME ( x -- f ) DUP * n - NEGATE ; CONSTANT sqrF

$> 1 1000 sqrF 400 TO n binary-search . .
$> 1 1000 sqrF 9 TO n binary-search . .
$> 1 1000 sqrF 1001 TO n binary-search . .

: 10/ ( res -- x ) 0 SWAP DUP DROPB reverse-function 10 * ;

REQUIRE factor ~profit/lib/bin-mul.f

: sqrt
DUP MAX{ factor DUP }MAX \ находим максимальную степень двойки в числе
2/ \ берём от неё квадратный корень, т.е. делим степень на два
defactor \ переводим из экспоненциального вида к обычному, т.е. возводим в степень
DUP 2* \ формируем диапазон в котором находится корень числа
ROT DROPB reverse-function DUP * ;

: // ( a b -- a/b )
OVER -ROT ( a a b )
LOCAL b DUP b !
MAX{ factor DUP }MAX 1+
RSHIFT DUP 2*
ROT DROPB reverse-function b @ * ;

:NONAME
CR CR ." sqrt " CR   200 0 DO I sqrt . LOOP
CR CR ." 10/  " CR   200 0 DO I 10/ . LOOP
CR CR ." //  " CR
1234567890 111111 // . ." =" 1234567890 111111 / .
; EXECUTE