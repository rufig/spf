\ 31-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с адресами

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

        \ сколько минимально адресуемых единиц занимает адресная ссылка
        CELL CONSTANT ADDR

\ извлечь адрес, хранимый по указанному адресу
: A@ ( addr --> addr ) @ ;

\ сохранить адресную ссылку по указанному адресу
: A! ( addr addr --> ) ! ;

\ компилировать адресную ссылку на вершину кодофайла.
: A, ( addr --> ) , ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{
  CREATE aaa HERE A,
  aaa A@ aaa <> THROW
  123456 DUP aaa A! aaa A@ <> THROW
S" passed" TYPE
}test