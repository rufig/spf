REQUIRE /STRING lib/include/string.f

: S>DOUBLE ( a u -- )
    BASE @ >R
    DUP
    IF OVER C@ [CHAR] - = DUP >R
       IF 1 /STRING THEN R> ELSE FALSE THEN >R
    2DUP 2 MIN S" 0x" COMPARE 0= IF 2 /STRING HEX THEN
    0 0 2SWAP >NUMBER 2DROP
    R> IF DNEGATE THEN 
    R> BASE !
;

: S>NUM ( a u -- n) S>DOUBLE D>S ;
