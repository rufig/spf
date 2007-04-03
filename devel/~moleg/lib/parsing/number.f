\ 16-02-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ Преобразование числовых литералов при интерпретации.

\ умножение числа двойной длинны на одинарное
: DU* ( d u --> d ) TUCK * >R UM* R> + ;

\ преобразовать символ в цифру »
: >CIPHER ( c --> u|-1 )
          DUP [CHAR] 0 [CHAR] : WITHIN IF 48 - EXIT THEN
          DUP [CHAR] A [CHAR] [ WITHIN IF 55 - EXIT THEN
          DUP [CHAR] a [CHAR] { WITHIN IF 87 - EXIT THEN
          DROP -1 ;

\ попытаться преобразовать символ char в цифру,
\ в системе исчисления, определяемой base »
: DIGIT ( char base --> u TRUE | FALSE )
        SWAP >CIPHER TUCK U>
        IF TRUE ELSE DROP FALSE THEN ;

\ добавить цифру x к числу d*base »
: CIPHER ( d x --> d )
         U>D 2SWAP BASE @ DU* D+ ;

\ перевести символьное представление числа во внутреннее ( двоичное ) »
\ преобразование ведется до конца строки или до первого непреобразуемого
\ символа. Если #2 равно нулю преобразование успешно.
: >NUMBER ( ud1 asc1 #1 --> ud2 asc2 #2 )
          BEGIN DUP WHILE               \ пока не конец строки
            OVER C@ BASE @ DIGIT WHILE  \ до первой непреобразуемой цифры
            -ROT SKIP1 2>R CIPHER 2R>   \ добавить цифру
           REPEAT
          THEN ;
