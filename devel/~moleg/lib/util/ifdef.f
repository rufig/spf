\ 25-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ выполнить действие, если слово не найдено

\ вернуть TRUE если следующее слово найдено в контексте
: ?WORD ( / token --> flag )
        SP@ >R  NextWord SFIND
        IF R> SP! TRUE
         ELSE R> SP! FALSE
        THEN ;

\ если флаг равен нулю пропустить текст до конца строки
: ADMIT ( flag --> ) IF ELSE [COMPILE] \ THEN ; IMMEDIATE

\ выполнить следующий за token код, если token не найден в контексте
: ?DEFINED ( / token --> ) ?WORD 0 = [COMPILE] ADMIT ; IMMEDIATE

\ выполнить следующий за token код, если token найден в контексте
: N?DEFINED ( / token --> ) ?WORD [COMPILE] ADMIT ; IMMEDIATE

?DEFINED test{ \EOF

test{  FALSE ADMIT -1 THROW
       S" passed" TYPE }test

\EOF -- sample --------------------------------------------------------------

?DEFINED A@  : A@ @ ; : A! ! ; : A, , ; : ADDR CELL ;

