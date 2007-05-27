REQUIRE /TEST ~profit/lib/testing.f

\ TODO: Почему на таких простых словах стопарится оптимизатор?..

\ Последовательное чтение и запись в память с бегунком, хранящим адрес текущей ячейки
\ Переменные-бегунки -- хорошая замена для регистра-аккумулятора с функциями @+ !+

\ Бегунками можно (даже нужно) делать локальные переменные, только тогда нужно
\ использовать их слегка не так как обычно (см. пример move), чтобы локальлыне 
\ переменные были обычными, а не VALUE-переменными.

: fetchByte ( addr -- b ) DUP  @ C@ SWAP 1+! ;
: writeByte ( n addr -- ) TUCK @ C!      1+! ;

: fetchWord ( addr -- b ) DUP  @ W@ SWAP 2 SWAP +! ;
: writeWord ( n addr -- ) TUCK @ W!      2 SWAP +! ;

: fetchCell ( addr -- b ) DUP  @ W@ SWAP CELL SWAP +! ;
: writeCell ( n addr -- ) TUCK @ !       CELL SWAP +! ;


/TEST

CREATE m 10 ALLOT

VARIABLE a

m a !
1 a writeByte
2 a writeByte
3 a writeByte



m a !
a fetchByte .
a fetchByte .
a fetchByte .

REQUIRE { lib/ext/locals.f
REQUIRE FOR ~profit/lib/for-next.f

: move ( src len dest -- ) { \ [ CELL ] A [ CELL ] B -- }
B !  SWAP A ! 0 DO 
A fetchByte DUP CR EMIT ( x ) B writeByte
LOOP ;

CREATE tmp 1000 ALLOT ALIGN
: r S" check00" tmp move ;
r
tmp 20 DUMP

lib\ext\disasm.f
SEE writeByte
SEE writeWord
VARIABLE s
:NONAME s writeByte ; REST
:NONAME s writeWord ; REST