\ 18-12-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ многострочные коментарии в стиле Си
\ с возможностью многократной вложенности

 REQUIRE ROOT      devel\~moleg\lib\util\root.f
 REQUIRE sFindIn   devel\~moleg\lib\newfind\search.f
 REQUIRE CS>       devel\~moleg\lib\util\csp.f
 REQUIRE ALIAS     devel\~moleg\lib\util\alias.f

 ?DEFINED IS   ALIAS TO IS

ALSO ROOT DEFINITIONS

   VECT \* IMMEDIATE
   VECT *\ IMMEDIATE

RECENT

\ искать слово в словаре ROOT, если найдено, вернуть его wid
\ найденное слово должно быть immediate
: qfnd ( --> wid | 0 )
       SP@ >R
       NEXT-WORD [ ALSO ROOT CONTEXT @ PREVIOUS ] LITERAL 1 sFindIn
       imm_word = IFNOT R> SP! FALSE ELSE RDROP THEN ;

\ пропустить все слова во входном потоке
\ вплоть до одного из двух указанных 'a 'b
: skipto'' ( 'a 'b / .... a|b --> ' )
           2>R BEGIN 2R@ qfnd TUCK = WHILENOT \ ?a
                                   = WHILENOT \ ?b
                 REPEAT RDROP R> EXIT
               THEN 2DROP R> RDROP ;

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
