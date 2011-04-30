: IS-/OR\? ( c -- ?) DUP [CHAR] \ = SWAP [CHAR] / = OR ;

: -X:\  ( a u -- a1 u1)  OVER 1+ C@ [CHAR] : = IF DUP 3 MIN >R R@ - SWAP R> + SWAP THEN ;
: -X:\2 ( a u -- a1 u1)

;
: FILENAME-FRACT { a u \ asep -- path u1 name u2 }
    a u + u IF 1- THEN
    BEGIN  DUP a <> OVER C@ IS-/OR\? 0= AND  WHILE 1- REPEAT
    TO asep
    asep a =
    IF S" "  a u
    ELSE
        a asep a - u OVER - 1- asep 1+ SWAP
    THEN
    2>R
    ?DUP 0= IF DROP S" ." THEN
    2R>
;

: LAST-N-DIRS { a u n \ cnt pos -- a1 u1 }
    n 0<> u 0<> AND
    IF
       0 TO cnt
       a a u + 1- DUP C@ IS-/OR\? IF 1- THEN
       2DUP > IF NIP 0 EXIT THEN
       2DUP = IF 2DROP a u EXIT THEN
       DO
         I C@ IS-/OR\?
         IF AT cnt 1+!
            I 1+ TO pos
            cnt n = IF LEAVE THEN
         THEN
       -1 +LOOP
       cnt n <>
       IF a u
       ELSE
           pos u pos a - -
       THEN
    ELSE a u + 0 THEN
;

REQUIRE \EOF ~nn/lib/eof.f
\EOF

: tp1 S" c:\xxx\yyy\zzz\aaa\bbb\ccc\ddd\" ;

: t ( a u n ) DUP . LAST-N-DIRS 2DUP SWAP . . ." <" TYPE ." >" CR ;
: test
    tp1 0 t
    tp1 1 t
    tp1 2 t
    tp1 3 t
    tp1 4 t
    tp1 5 t
    tp1 6 t
    tp1 7 t
    tp1 8 t
    tp1 9 t
    S" \" 9 t
    S" x\" 9 t
    S" ." 2 t
;
test