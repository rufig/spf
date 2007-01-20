\ ѕоследовательный пробег по диапазону чисел. ќт одного до ста,
\ от двух до п€ти, от начала одной €чейки к пам€ти к другой.

\ TODO: –азрешить обратные проходы с отрицательным шагом
\ ¬опрос: при отрицательном step, должен ли быть отрицательным len?
\ ќтвет. чтобы работали iterateByByteValues и прочие step не должен 
\ быть отрицательным. ѕоэтому отрицательным
\ должен становитс€ len

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE compiledCode ~profit/lib/bac4th-closures.f

: reverse ( start len -- start+len -len ) DUP NEGATE -ROT + 1- SWAP ;

: iterateBy1  ( start len step --> i \ i <-- i ) PRO LOCAL step step !
OVER + SWAP ?DO
I CONT DROP
step @ +LOOP ;

: iterateBy2  ( start len step --> i \ i <-- i ) PRO LOCAL step step ! 
OVER +
2DUP = IF 2DROP EXIT THEN
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

\ Ќадо это потом переопределить через compiledCode пущей скорости ради

\ ѕереписал, должно летать:

: iterateBy3  ( start len step --> i \ i <-- i ) PRO
OVER 0 > 0= IF 2DROP EXIT THEN \ если длина нулева€ или меньше, значит делать больше нам нечего..
>R
OVER + ( start end  R: step )
SWAP R> SWAP ( end step start )
" PRO
LITERAL
BEGIN [ 2SWAP ]
CONT
LITERAL +
DUP LITERAL < 0= UNTIL
DROP "
STRcompiledCode ENTER CONT ;

\ Ќо не только не летает, но оказываетс€ *медленнее* чем DO LOOP !

\ ’орошо, попробуем уже хаками:
: iterateBy4  ( start len step --> i \ i <-- i )
OVER 0 > 0= IF 2DROP EXIT THEN \ если длина нулева€ или меньше, значит делать больше нам нечего..
>R
OVER + ( start end  R: step )
SWAP R> SWAP ( end step start )
R> SWAP ( end step succ-xt start )

"
LITERAL
BEGIN [ ROT >R 2SWAP R> ]
[ COMPILE, ]
LITERAL +
DUP LITERAL < 0= UNTIL
DROP "
STRcompiledCode ( xt )  >R ;

\ “ож самое... “ормоза...

: iterateBy ( start len step --> i \ i <-- i )
2DUP 6 LSHIFT ( 2* 2* 2* 2* 2* 2* ) SWAP ABS >
\ –ешаем: если кол-во итераций в цикле будет меньше чем, скажем 64 (вз€то с потолка),
IF RUSH> iterateBy2 ELSE
\ то циклуем статически,
   RUSH> iterateBy4 THEN ;
\ иначе, если больше чем 64, -- то генерируем цикл и пускаем в нЄм

\ : iterateBy RUSH> iterateBy1 ;

: iterateByBytes ( addr u <--> caddr )        1 RUSH> iterateBy ;
: iterateByWords ( addr u <--> waddr )        2 RUSH> iterateBy ;
: iterateByCells ( addr u <--> addr )      CELL RUSH> iterateBy ;
: iterateByDCells ( addr u <--> qaddr ) 2 CELLS RUSH> iterateBy ;

: iterateByByteValues ( addr n <--> caddr ) PRO       iterateByBytes DUP C@ CONT DROP ;
: iterateByWordValues ( addr n <--> waddr ) PRO 2*    iterateByWords DUP W@ CONT DROP ;
: iterateByCellValues ( addr n <--> addr )  PRO CELLS iterateByCells DUP @ CONT DROP ;

/TEST
: printByOne iterateByByteValues DUP EMIT ." _" ;
>> S" abc" printByOne

: 10-3. 10 -3 1 iterateBy DUP . ;
>> 10-3.

: printByOneReverse reverse iterateByByteValues DUP EMIT ." _" ;
>> S" abc" printByOneReverse

: s 100 0 DO +{ 1 200000 1 iterateBy DUP }+ . LOOP ;
\ ResetProfiles s .AllStatistic

\  ¬ремени работы слова s на разных вариантах iterateBy

\  1 (DO LOOP) __________________________________________________ 43,394,789,947
\  2 (STRcompiledCode и CONT) ___________________________________ 56,321,774,280
\  3 (STRcompiledCode с пр€мым внедрением вызова кода успеха) ___ 50,266,760,943
\  3 c DIS-OPT (sic!) и ~pinka/spf/quick-swl.f __________________ 10,369,798,311
\  _____________________________________________________________________________
\  »тог: чЄрти что

\ ¬идимо дело в зан€тии пам€ти через WINAPI_функцию ALLOCATE глубоко внутри 
\ STRcompiledCode

\ Ќет дело не в ALLOCATE, дело в EVALUATE