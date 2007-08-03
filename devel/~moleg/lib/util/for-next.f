\ 02-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ реализация циклов FOR NEXT для СПФ
\ c возможностью использования во время исполнения (т.е при STATE = 0)

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f
 REQUIRE IFNOT    devel\~moleg\lib\util\ifnot.f
 REQUIRE controls devel\~moleg\lib\util\run.f

\ начать определения цикла со счетчиком
: FOR ( n --> )
      STATE @ IFNOT init: THEN 3 controls +!
      <MARK COMPILE >R  ; IMMEDIATE

\ если счетчик цикла не равен нулю перейти к точке, отмеченной словом FOR
\ иначе, продолжить выполнение программы со слова за NEXT
: NEXT ( --> )
       ?COMP -3 controls +!
       COMPILE R> COMPILE DUP 1 LIT, COMPILE - COMPILE SWAP
       N?BRANCH, COMPILE DROP
       controls @ IFNOT [COMPILE] ;stop THEN ; IMMEDIATE

\ аналогично NEXT позволяет создавать циклы со счетчиком,
\ только счет ведется до достижения 1, а не 0
: TILL ( --> )
       ?COMP -3 controls +!
       COMPILE R> 1 LIT, COMPILE - COMPILE DUP
       N?BRANCH, COMPILE DROP
       controls @ IFNOT [COMPILE] ;stop THEN ; IMMEDIATE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 3 FOR R@ NEXT 0 <> THROW 1 <> THROW 2 <> THROW 3 <> THROW
      3 FOR R@ TILL 1 <> THROW 2 <> THROW 3 <> THROW
   S" passed" TYPE
}test

\EOF пример использования:
     10 FOR R@ . NEXT
     должен выдать ряд чисел от 10 до 0

     в то время, как 10 FOR R@ . TILL
     должен выдать ряд чисел от 10 до 1
