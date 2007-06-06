\ 19-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ неименованные накопительные буфера

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE R+       devel\~moleg\lib\util\stackadd.f

  \ структура буфера
  0 CELL -- off-place     \ позиция первого свободного символа в буфере
    CELL -- off-limit     \ предельный размер буфера
    0    -- off-space     \ начало пространства буфера
  CONSTANT /buffer        \ размер записи буфера

\ создать буфер указанной длины
: Buffer ( # --> buf )
         /buffer + 0x1000 ROUND  DUP ALLOCATE THROW
         0 OVER off-place !  >R /buffer - R@ off-limit ! R> ;

\ вернуть адрес начала буфера и его заполненую длину
: Buffer> ( buf --> asc # ) DUP off-space SWAP off-place @ ;

\ добавить содержимое строки asc # в буфер
: >Buffer ( asc # buf --> flag )
          2DUP off-place @ +
          OVER off-limit @ OVER >
          IF OVER off-place change
             + off-space SWAP CMOVE
             TRUE
           ELSE 2DROP 2DROP
             FALSE
          THEN ;

\ очистить содержимое буфера.
: Clean ( buf --> ) 0 SWAP off-place ! ;

\ освободить память занимаемую буфером
: Retire ( buf --> ) FREE THROW ;


?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока просто проверка собираемости

  S" passed" TYPE
}test
\EOF -- тестовая секция -----------------------------------------------------

1 Buffer VALUE zzzz

S" s" BEGIN 2DUP zzzz >Buffer WHILE REPEAT 2DROP
zzzz Buffer> SWAP . .
zzzz Buffer> DUMP
