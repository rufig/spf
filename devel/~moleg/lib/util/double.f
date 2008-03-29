\ 28-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с числами двойной длинны

 REQUIRE ADDR     devel\~moleg\lib\util\addr.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f
 REQUIRE ALIAS    devel\~moleg\lib\util\alias.f

\ -- стековые манипуляции ----------------------------------------------------

 ALIAS 2DROP DDROP ( d --> )
 ALIAS 2DUP  DDUP  ( d --> d d )
 ALIAS 2SWAP DSWAP ( da db --> db da )

 ALIAS 2>R   D>R
 ALIAS 2R>   DR>
 ALIAS 2R@   DR@

\ копировать на вершину стека двойное число,
\ находящееся под двойным же на вершине стека
: DOVER ( da db --> da db da ) D>R DDUP DR> DSWAP ;

\ удалить второе двойное число, от вершины стека
: DNIP ( da db --> db ) D>R DDROP DR> ;

\ подложить двойное число, находящееся на вершине стека данных под нижнее d
: DTUCK ( da db --> db da db ) DDUP D>R DSWAP D>R ;

\ -- работа с памятью -------------------------------------------------------

 ALIAS 2@ D@ ( addr --> d )
 ALIAS 2! D! ( d addr --> )

\ компилировать двойное число на вершину кодофайла
: D, ( d --> ) HERE 2 CELLS ALLOT D! ;

\ -- константы, переменные, значения двойной длины --------------------------

\ создать именованую переменную хранящюю число двойной длины
: DVARIABLE ( / name --> ) CREATE 0 0 D, DOES> ;

\ создать именованую константу для числа двойной длины d
: DCONSTANT ( d / name --> ) CREATE D, DOES> D@ ;

\ метод извлечения двойного числа из VALUE переменной двойной длины
: DVAL-CODE ( r: addr --> d ) R> A@ D@ ;

\ метод сохранения двойного числа в VALUE переменную двойной длины
: DTOVAL-CODE ( r: addr d: d --> )
              R> [ CELL CFL + ] LITERAL - A@ D! ;

\ создать именованую VALUE переменную, хранящую число двойной длины
: DVALUE ( d / name --> )
         HEADER
         COMPILE DVAL-CODE HERE >R 0 ,
         COMPILE DTOVAL-CODE ALIGN HERE R> A!
         D, ;

\ метод извлечения двойного числа из VALUE переменной двойной длины
: DUVAL-CODE ( r: addr --> d ) R> A@ TlsIndex@ + D@ ;

\ метод сохранения двойного числа в VALUE переменную двойной длины
: DTOUVAL-CODE ( r: addr d: d --> )
               R> [ CELL CFL + ] LITERAL - A@ TlsIndex@ + D! ;

\ создать пользовательскую именованую переменную двойной длины
: USER-DVAL ( --> d )
            HEADER
            COMPILE DUVAL-CODE USER-HERE ,
            COMPILE DTOUVAL-CODE
            2 CELLS USER-ALLOT ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ 1 DEPTH NIP
       1 2 2DUP DVALUE sample sample D= 0= THROW
       3 4 2DUP TO sample sample D= 0= THROW

       USER-DVAL simple
       4 5 2DUP TO simple  simple D= 0= THROW
       6 7 2DUP DCONSTANT proba proba D= 0= THROW
       7 8 2DUP DVARIABLE test test 2!  test 2@ D= 0= THROW
      DEPTH <> THROW
  S" passed" TYPE
}test
