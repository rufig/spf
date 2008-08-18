\ Loading to high memory

\ HERE 
\ IMAGE-SIZE HERE IMAGE-BEGIN - - 2048 - ALLOT

0 VALUE HIGH-DP
0 VALUE LH-SAVE-DP
1024 100 * CONSTANT HIGH-SIZE

: LH-START
    HIGH-DP 0=
    IF
        IMAGE-SIZE HIGH-SIZE -
        IMAGE-BEGIN + TO HIGH-DP
    THEN
    HERE TO LH-SAVE-DP
    HIGH-DP HERE - ALLOT
;
       
: LH-STOP
    HERE TO HIGH-DP
    LH-SAVE-DP HERE - ALLOT ;

\ ”даление всех слов, которые наход€тс€ выше вершины словар€
: LH-UNLINK
\    ." Unlink: " 
    VOC-LIST  
    BEGIN DUP @  ?DUP WHILE
        DUP CELL+
        BEGIN DUP @ ?DUP WHILE
            HERE OVER U<
            IF             \ DUP DUP . COUNT TYPE SPACE CR
                NAME>L @ OVER !
            ELSE NIP NAME>L THEN
        REPEAT
        DROP
        \ ј не выше ли вершины словар€ сам заголовок списка слов?
        HERE OVER U<
        IF @ OVER ! \ ." ”дал€ем" CR
        ELSE
           NIP
        THEN
    REPEAT
    DROP

    WINAPLINK
    BEGIN
        DUP @ ?DUP
    WHILE
        HERE OVER U<
        IF @ OVER !
        ELSE NIP THEN
    REPEAT
    DROP
\    CR
;

: LH-INCLUDED ( S" prog.f" --)
    LH-START INCLUDED LH-STOP ;

WARNING @ WARNING 0!    

: SAVE LH-UNLINK 0 TO HIGH-DP SAVE ;

WARNING !

\ HERE - ALLOT