\ 27-09-2007 ~mOleg  SPF4.18
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ перемешать буквы слова случайным образом

 S" .\lib\ext\rnd.f" INCLUDED \ подключаем генератор псевдослучайных чисел

\ поменять содержимое байта, на ходящегося по addr на char,
\ старое значение вернуть
: ExBytes ( char addr --> oldchar ) DUP C@ -ROT C! ;

\ поменять байтовые значения двух ячеек памяти местами
: ChBytes ( addra addrb --> ) OVER C@ SWAP ExBytes SWAP C! ;

\ перемешать содержимое строки случайным образом
: mix ( asc # --> asc # )
      2DUP OVER + SWAP DO 2DUP CHOOSE + I ChBytes LOOP ;

\ перемешать все символы кроме крайних
: mmix ( asc # --> asc # )
       3 OVER < IF ELSE EXIT THEN  \  не менее трех символов в строке
       2DUP 1 -2 D+ mix 2DROP ;

\ отобразить пословное искажение содержимого строки, находящейся за mixstr
: mixstr ( / asc --> )
         BEGIN NextWord DUP WHILE
               mmix TYPE SPACE
         REPEAT 2DROP CR ;

mixstr На самом деле не так просто разобрать слова с перемешанными символами.
mixstr Возможно не все буквы стоит перемешивать , а лишь определенный процент
mixstr букв в слове

