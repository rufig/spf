\ http://fforum.winglion.ru/viewtopic.php?p=5325#5325
\ Отладка двух рекурсивных функций


: FIB1 ( n -- n' ) DUP 1 >        IF
DUP 1- RECURSE SWAP 2 - RECURSE + ELSE
DROP 1                            THEN ; 

: FIB2 ( n -- n' ) 
DUP 2 < 
IF 
DROP 1 
ELSE 
DUP 
2 - RECURSE 
SWAP 
1 - RECURSE 
+ 
THEN 
;


:NONAME 10 0 DO CR I FIB1 .  I FIB2 . LOOP ; EXECUTE

0 VALUE rs
10000 CELLS CONSTANT rLen

CREATE ss 10000 ALLOT
HERE DUP S0 ! SP!

: megaRS ( xt -- )
rLen ALLOCATE THROW TO rs
R0 @ RP@
\ R0 @ RP@ - CELL / . R@ . ." |"
rs rLen + DUP RP! R0 !
2>R
EXECUTE
\ ." bla-bla" KEY DROP
2R> RP! R0 !
\ R0 @ RP@ - CELL / . R@ . KEY DROP
rs FREE THROW ;

: ACK ( x y -- ack*x*y )
OVER 0=                       IF
NIP 1+                        ELSE   \ f(0,y)=y+1             (1)
DUP 0=               IF
DROP 1- 1 RECURSE    ELSE            \ f(x,0)=f(x-1,1)        (2)
1- OVER SWAP RECURSE                 \ f(x,y)=f(x-1,f(x,y-1)) (3)
SWAP 1- SWAP RECURSE THEN     THEN ;

REQUIRE SEE lib/ext/disasm.f
\ SEE ACK

: ACK1 ['] ACK megaRS ;

\ 0 0 ACK1 . \ (1)
\ 3 0 ACK1 . \ (2)
3 7 ACK . KEY DROP