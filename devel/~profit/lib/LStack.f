REQUIRE /TEST ~profit/lib/testing.f

CREATE L0   \ начало стека
100 CELLS ALLOT  \ занять 100 ячеек
VARIABLE LP    \ указатель вершины стека

: LEMPTY  L0  LP ! ; \ установить указатель стека на дно
: LDEPTH ( -- d ) LP @ L0 -  CELL / ; \ вовращает глубину стека
LEMPTY  

: LUNDROP CELL  LP +! ;
: LDROP CELL NEGATE LP +! ;
: L@ ( -- n ) LP @ CELL- @ ;  \ взять с L-стека, глубина стека не меняется

: L> ( -- n ) \ снять с L-стека
L@  LDROP ;

: >L ( n -- ) \ положить на L-стек
LP @ !  LUNDROP ;

/TEST
>> 1 >L  2 >L  L> . L> .