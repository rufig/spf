\ 02-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ реализация циклов FOR NEXT для СПФ
\ c возможностью использования во время исполнения (т.е при STATE = 0)

 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f
 REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f
 REQUIRE controls devel\~moleg\lib\util\run.f
 REQUIRE R+       devel\~moleg\lib\util\rstack.f

\ начать цикл NOW .. SINCE .. TILL\NEXT
: NOW ( u --> )
      STATE @ IFNOT init: THEN
      3 controls +! COMPILE >R ; IMMEDIATE

\ метка для перехода назад
: SINCE ( --> ) <MARK ; IMMEDIATE

\ начать определения цикла со счетчиком
: FOR ( n --> ) [COMPILE] NOW [COMPILE] SINCE ; IMMEDIATE

\ если счетчик цикла не равен нулю перейти к точке, отмеченной словом FOR
\ иначе удалить счетчик цикла, и выйти из цикла.
: NEXT ( --> )
       ?COMP -3 controls +!
       COMPILE R@ -1 LIT, COMPILE R+ N?BRANCH, COMPILE RDROP
       controls @ IFNOT [COMPILE] ;stop THEN ; IMMEDIATE

\ аналогично NEXT позволяет создавать циклы со счетчиком,
\ только счет ведется до достижения 1, а не 0
: TILL ( --> )
       ?COMP -3 controls +!
       -1 LIT, COMPILE R+ COMPILE R@ N?BRANCH, COMPILE RDROP
       controls @ IFNOT [COMPILE] ;stop THEN ; IMMEDIATE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 3 FOR R@ NEXT 0 <> THROW 1 <> THROW 2 <> THROW 3 <> THROW
      3 FOR R@ TILL 1 <> THROW 2 <> THROW 3 <> THROW
      : summa ( [ a .. z ] # --> d ) 1 - NOW S>D SINCE ROT S>D D+ TILL ;
      11 22 33 44 4 summa THROW 110 <> THROW
   S" passed" TYPE
}test

\EOF пример использования:
     10 FOR R@ . NEXT
     должен выдать ряд чисел от 10 до 0

     в то время, как 10 FOR R@ . TILL
     должен выдать ряд чисел от 10 до 1

дополнительные варианты:

 NOW ... SINCE ... TILL
 NOW ... SINCE ... NEXT

пример:
\ найти сумму чисел a .. z количеством #
: summa ( [ a .. z ] # --> d ) 1 - NOW S>D SINCE ROT S>D D+ TILL ;

10 20 30 40 4 summa D.
