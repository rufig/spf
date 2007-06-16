\ 06-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ полезные при работе со строками слова

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f

?DEFINED char  1 CHARS CONSTANT char

\ вернуть строку нулевой длинны
: EMPTY" ( --> asc # ) S" " ;

\ преобразовать символ в строку, содержащую один символ
: Char>Asc ( char --> asc # ) SYSTEM-PAD TUCK C! 0 OVER char + C! char ;

\ укоротить строку asc # на u символов от начала
: SKIPn ( asc # u --> asc+u #-u ) OVER MIN TUCK - >R + R> ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ CHAR Ё Char>Asc S" Ё" COMPARE 0<> THROW
      S" aksdjhf" 3 SKIPn S" djhf" COMPARE 0<> THROW
  S" passed" TYPE
}test
