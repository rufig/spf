\ 2008-03-20 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ поддержка длинных строк

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE SWITCH:  devel\~moleg\lib\util\switch.f
 S" devel\~mOleg\lib\util\bytes.f" INCLUDED

\ распаковка значения числа однобайтовой длины
: 1x7F ( u --> u ) 1 RSHIFT 0x7F AND 1 ;
\ .. двухбайтовой длины
: 2x3FFF ( u --> u ) 2 RSHIFT 0x3FFF AND 2 ;
\ .. трехбайтовой длины
: 3x1FFFFF ( u --> u ) 3 RSHIFT 0x1FFFFF AND 3 ;
\ .. четырехбайтовой длины
: 4xFFFFFFF ( u--> u ) 4 RSHIFT 0xFFFFFFF AND 4 ;

\ вернуть значение u, хранимое по адресу Addr и длину поля данных
: SCNT@ ( addr --> u # )
        @ DUP 7 AND
        SWITCH: NOOP
                1x7F 2x3FFF  1x7F 3x1FFFFF  1x7F 2x3FFF  1x7F 4xFFFFFFF
        ;SWITCH ;

\ сохранить занчение u в память по адресу addr,
\ вернуть кол-во байт, отведенных под хранение числа
: SCNT! ( u addr --> # )
        OVER 0x1FFFFF U> IF SWAP 4 LSHIFT 7 OR SWAP ! 4 EXIT THEN
        OVER 0x3FFF > IF SWAP 3 LSHIFT 3 OR SWAP ! 3 EXIT THEN
        OVER 0x7F > IF SWAP 2 LSHIFT 1 OR SWAP W! 2 EXIT THEN
        SWAP 1 LSHIFT SWAP B! 1 ;

\ вернуть адрес начала и длину поля (строки)
: COUNT ( addr --> addr u ) DUP SCNT@ ROT + SWAP ;

\ компилировать число на вершину кодофайла
: SCNT, ( u --> ) HERE SCNT! ALLOT ;

\ компилировать строку со счетчиком на вершину кодофайла
: S", ( asc # --> ) DUP SCNT, S, ;

\ выложить адрес и начало строки, лежащей в коде за SLITERAL
: (SLITERAL) ( --> asc # )
             R> COUNT 2DUP + 1 + >R ;

\ Скомпилировать литеральную строку, заданную asc # в текущее определение
: SLIT, ( asc # --> ) COMPILE (SLITERAL) S", 0 B, ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ CREATE zzz 0 ,
      0x7F zzz SCNT! 1 <> THROW  zzz SCNT@ 1 <> THROW 0x7F <> THROW
      0x3FFF zzz SCNT! 2 <> THROW  zzz SCNT@ 2 <> THROW 0x3FFF <> THROW
      0x1FFFFF zzz SCNT! 3 <> THROW  zzz SCNT@ 3 <> THROW 0x1FFFFF <> THROW
      0xFFFFFFF zzz SCNT! 4 <> THROW  zzz SCNT@ 4 <> THROW 0xFFFFFFF <> THROW
      zzz DUP COUNT 0xFFFFFFF <> THROW CELL - <> THROW
  S" passed" TYPE
}test

\EOF
сейчас достаточно часто появляется необходимость хранить строки длиной более
255 символов, при этом, как обычно, достаточно много бывает коротких строковых
литералов, на которых не хотелось бы лишние байты тратить.
Конечно же, можно сделать счетчик строк длиной в 4 байта... Но хочется более
изящного решения...
В данной библиотечке длина счетчика строки может составлять 1,2,3,4 байта - в
зависимости от длины строки: 127\16383\2097151\268435455.
Предельная длина строки 2^28-1 = 268435455.
