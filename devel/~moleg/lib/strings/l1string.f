\ 2008-03-21 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ хранение строк со счетчиком переменной длины

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE SWITCH:  devel\~moleg\lib\util\switch.f
 S" devel\~mOleg\lib\util\bytes.f" INCLUDED

\ методы извлечения числа
: 1byte ( n --> u # ) 1 RSHIFT 0x7F AND 1 ;
: 2byte ( n --> u # ) 2 RSHIFT 0x3FFF AND 2 ;
: 4byte ( n --> u # ) 2 RSHIFT 4 ;

\ извлечь упакованное число u из памяти по адресу addr
\ вернуть количество байт в числе
: X@ ( addr --> u # )
     @ DUP 3 AND SWITCH: NOOP 1byte 2byte 1byte 4byte ;SWITCH ;

\ сохранить упакованное число u в память по адресу addr
\ вернуть количество байт в числе
: X! ( u addr --> # )
     >R 0x80 OVER U> IF 1 LSHIFT R> B! 1 EXIT THEN
        0x4000 OVER U> IF 2 LSHIFT 1 OR R> W! 2 EXIT THEN
        2 LSHIFT 3 OR R> ! 4 ;

\ вернуть адрес начала и длину поля (строки)
: COUNT ( addr --> addr u ) DUP X@ ROT + SWAP ;

\ компилировать число на вершину кодофайла
: X, ( u --> ) HERE X! ALLOT ;

\ компилировать строку со счетчиком на вершину кодофайла
: S", ( asc # --> ) DUP X, S, ;

\ выложить адрес и начало строки, лежащей в коде за SLITERAL
: (SLITERAL) ( r: addr --> asc # ) R> COUNT 2DUP + 1 + >R ;

\ Скомпилировать литеральную строку, заданную asc # в текущее определение
: SLIT, ( asc # --> ) COMPILE (SLITERAL) S", 0 B, ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ CREATE zzz 0 ,
      0x7F zzz X! 1 <> THROW  zzz X@ 1 <> THROW 0x7F <> THROW
      0x3FFF zzz X! 2 <> THROW  zzz X@ 2 <> THROW 0x3FFF <> THROW
      0x1FFFFF zzz X! 4 <> THROW  zzz X@ 4 <> THROW 0x1FFFFF <> THROW
      0xFFFFFFF zzz X! 4 <> THROW  zzz X@ 4 <> THROW 0xFFFFFFF <> THROW
      zzz DUP COUNT 0xFFFFFFF <> THROW CELL - <> THROW
  S" passed" TYPE
}test
