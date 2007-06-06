\ 28-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с числами двойной длинны

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE COMPILE  devel\~moleg\lib\util\compile.f
 REQUIRE ADDR     devel\~moleg\lib\util\addr.f

\ -- стековые манипуляции ----------------------------------------------------

\ удалить двойное число с вершины стека данных
: DDROP ( d --> ) 2DROP ;

\ копировать двойное число d на вершине стека данных
: DDUP ( d --> d d ) 2DUP ;

\ поменять местами два двойных числа на вершине стека данных местами
: DSWAP ( da db --> db da ) 2SWAP ;

\ копировать на вершину стека двойное число,
\ находящееся под двойным же на вершине стека
: DOVER ( da db --> da db da ) 2>R 2DUP 2R> 2SWAP ;

\ удалить второе двойное число, от вершины стека
: DNIP ( da db --> db ) 2>R 2DROP 2R> ;

\ подложить двойное число, находящееся на вершине стека данных под нижнее d
: DTUCK ( da db --> db da db ) 2DUP 2>R 2SWAP 2>R ;

\ -- работа с памятью -------------------------------------------------------

\ извлечь число двойной длины из памяти по указанному адресу
: D@ ( addr --> d ) 2@ ;

\ сохранить число двойной длины в память по указаному адресу
: D! ( d addr --> ) 2! ;

\ компилировать двойное число на вершину кодофайла
: D, ( d --> ) HERE 2 CELLS ALLOT D! ;

\ -- константы, переменные, значения двойной длины --------------------------

\ создать именованую переменную хранящюю число двойной длины
: DVARIABLE ( / name --> ) CREATE 0 0 D, DOES> ;

\ создать именованую константу для числа двойной длины d
: DCONSTANT ( d / name --> ) CREATE D, DOES> D@ ;

\ метод извлечения двойного числа из VALUE переменной двойной длины
: DVAL-CODE ( r: addr --> d ) R> A@ 2@ ;

\ метод сохранения двойного числа в VALUE переменную двойной длины
: DTOVAL-CODE ( r: addr d: d --> )
              R> [ CELL CFL + ] LITERAL - A@ 2! ;

\ создать именованую VALUE переменную, хранящую число двойной длины
: DVALUE ( d / name --> )
         HEADER
         COMPILE DVAL-CODE HERE >R 0 ,
         COMPILE DTOVAL-CODE ALIGN HERE R> A!
         D, ;

\ метод извлечения двойного числа из VALUE переменной двойной длины
: DUVAL-CODE ( r: addr --> d ) R> A@ TlsIndex@ + 2@ ;

\ метод сохранения двойного числа в VALUE переменную двойной длины
: DTOUVAL-CODE ( r: addr d: d --> )
               R> [ CELL CFL + ] LITERAL - A@ TlsIndex@ + 2! ;

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


