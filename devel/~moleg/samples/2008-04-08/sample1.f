\ 2008-04-16 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ удвоение уникальных цифр строки
\ решение задачки для конкурса http://fforum.winglion.ru/viewtopic.php?t=1228

\ чтобы не подключать внешнюю либу:
\ преобразовать символ в цифру
: >CIPHER ( c --> u|-1 )
          DUP [CHAR] 0 [CHAR] : WITHIN IF 48 - EXIT THEN
          DUP [CHAR] A [CHAR] [ WITHIN IF 55 - EXIT THEN
          DUP [CHAR] a [CHAR] { WITHIN IF 87 - EXIT THEN
          DROP -1 ;

\ преобразовать число в символ √
\ число не должно превышать значение находящееся в BASE
: >DIGIT ( u --> char ) DUP 0x09 > IF 7 + THEN 0x30 + ;

\ ----------------------------------------------------------------------------------
        USER-VALUE digits \ вместо списка одно число

\ вернуть маску указанной цифры и маску для всех цифр
: m&m ( char --> u u ) >CIPHER 1 SWAP LSHIFT digits ;

\ сканировать строку цифр (возможно и символов) собирать статистику
: scan ( asc # --> )
       OVER + SWAP
       BEGIN 2DUP <> WHILE
             DUP C@ m&m XOR TO digits
         1 +
       REPEAT 2DROP ;

\ преобразование исходной строки согласно ТЗ
: transf ( asc # --> asc # )
         <# HOLDS
            0 digits 0x3FF AND
            BEGIN DUP WHILE
                  DUP 1 AND IF OVER >DIGIT HOLD THEN
              2/ SWAP 1 + SWAP
            REPEAT
          #> ;

\ собственно, главное слово
: sample ( asc # --> )
         0 TO digits
         2DUP scan transf
         TYPE ;