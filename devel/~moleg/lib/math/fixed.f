\ 24-05-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ работа с числами с фиксированной точкой

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE >DIGIT    devel\~moleg\lib\spf_print\pad.f
 REQUIRE UD/       devel\~moleg\lib\math\math.f

       8 VALUE places   \ количество отображаемых символов после запятой

\ получить очередную цифру
: $ ( n --> n*base ) BASE @ UM* >DIGIT KEEP ;

\ преобразовать число
: $S ( n --> )
     places HLD @ OVER CHARS - HLD !
     HLD @ >R
      >R BEGIN R@ WHILE $ -1 R+ REPEAT RDROP DROP
     R> HLD ! ;

\ преобразовать число с фиксированной точкой.
: (N.P) ( p n --> asc # )
        DUP >R DABS SWAP 1 + <# $S comma HOLD 0 #S R> SIGN #> ;

\ распечатать число с фиксированной точкой
: N.P ( n p --> ) (N.P) TYPE SPACE ;

\ преобразовать строку в положительное число после десятичной точки
: >FRACT ( asc # --> p TRUE | FALSE )
         0 >R  SWAP char - TUCK +
         BEGIN 2DUP <> WHILE
               DUP C@ BASE @ DIGIT WHILE
               R> SWAP BASE @ UD/ DROP >R
             char -
           REPEAT 2DROP RDROP FALSE EXIT
         THEN 2DROP R> TRUE ;

\ преобразовать строку вида " 123,345" в число с фиксированной точкой
: pNUMBER ( asc # --> n p TRUE | FALSE )
          0 0 2SWAP >NUMBER
          DUP IF OVER C@ comma =
                 IF SKIP1 >FRACT
                    IF NIP SWAP TRUE EXIT THEN
                 THEN
              THEN
          2DROP 2DROP FALSE ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ S" 12,345" pNUMBER 0= THROW
         1481763717 12 D= 0= THROW
  S" passed" TYPE
}test

\EOF
числа с фиксированной точкой. Одна ячейка на стеке данных отводится под
целую часть числа, вторая под дробную. Число с фиксированной точкой
распознается по разделительной запятой: 0,123 1,345 и тому подобное.
В стандартный 4байтный cell влазит около 9 десятичных разрядов - переменная
places определяет сколько чисел после запятой будет отбражаться.
Библиотечка корректно работает и с 10 и с 16 числами.

