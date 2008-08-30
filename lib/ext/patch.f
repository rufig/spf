\ $Id$

: REPLACE-WORD ( by-xt what-xt ) 
    \ http://n2.nabble.com/Прямая-компиляция-векторных-вызовов-td672884.html
    DUP B@ 0xE8 = IF \ if we're replacing defer'red word 
        DUP 1+ REL@ CELL+ ['] _VECT-CODE = IF 
            >BODY ! EXIT 
        THEN 
    THEN 

    0xE9 OVER B!  \ JMP ... 
    1+ DUP >R 
    CELL+ - 
    R> ! 
;

\ from gforth
\ : REPLACE-WORD ( by-xt what-xt )
\     [ HEX ] E9 [ DECIMAL ] OVER C!  \ JMP ...
\     1+ DUP >R
\     CELL+ -
\     R> !
\ ;
