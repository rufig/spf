\ 14-10-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ маленькие полезные трюки

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

\ обнулить младший значащий бит числа
: reslbit ( u --> u1 ) DUP 1 - AND ;

\ найти младший значащий бит числа
: getlbit ( u --> mask ) DUP NEGATE AND ;

\ найти младший незначащий бит числа
: getlz ( u --> mask ) DUP 1 + SWAP NEGATE AND ;

\ получить маску для младших нулевых битов числа
: getlzm ( u --> mask ) DUP NEGATE AND 1 - ;

\ получить маску на младший значащий бит и следующие за ним нули
: getlbz ( u --> mask ) DUP 1 - XOR ;

\ распространить младший значащий бит вправо на все нулевые биты
: sellbz ( u --> u1 ) DUP 1 - OR ;

\ установить крайний справа нулевой бит
: setmbit ( u --> u1 ) DUP 1 + OR ;

\ умножение на два
\ : 2* ( u --> <<u ) DUP + ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 0x4234 reslbit 0x4230 <> THROW
      0x2340 getlbit 0x0040 <> THROW
      0x12FF getlz   0x0100 <> THROW
      0x3580 getlzm  0x007F <> THROW
      0x6230 getlbz  0x001F <> THROW
      0x9730 sellbz  0x973F <> THROW
      0xF457 setmbit 0xF45F <> THROW
  S" passed" TYPE
}test
