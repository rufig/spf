\ Loading to high memory

\ modified at 04.09.2002:
\ * HIGH-SIZE теперь VALUE
\ + START-HERE хранит HERE на момент вызова LH-START
\ можно использовать дл€ контрол€
\ + проверка START-HERE в LH-INCLUDED

0 VALUE HIGH-DP
0 VALUE LH-SAVE-DP
100 1024 * VALUE HIGH-SIZE
0 VALUE START-HERE

: LH-START
    HIGH-DP 0=
    IF
        IMAGE-SIZE HIGH-SIZE -
        IMAGE-BEGIN + TO HIGH-DP
    THEN
    HERE TO LH-SAVE-DP
    HIGH-DP HERE - ALLOT
    HERE TO START-HERE
;
       
: LH-STOP
    HERE TO HIGH-DP
    LH-SAVE-DP HERE - ALLOT ;

\ ”даление всех слов, которые наход€тс€ выше вершины словар€
: LH-UNLINK
\    ." Unlink: " 
    VOC-LIST
    BEGIN DUP @ ?DUP WHILE
        DUP CELL+
        BEGIN DUP @ ?DUP WHILE
            HERE OVER U<
            IF  \ DUP COUNT TYPE SPACE
                NAME>L @ OVER !
            ELSE NIP NAME>L THEN
        REPEAT
        DROP
        \ ј не выше ли вершины словар€ сам заголовок списка слов?
        HERE OVER U<
        IF @ OVER ! \ ”дал€ем
        ELSE
           NIP
        THEN
    REPEAT
    DROP
\    CR
;

: LH-INCLUDED ( S" prog.f" --)
    LH-START
    INCLUDED
    LH-STOP
    HERE START-HERE - HIGH-SIZE > ABORT" LH-INCLUDED: High memory overflow" ;

WARNING @ WARNING 0!    

: SAVE LH-UNLINK 0 TO HIGH-DP SAVE ;

WARNING !