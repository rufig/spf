\ (c) D. Yakimov [ftech@tula.net]
\ Думаю - получилась неплохая функция хэша
\ И главное быстрая

: ROL  ( u -- u1 )
[ BASE @ HEX
 C1  C, 45  C, 0  C, 1  C,
BASE ! ] ;

: HASH ( addr u -- u1 )
    SWAP 2DUP
    + SWAP
    ?DO
      I C@ XOR ROL
    LOOP
;

\ examples
\ Все хэши будут рассеяны по таблице длиной 25 элементов (в примере)
\ Так хорошо организовывать поиск в больших массивах данных
(
S" dima" HASH 25 MOD .
S" test" HASH 25 MOD .
S" ыловарлывоалоывр" HASH 25 MOD .
)