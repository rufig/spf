\ Создание серии констант
\ enum{ , zero , one DROP 5 , five }

VOCABULARY EnumSupport
GET-CURRENT ALSO EnumSupport DEFINITIONS

\ Создает очередную константу
: , ( n -- n+1 )  DUP CONSTANT 1+ ;

\ Заканчивает создание констант
: } ( n -- )  DROP PREVIOUS ;

SET-CURRENT

\ Начинает создание серии констант, кладет 0 на стек
: enum{
  0
  ALSO EnumSupport
;
PREVIOUS
