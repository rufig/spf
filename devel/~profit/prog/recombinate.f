\ Слово recombinateStack, компилирующее стековую комбинацию, через
\ посредник -- стек возвратов.
\ Изначальной позицией считается n ... 3 2 1
\ Обсуждение: http://fforum.winglion.ru/viewtopic.php?p=3479#3479 и
\ http://fforum.winglion.ru/viewtopic.php?t=334

0 VALUE maxElem

SET-OPT

: recombinateStack ( "word" -- ) ?COMP
0 TO maxElem
NextWord DUP >R ( addr u )
OVER + SWAP DO
I C@ [CHAR] 0 - ( num )
DUP maxElem MAX TO maxElem
1- LIT,
POSTPONE PICK POSTPONE >R
LOOP

maxElem 0 DO POSTPONE DROP LOOP

R> 0 DO POSTPONE R> LOOP
; IMMEDIATE

\EOF
: SWAP recombinateStack 21 ;

: 1234->2143 ( 4 3 2 1 --> 3 4 1 2 ) recombinateStack 3412 ;

: s 1234->2143 ;

: megaDROP ( 7 6 5 4 3 2 1 --> 7 ) recombinateStack 7 ;

: r ( 3 2 1 --> 2 3 ) recombinateStack 32 ;


REQUIRE SEE lib/ext/disasm.f
CR CR .( SWAP is:)
SEE SWAP

CR CR .( 1234->2143 is:)
SEE 1234->2143

CR CR .( megaDROP is:)
SEE megaDROP

CR CR .( r is:)
SEE r