\ 2008-06-16 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ описание структур с отрицательными полями

  REQUIRE KEEPS devel\~moleg\lib\spf_print\pad.f

\ определить размер структуры с учетом того, что она может расти вниз
\ или начинаться с отрицательного положения
: ?Size ( disp disp --> size ) 2DUP MAX -ROT MIN - ;

\ начать описание структуры с именем name
\ n - число, от которого отсчитывается смещение поля
: struct ( n / name --> addr n n )
         NextWord <| [CHAR] / KEEP KEEPS |>
         CREATED HERE 0 , SWAP DUP
         DOES> @ ;

\ создать поле длиной # байт
: fld ( disp # --> disp ) NextWord CREATED OVER , + DOES> @ + ;

\ закончить описание структуры
: /struct ( addr u disp --> ) ?Size SWAP ! ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ -5 struct sample
            0 fld off_a
            2 fld off_b
            4 fld off_c
            1 fld off_d
       /struct

       /sample 7 <> THROW  \ неверно подсчитан размер
       3 off_a -2 <> THROW \ неверно подсчитано смещение поля
       5 off_b 0 <> THROW
       0 off_c -3 <> THROW
       2 off_d 3 <> THROW
  S" passed" TYPE
}test

\EOF - пример описания структуры с отрицательными полями
 -20 struct sample
 0 fld aaaa
10 fld bbbb
20 fld cccc
 0 fld dddd
/struct

в текущем словаре будет создано 5 слов: aaaa bbbb cccc dddd /sample
последнее слово будет содержать размер структуры
