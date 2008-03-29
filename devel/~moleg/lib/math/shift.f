\ 24-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ различные сдвиги 32битных чисел

 REQUIRE STREAM[   devel\~mOleg\lib\arrays\stream.f

\ поменять порядо следования байтов в ячейке на обратный порядок
: BSWAP ( U --> U )  STREAM[ x0FC8 C3 ] ;

\ циклически сдвинуть число U на указанное число бит влево
: ROL ( U # --> U ) STREAM[ x8AC8 8B4500 8D6D04 D3C0 C3 ] ;

\ циклически сдвинуть число U на указанное число бит вправо
: ROR ( U # --> U ) STREAM[ x8AC8 8B4500 8D6D04 D3C8 C3 ] ;

\ арифметический сдвиг влево числа U на указанное # число бит
: SAL ( U # --> U ) STREAM[ x8AC8 8B4500 8D6D04 D3F0 C3 ] ;

\ арифметический сдвиг вправо числа U на указанное # число бит
: SAR ( U # --> U ) STREAM[ x8AC8 8B4500 8D6D04 D3F8 C3 ] ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 0x12345678 4 ROL 0x23456781 <> THROW
      0x12345678 4 ROR 0x81234567 <> THROW
      0xF0000000 3 SAR 0xFE000000 <> THROW
      0x70000001 3 SAL 0x80000008 <> THROW
  S" passed" TYPE
}test
