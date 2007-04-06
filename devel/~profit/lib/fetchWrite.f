REQUIRE /TEST ~profit/lib/testing.f

\ последовательное чтение и запись в пам€ть с бегунком, хран€щим адрес текущей €чейки
\ ѕеременные-бегунки -- хороша€ замена дл€ регистра-аккумул€тора с функци€ми @+ !+

: fetchByte ( addr -- b ) DUP 1+!  @ 1- C@ ;
: writeByte ( n addr -- ) TUCK @ C!  1+! ;

: fetchWord ( addr -- b ) 2 OVER +!  @ 2 - W@ ;
: writeWord ( n addr -- ) TUCK @ W!  2 SWAP +! ;

: fetchCell ( addr -- b ) CELL OVER +!  @ CELL- @ ;
: writeCell ( n addr -- ) TUCK @ !  CELL SWAP +! ;


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