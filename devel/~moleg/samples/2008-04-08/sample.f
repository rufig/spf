\ 2008-04-08 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ удвоение уникальных цифр строки
\ решение задачки для конкурса http://fforum.winglion.ru/viewtopic.php?t=1228

  10 CONSTANT basedigits

\ по количеству значащих цифр
 CREATE Сiphers basedigits CELLS ALLOT

\ стираем содержимое массива
: init ( --> ) Сiphers basedigits CELLS ERASE ;

\ найти поле в массиве, соответствующее цифре
: cstat ( char --> ) [CHAR] 0 - CELLS Сiphers + ;

\ подготовили массив
: prep ( asc # --> )
       OVER + SWAP
       BEGIN 2DUP <> WHILE
             DUP C@ cstat 1+!
           1 +
       REPEAT 2DROP ;

\ преоборазовали исходную строку
: transf ( asc # --> )
         OVER +
         <# BEGIN 2DUP <> WHILE 1 -
                  DUP C@ DUP HOLD
                         DUP cstat @
                         2 MOD IF DUP HOLD cstat 1+! ELSE DROP THEN
            REPEAT
          #> ;

\ собственно, главное слово
: sample ( asc # --> ) init 2DUP prep transf TYPE ;

S" 874205257" sample CR
