\ 31-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с байтами
\ С@ С! C, - остается за символами, разрядность которых может быть 16 бит

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

N?DEFINED B! \EOF если уже есть поддержка

 REQUIRE ALIAS    devel\~moleg\lib\util\alias.f

0xFEFF SP@ C@ 256 > NIP \ если символы двойной длины
 ADMIT CR S" Please redefine B@ B! B, becouse Chars are wide" TYPE -1 THROW

?DEFINED B@  ALIAS C@ B@ \ извлечь байт, хранимый по указанному адресу
?DEFINED B!  ALIAS C! B! \ сохранить байт по указанному адресу
?DEFINED B,  ALIAS C, B, \ компилировать байт на вершину кодофайла.

?DEFINED test{ \EOF -- тестовая секция -----------------------------------------

test{
  CREATE aaa HERE B,
  aaa B@ aaa 0xFF AND <> THROW
  123456 DUP aaa B! aaa B@ SWAP 0xFF AND <> THROW
S" passed" TYPE
}test

\EOF
в связи с тем, что разрядность символьных данных может не совпадать с
разрядностью минимально адресуемой ячейки памяти ( обычно байта), а так
же существуют процессорные архитектуры, не умеющие адресовать байты
(адресуют данные более крупной разрядности) видится логичным выделить
набор слов, работающих с байтами в отдельный лексикон с другим префиксом: B
а не C.

\ 05-11-2007
для определения набора слов работающего в памяти с байтами использованы алиасы