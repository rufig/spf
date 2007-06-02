\ 02-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с памятью - наброски

\ все слова набраны на нижнем регистре, чтобы не путать их с системными
\ следующий код интересен с точки зрения переносимости, а не скорости!!!

REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
REQUIRE TILL     devel\~moleg\lib\util\for-next.f

\ переместить байт из памяти по адресу from в память по адресу to
: (move) ( from to --> from to ) OVER C@ OVER C! ;

\ переместить указанное количество байт # из памяти с начальным
\ адресом from в память с начальным адресом to начиная с младших адресов
: cmovel ( from to # --> ) FOR (move) 1 1 D+ TILL 2DROP ;

\ переместить указанное кол-во байт начиная со старших адресов
: cmove> ( from to # --> ) 1 - DUP DUP FOR D+ (move) -1 -1 NEXT 2DROP 2DROP ;

\ заполнить область памяти начиная с адреса from байтом b # байт памяти
: fill ( b from # --> ) FOR 2DUP C! 1 + TILL 2DROP ;

\ очистить указанное кол-во байт начиная с адреса from в нуль
: erase ( from # --> ) 0 -ROT fill ;

\ сравнить два байта из память
: (comp) ( which with --> which with flag ) OVER C@ OVER C@ = ;

\ сравнение двух строк одинаковой длины на идентичность.
: same ( which with # --> flag )
       FOR (comp)
           IF 1 1 D+
            ELSE 2DROP RDROP FALSE
           EXIT THEN
       TILL 2DROP TRUE ;

\ сравнить две строки на идентичность
: like ( which # with # --> flag )
       ROT OVER =
       IF same
        ELSE DROP 2DROP FALSE
       THEN ;

\ сравнить две asciiz строки на равенство
: equal ( asc1Z asc2Z --> flag )
        BEGIN DUP C@ WHILE
              (comp) WHILE
              1 1 D+
           REPEAT 2DROP FALSE EXIT
        THEN (comp) NIP NIP ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test

