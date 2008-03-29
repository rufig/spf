\ 2008-03-21 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ хранение строк со счетчиком переменной длины

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 S" devel\~mOleg\lib\util\bytes.f" INCLUDED
 REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f

  \ максимальное кол-во байт, отводимое под счетчик строки
 4 CONSTANT SCNT# ( --> const )

\ сохранить значение счетчика строки u, вернуть его длину
: SCNT! ( u addr --> # )
        >R 0x80 OVER U> IF 1 LSHIFT R> B! 1 EXIT THEN
           0x4000 OVER U> IF 2 LSHIFT 1 OR R> W! 2 EXIT THEN
        2 LSHIFT 3 OR R> ! 4 ;

\ извлечь значение счетчика строки u и его длину #
: SCNT@ ( addr --> u # )
        @ DUP 1 AND IFNOT 1 RSHIFT 0x7F AND 1 EXIT THEN
       DUP 2 AND IFNOT 2 RSHIFT 0x3FFF AND 2 EXIT THEN
       2 RSHIFT 4 ;

\ вернуть адрес начала и длину поля (строки)
: COUNT ( addr --> addr u ) DUP SCNT@ ROT + SWAP ;

\ компилировать число на вершину кодофайла
: SCNT, ( u --> ) HERE SCNT! ALLOT ;

\ компилировать строку со счетчиком на вершину кодофайла
: S", ( asc # --> ) DUP SCNT, S, ;

\ выложить адрес и начало строки, лежащей в коде за SLITERAL
: (SLITERAL) ( r: addr --> asc # ) R> COUNT 2DUP + 1 + >R ;

\ Скомпилировать литеральную строку, заданную asc # в текущее определение
: SLIT, ( asc # --> ) COMPILE (SLITERAL) S", 0 B, ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ CREATE zzz 0 ,
      0x7F zzz SCNT! 1 <> THROW  zzz SCNT@ 1 <> THROW 0x7F <> THROW
      0x3FFF zzz SCNT! 2 <> THROW  zzz SCNT@ 2 <> THROW 0x3FFF <> THROW
      0x1FFFFF zzz SCNT! 4 <> THROW  zzz SCNT@ 4 <> THROW 0x1FFFFF <> THROW
      0xFFFFFFF zzz SCNT! 4 <> THROW  zzz SCNT@ 4 <> THROW 0xFFFFFFF <> THROW
      zzz DUP COUNT 0xFFFFFFF <> THROW CELL - <> THROW
  S" passed" TYPE
}test

\EOF сейчас достаточно часто появляется необходимость хранить строки длиной
более 255 символов, при этом, как обычно, достаточно много бывает коротких
строковых литералов, на которых не хотелось бы лишние байты тратить.
Конечно же, можно сделать счетчик строк длиной в 4 байта... Но хочется более
изящного решения...
В данной библиотечке длина счетчика строки может составлять 1,2,4 байта - в
зависимости от длины строки: 127\16383\2^30-1
Предельная длина строки 2^30-1 = 1073741823 байт
