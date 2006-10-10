\ последовательное чтение и запись в память с бегунком, хранящим адрес текущей ячейки

: fetchByte ( addr -- b ) DUP @ C@ SWAP  1+! ;
: writeByte ( n addr -- ) TUCK @ C!  1+! ;

: fetchWord ( addr -- b ) DUP @ W@ SWAP  2 SWAP +! ;
: writeWord ( n addr -- ) TUCK @ W!  2 SWAP +! ;

: fetchCell ( addr -- b ) DUP @ @ SWAP CELL SWAP +! ;
: writeCell ( n addr -- ) TUCK @ !  CELL SWAP +! ;


\EOF

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

\EOF
REQUIRE { ~ac/lib/locals.f
REQUIRE FOR ~profit/lib/for-next.f

: move ( src len dest -- ) { \ [ CELL ] A [ CELL ] B -- }
B !  SWAP A ! 0 DO 
A fetchByte DUP CR EMIT ( x ) B writeByte
LOOP ;

CREATE tmp 1000 ALLOT ALIGN
: r S" check00" tmp move ;
r
tmp 20 DUMP