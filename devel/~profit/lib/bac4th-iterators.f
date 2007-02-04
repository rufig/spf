\ ѕоследовательный пробег по диапазону чисел. ќт одного до ста,
\ от двух до п€ти, от начала одной €чейки к пам€ти к другой и т.д.

\ —делано: разрешение обратных проходов с отрицательным шагом.
\ ¬опрос: при отрицательном step, должен ли быть отрицательным len?
\ ќтвет: чтобы работали iterateByByteValues и прочие, step не должен 
\ быть отрицательным. ѕоэтому отрицательным должен становитс€ len

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE compiledCode ~profit/lib/bac4th-closures.f

\ –азворот начала и длины дл€ прохода тех же самых значений в обратном пор€дке
: reverse ( start len -- start+len -len ) DUP NEGATE -ROT + 1- SWAP ;

\ —амый простой (и надЄжный) вариант
: iterateBy1  ( start len step --> i \ i <-- i ) PRO LOCAL step step !
OVER + SWAP ?DO
I CONT DROP
step @ +LOOP ;

\ ¬ариант посложнее, без DO LOOP и использовани€ R-стека
: iterateBy2  ( start len step --> i \ i <-- i ) PRO
LOCAL step step !
OVER +
LOCAL end DUP end !
OVER > IF
BEGIN
CONT
step @ +
DUP end @ < 0= UNTIL
ELSE
BEGIN
CONT
step @ -
DUP end @ > 0= UNTIL
THEN DROP ;

\ ¬ариант с динамической генерацией кода цикла
: iterateBy3  ( start len step --> i \ i <-- i ) PRO
OVER >R >R
OVER + ( start end  R: len step )
SWAP R> SWAP ( end step start  R: len )
R> 0 > IF
" LITERAL
BEGIN
[ R@ENTER, ]
LITERAL +
DUP LITERAL < 0= UNTIL
DROP RDROP"
ELSE
" LITERAL
BEGIN
[ R@ENTER, ]
LITERAL -
DUP LITERAL > 0= UNTIL
DROP RDROP"
THEN
STRcompiledCode ENTER CONT ;

\ √лавное слово итерировани€, совершает пару проверок и решает какой из вариантов (2-й или 3-й)
\ будет задействован
: iterateBy ( start len step --> i \ i <-- i )
OVER 0= IF 2DROP DROP RDROP EXIT THEN \ если длина нулева€ или меньше, значит делать больше нам нечего..
2DUP 6 LSHIFT ( 2* 2* 2* 2* 2* 2* ) SWAP ABS >
\ –ешаем: если кол-во итераций в цикле будет меньше чем, скажем 64 (вз€то с потолка),
IF RUSH> iterateBy2 ELSE
\ то циклуем статически,
   RUSH> iterateBy3 THEN ;
\ иначе, если больше чем 64, -- то генерируем цикл и пускаем в нЄм

  \ : iterateBy RUSH> iterateBy1 ;
\ ^-- "разбить в случае аварии" (с) (программы)
\ ≈сли будет глючить в итераторах, можно временно попробовать
\ включить старый, добрый и простой как мычание iterateBy1

: iterateByBytes ( addr u <--> caddr )        1 RUSH> iterateBy ;
\ “олько на первый взгл€д бесмысленно использовать RUSH>
\ ≈сли писать iterateByBytes без безусловного перехода в RUSH> 
\ пришлось бы дл€ сохранени€ линии "успеха" (нырка), ставить 
\ скобки PRO ... CONT и это мало того что бесполезно съело бы 
\ значение на L-стеке, но и замедлило бы итерирование.

: iterateByWords ( addr u <--> waddr )        2 RUSH> iterateBy ;
: iterateByCells ( addr u <--> addr )      CELL RUSH> iterateBy ;
: iterateByDCells ( addr u <--> qaddr ) 2 CELLS RUSH> iterateBy ;

: iterateByByteValues ( addr n <--> char ) PRO       iterateByBytes DUP C@ CONT DROP ;
: iterateByWordValues ( addr n <--> word ) PRO 2*    iterateByWords DUP W@ CONT DROP ;
: iterateByCellValues ( addr n <--> cell )  PRO CELLS iterateByCells DUP @ CONT DROP ;

: times ( n --> \ <-- ) 1 SWAP 1 RUSH> iterateBy ;

/TEST
: printByOne iterateByByteValues DUP EMIT ." _" ;
$> S" abc" printByOne  S" ]" TYPE

$> S" abc" reverse  printByOne  S" ]" TYPE

: 10-3. 10 -3 1 iterateBy DUP . ;
$> 10-3.

: 1-100. 1 100 1 iterateBy DUP . ;
$> 1-100.

: 150-50. 150 -100 1 iterateBy DUP . ;
$> 150-50.

: 0. 150 0 1 iterateBy DUP . ;
$> 0.

: s 100 0 DO +{ 1 200000 1 iterateBy DUP }+ . LOOP ;
\ ResetProfiles s .AllStatistic