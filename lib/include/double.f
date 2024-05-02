\ 94 Double-Number words

REQUIRE SYNONYM         lib/include/wordlist-tools.f
REQUIRE [UNDEFINED]     lib/include/tools.f

[UNDEFINED] 2, [IF]
  : 2, ( xd -- )  , , ;  \ a well-known word
[THEN]

[UNDEFINED] 2LIT, [IF]
  SYNONYM 2LIT, DLIT,  ( xd -- ) \ a well-known word
[THEN]


: 2CONSTANT ( x1 x2 "<spaces>name" -- )
  2>R  :  2R> 2LIT, POSTPONE ;
;
: 2VARIABLE ( "<spaces>name" -- )
  ALIGN HERE  0 , 0 ,  CONSTANT
;

: _2VALUE-CODE    ( -- xd ) R>      @ 2@ ;
: _TO_2VALUE-CODE ( xd -- ) R> 9 -  @ 2! ;

: 2VALUE ( xd "<spaces>name" -- )
  ALIGN HERE >R  2,
  \ see compiler/spf_defwords.f # "VALUE"
  HEADER
  ['] _2VALUE-CODE      _COMPILE, R> ,
  ['] _TO_2VALUE-CODE   _COMPILE,
  \ NB: "_COMPILE," never does inlining
;

: D.R ( d n -- )
  >R DUP >R DABS <# #S R> SIGN #>
  R> OVER - 0 MAX SPACES TYPE
;
: D0< ( d -- flag )
  0. D<
;
: DMAX ( d1 d2 -- d3 )
  2OVER 2OVER D< IF 2SWAP THEN 2DROP
;
: DMIN ( d1 d2 -- d3 )
  2OVER 2OVER D> IF 2SWAP THEN 2DROP
;
: M+ ( d1|ud1 n -- d2|ud2 )
  S>D D+
;

\ 94 Double-Number extension words

: 2ROT ( x1 x2 x3 x4 x5 x6 -- x3 x4 x5 x6 x1 x2 )
  2>R 2SWAP 2R> 2SWAP
;
: DU< ( ud1 ud2 -- flag )
  ROT 2DUP = IF 2DROP U< ELSE U> NIP NIP THEN
;


\ ===============================================

\ ANS extended precision maths
\ Robert Smith
\ (from COLDFORTH Version 0.8, GPL )

\ tnegate
\ Tri negate.
: TNEGATE   ( t1lo t1mid t1hi -- t2lo t2mid t2hi )
    INVERT >R
    INVERT >R
    INVERT 0 -1 -1 D+ S>D R> 0 D+
    R> +
;

\ ut*
\ Unsigned double by an unsigned integer to give a tri result.
: UT*   ( ulo uhi u -- utlo utmid uthi )
    SWAP >R DUP >R
    UM* 0 R> R> UM* D+
;

\ mt*
\ Double by a integer to give a tri result.
: MT*   ( lo hi n -- tlo tmid thi )
    DUP 0< IF
        ABS OVER 0< IF
            >R DABS R> UT*
        ELSE
            UT* TNEGATE
        THEN
    ELSE
        OVER 0<
        IF
            >R DABS R> UT* TNEGATE
        ELSE
            UT*
        THEN
    THEN
;
     
\ ut/
\ Divide a tri number by an integer.
: UT/   ( utlo utmid uthi n -- d1 )
    DUP >R UM/MOD -ROT R> UM/MOD
    NIP SWAP
;


\ ANS 8.6.1.1820 M*/
: M*/  ( d1 n1 +n2 -- d2 ) \ 94 DOUBLE 
\ Multiply d1 by n1 producing the triple-cell intermediate result t. 
\ Divide t by +n2 giving the double-cell quotient d2. 
\ An ambiguous condition exists if +n2 is zero or negative, 
\ or the quotient lies outside of the range of a double-precision 
\ signed integer.
    >R MT* DUP 0< IF
        TNEGATE R> UT/ DNEGATE
    ELSE
        R> UT/
    THEN
;
