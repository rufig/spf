\ 25-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ выполнить действие, если слово не найдено

\ вернуть TRUE если следующее слово найдено в контексте
: ?WORD ( / token --> flag )
        SP@ >R  NextWord SFIND
        IF R> SP! TRUE
         ELSE R> SP! FALSE
        THEN ;

\ выполнить следующий за token код, если token не найден в контексте
: ?DEFINED ( / token --> ) ?WORD IF [COMPILE] \ THEN ; IMMEDIATE

\ выполнить следующий за token код, если token найден в контексте
: N?DEFINED ( / token --> ) ?WORD IF ELSE [COMPILE] \ THEN ; IMMEDIATE

?DEFINED test{ \EOF

test{  S" passed" TYPE }test

\EOF -- sample --------------------------------------------------------------

?DEFINED A@  : A@ @ ; : A! ! ; : A, , ; : ADDR CELL ;

