\ Fractions

\ S" ~nn/lib/gcd-code.f" INCLUDED
: GCD ( n1 n2 -- u3)
    ABS SWAP ABS SWAP
    2DUP < IF SWAP THEN
    ?DUP 0= IF ?DUP 0= IF 1 THEN EXIT THEN
    BEGIN TUCK MOD ?DUP 0= UNTIL
;
: FR-NORMALIZE ( a1/b1 -- a2/b2)
    ?DUP 0= IF 1 THEN
    2DUP GCD TUCK / >R / R>
    DUP 0<
    IF 
         NEGATE SWAP NEGATE SWAP
    THEN
;

: FR+ ( a1/b1 a2/b2 -- [a1*b2+a2*b1]/[b1*b2])
    FR-NORMALIZE 2SWAP FR-NORMALIZE 2SWAP
    ROT 2DUP * >R ROT * >R * R> + R>
    FR-NORMALIZE
;
: FR-NEGATE SWAP NEGATE SWAP ;
: FR-ABS SWAP ABS SWAP ;

: FR- FR-NEGATE FR+ ;

: FR* ( a1/b1 a2/b2 -- a3/b3)
    FR-NORMALIZE 2SWAP FR-NORMALIZE 2SWAP
    ROT * >R * R>
    FR-NORMALIZE
;

: FR/ ( a1/b1 a2/b2 -- a3/b3)
    SWAP FR* ;
: FRS* ( a1/b1 n2 -- a2/b2) 1 FR* ;
8 VALUE PRINT-ACCURACY

: ?SPACES DUP 0 > IF SPACES ELSE DROP THEN ;
: R-TYPE ( addr len1 len-field -- )
    OVER - ?SPACES TYPE ;
: L-TYPE ( addr len1 len-field -- )
    OVER - >R TYPE R> ?SPACES ;    
: FR>/STR ( a/b -- addr u)
    FR-NORMALIZE SWAP DUP >R ABS SWAP
    <#
        DUP 1 <> OVER 0 <> AND
        IF
            S>D #S 2DROP
            [CHAR] / HOLD
        ELSE
            DROP
        THEN
        S>D #S 
        R> SIGN
    #>
;
: FR/.R ( a/b len --)  >R FR>/STR R> R-TYPE ;
: FR/.L ( a/b len --)  >R FR>/STR R> L-TYPE ;
: FR/. ( a/b --)  1 FR/.R SPACE ;


: FR>STR ( a/b -- addr u)
    FR-NORMALIZE SWAP DUP >R ABS 
    OVER /MOD >R
    <#
        0 ROT ROT
        PRINT-ACCURACY 0
        DO
            10 * OVER /MOD
            [CHAR] 0 + ROT ROT
            DUP 0= IF LEAVE THEN
        LOOP
        2DROP
        BEGIN ?DUP WHILE
            HOLD 
        REPEAT
        [CHAR] . HOLD
        R> S>D #S
        R> SIGN
    #>
;

: FR.R ( a/b len --)  >R FR>STR R> R-TYPE ;
: FR.L ( a/b len --)  >R FR>STR R> L-TYPE ;
: FR. 1 FR.R SPACE ;
    
CREATE FR-DENOM
    1 ,  10 , 100 , 1000 , 10000 , 100000 , 1000000 , 10000000 , 
    100000000 , 1000000000 , 10000000000 , 

: ?FR-SLITERAL ( addr u -- )
    OVER C@ [CHAR] - = DUP >R
    IF 1- SWAP 1+ SWAP THEN
    0 0 2SWAP >NUMBER
    DUP 0= IF -321 THROW THEN
    OVER C@ [CHAR] . = 
    IF
        1- SWAP 1+ SWAP DUP 0= IF 321 THROW THEN
        OVER >R
        >NUMBER IF RDROP -321 THROW THEN 
        R> - CELLS FR-DENOM + @ >R
        DROP R> 
    ELSE 
        OVER C@ [CHAR] / = 
        IF 
            2SWAP DROP >R
            1- SWAP 1+ SWAP
            0 0 2SWAP >NUMBER 2DROP DROP
            DUP 0= IF -322 THROW THEN
            R> SWAP
        ELSE
           -321 THROW
        THEN
    THEN
    FR-NORMALIZE
    R> IF SWAP NEGATE SWAP THEN
    POSTPONE 2LITERAL
;

: NOTFOUND ( addr u -- )    
    2DUP 2>R ['] ?FR-SLITERAL CATCH
    IF 2DROP 2R> ?SLITERAL
    ELSE
        2R> 2DROP
    THEN ;

: FR: ( -- a/b)
    BL WORD COUNT 2>R 2R@ ['] ?FR-SLITERAL CATCH
    IF  2DROP
        2R> ?SLITERAL 1 POSTPONE LITERAL
    ELSE
        2R> 2DROP
    THEN
;

: FR-VARIABLE  VARIABLE 0 , ;
: FR-CONSTANT  CREATE HERE 2! 2 CELLS ALLOT DOES> 2@ ;

: FR0= DROP 0= ;
: FR0< ( a/b -- ?) DROP 0< ;
: FR0> ( a/b -- ?) DROP 0 > ;
: FR< ( a1/b1 a2/b2 -- ?) FR- FR0< ;
: FR> ( a1/b1 a2/b2 -- ?) FR< 0= ;
: FR= FR- FR0= ;

: FR! 2! ;
: FR@ 2@ ;
: FR? FR@ FR. ;

: FR-DUP    2DUP ;
: FR-DROP   2DROP ;
: FR-SWAP   2SWAP ;
: FR-OVER   2OVER ;
: FR-NIP    2SWAP 2DROP ;
: FR-TUCK   2SWAP 2OVER ;

: FR-SIGN   DROP DUP IF 0< IF -1 ELSE 1 THEN THEN ;
    
: FRR/. ( a/b --) SWAP OVER /MOD . SWAP
    FR-DUP FR0= 0= IF FR-ABS FR/. ELSE FR-DROP THEN ;
    