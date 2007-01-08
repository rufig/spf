REQUIRE /TEST ~profit/lib/testing.f
REQUIRE LOCAL ~profit/lib/static.f
REQUIRE CONT ~profit/lib/bac4th.f
REQUIRE compiledCode ~profit/lib/bac4th-closures.f

: iterateBy1  ( start len step --> i \ i <-- i ) PRO LOCAL step step !
OVER + SWAP ?DO
I CONT DROP
step @ +LOOP ;

: iterateBy2  ( start len step --> i \ i <-- i ) PRO LOCAL step step !
OVER + 1- LOCAL end end !
BEGIN
CONT
step @ +
DUP end @ > UNTIL
DROP ;

\ Ќадо это потом переопределить через compiledCode пущей скорости ради

\ ѕереписал, должно летать:

: iterateBy3  ( start len step --> i \ i <-- i ) PRO
OVER 0 > 0= IF 2DROP EXIT THEN \ если длина нулева€ или меньше, значит делать больше нам нечего..
>R
OVER + 1- ( start end  R: step )
SWAP R> SWAP ( end step start )
" PRO
( start ) LITERAL
BEGIN [ 2SWAP ] ( трах-ти-би-дох, ти-би-дох!.. Ќу кто сказал что control-flow стек == стек параметров -- это хорошо !.?. )
CONT
( step ) LITERAL +
DUP ( end ) LITERAL > UNTIL
DROP "
STRcompiledCode ENTER CONT ;

\ Ќо не только не летает, но оказываетс€ *медленнее* чем DO LOOP !

\ ’орошо, попробуем уже хаками:
: t  ROT >R 2SWAP R> ;

: iterateBy4  ( start len step --> i \ i <-- i )
OVER 0 > 0= IF 2DROP EXIT THEN \ если длина нулева€ или меньше, значит делать больше нам нечего..
>R
OVER + 1- ( start end  R: step )
SWAP R> SWAP ( end step start )
R> SWAP ( end step succ-xt start )

"
( start ) LITERAL
BEGIN [ t ]
( succ-xt ) [ COMPILE, ]
( step ) LITERAL +
DUP ( end ) LITERAL > UNTIL
DROP "
STRcompiledCode ( xt )  >R ;

\ “ож самое... “ормоза...

: iterateBy ( start len step --> i \ i <-- i ) PRO
2DUP 6 LSHIFT ( 2* 2* 2* 2* 2* 2* ) <
\ –ешаем: если кол-во итераций в цикле будет меньше чем, скажем 64 (вз€то с потолка),
IF iterateBy2 CONT EXIT THEN
\ то циклуем статически,
   iterateBy4 CONT ;
\ иначе, если больше чем 64, -- то генерируем цикл и пускаем в нЄм

: iterateByBytes ( addr u <--> caddr ) PRO 1 iterateBy CONT ;
: iterateByWords ( addr u <--> waddr ) PRO 2 iterateBy CONT ;
: iterateByCells ( addr u <--> addr )  PRO CELL iterateBy CONT ;
: iterateByDCells ( addr u <--> qaddr ) PRO 2 CELLS iterateBy CONT ;

: iterateByByteValues ( addr n <--> caddr ) PRO       iterateByBytes DUP C@ CONT DROP ;
: iterateByWordValues ( addr n <--> waddr ) PRO 2*    iterateByWords DUP W@ CONT DROP ;
: iterateByCellValues ( addr n <--> addr )  PRO CELLS iterateByCells DUP @ CONT DROP ;

/TEST
: r S" abc" iterateByByteValues DUP EMIT ." _" ;
r

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