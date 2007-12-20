\ 18-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ многострочные коментарии в стиле Си
\ с возможностью многократной вложенности

 REQUIRE [IFNOT]  devel\~moleg\lib\util\qif.f

ALSO ROOT DEFINITIONS

   VECT \* IMMEDIATE
   VECT *\ IMMEDIATE

RECENT

\ пропустить весь текст до заключающего слова *\
\ пробел перед *\ обязателен
: _\* ( / ... *\ --> )
      ['] \* >CS
      ['] \* ['] *\ skipto'' EXECUTE ;

\ завершение многострочного коментария
: _*\ ( --> )
      CS@ ['] \* =
      IF CSDrop
         CS@ ['] \* = IF ['] \* ['] *\ skipto'' EXECUTE THEN
       ELSE -1 THROW
      THEN ;

' _\* IS \*
' _*\ IS *\

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------
test{
 \* очень простой \* тест *\ работоспособности *\
  S" passed" TYPE
}test
