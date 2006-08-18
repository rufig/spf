\                       For Sp-Forth 4 ( ver. >= 007 ) ( 19.10.2002 )

\                       contains commonly needed definitions.
\ dxor, dor, dand       double xor, or, and
\ sd*                   single * double = double_product
\ v: defines use( &     For defining and settting execution vectors
\ %                     Parse next token as a FLOAT
\ -FROT                 Reverse the effect of FROT
\ F2*  F2/              Multiply and divide float by two
\ F2DUP                 FDUP two floats
\ F2DROP                FDROP two floats
\ INTEGER, DOUBLE, FLOAT   For setting up ARRAY types
\ ARRAY DARRAY              For declaring static and dynamic arrays
\ }                         For getting an ARRAY or DARRAY element address
\ &!                        For storing ARRAY aliases in a DARRAY
\ PRINT-WIDTH               The number of elements per line for printing arrays
\ }FPRINT                   Print out a given array
\ Matrix                    For declaring a 2-D array
\ }}                        gets a Matrix element address
\ Public: Private: Reset_Search_Order   controls the visibility of words
\ frame unframe             sets up/removes a local variable frame
\ a b c d e f g h           local FVARIABLE values
\ &a &b &c &d &e &f &g &h   local FVARIABLE addresses


\ This code conforms with ANS requiring:
\     	1. The Floating-Point word set
\       2. The words umd* umd/mod and d* are implemented
\          for ThisForth in the file umd.fo

\ This code is released to the public domain Everett Carter July 1994

CR .( FSL-UTIL.F       V1.0          19 October 2002   for SP-Forth4 ) CR
777 CONSTANT fsl-util
S" FLOAT-PAD" SFIND 0= [IF] 2DROP lib\include\float2.f [ELSE] DROP [THEN]
: PRINT-WIDTH FFORM ;
: F> F< 0= ;

\ ================= compilation control ======================================

\ for control of conditional compilation of test code
FALSE VALUE TEST-CODE?
FALSE VALUE ?TEST-CODE           \ obsolete, for backward compatibility

\ for control of conditional compilation of Dynamic memory
FALSE CONSTANT HAS-MEMORY-WORDS?

\ =============================================================================

\ FSL NonANS words

: S>F    S>D D>F ;

WORDLIST CONSTANT hidden-wordlist

: Reset-Search-Order
	FORTH-WORDLIST 1 SET-ORDER
	FORTH-WORDLIST SET-CURRENT
;
: Public:
	FORTH-WORDLIST hidden-wordlist 2 SET-ORDER
	FORTH-WORDLIST SET-CURRENT
;
: Private:
	FORTH-WORDLIST hidden-wordlist 2 SET-ORDER
	hidden-wordlist SET-CURRENT
;
: Reset_Search_Order   Reset-Search-Order ;     \ these are
: reset-search-order   Reset-Search-Order ;	\ for backward compatibility
: private:              Private: ;
: public:               Public:  ;

\	QUESTION: Do you have a PAD for FSL?

CREATE fsl-pad	84 CHARS ( or more ) ALLOT

\ needs
\ umd/mod     ( uquad uddiv -- udquot udmod ) unsigned quad divided by double
\ umd*        ( ud1 ud2 -- qprod )            unsigned double multiply
\ d*          ( d1 d2   -- dprod )            double multiply

: dxor       ( d1 d2 -- d )             \ double xor
	ROT XOR >R XOR R>
;
: dor       ( d1 d2 -- d )              \ double or
	ROT OR >R OR R>
;
: dand     ( d1 d2 -- d )               \ double and
	ROT AND >R AND R>
;
: d>
         2SWAP D<
;
: >=     < 0= ;                        \ greater than or equal to
: <=       > 0= ;                        \ less than or equal to

\ single * double = double
: sd*   ( multiplicand  multiplier_double  -- product_double  )
             2 PICK * >R   UM*   R> +
;

0 VALUE TYPE-ID               \ for building structures
FALSE VALUE STRUCT-ARRAY?

\ size of a regular integer
1 CELLS CONSTANT INTEGER

\ size of a double integer
2 CELLS CONSTANT DOUBLE

\ size of a regular float
1 FLOATS CONSTANT FLOAT

\ size of a pointer (for readability)
1 CELLS CONSTANT POINTER

: Double DOUBLE ;             \ backward compatibility

: add_e ( addr u -- addr u+1 ) \ добавим "е" если его нет в разбираемой строке 
2DUP S" e" SEARCH -ROT 2DROP IF \ NOOP
 ELSE
2DUP + 101 SWAP C! 1+ 
THEN 
;

\ pushes following value to the float stack
: %   
   BL WORD  COUNT SFIND IF EXECUTE EXIT THEN \ for constant for example 
   2DUP >FLOAT
   0= IF add_e 2DUP >FLOAT 0= ABORT" NAN " THEN 2DROP
   STATE @  IF POSTPONE FLITERAL  THEN  ; IMMEDIATE

\ some floating point constants
% 1.0 FCONSTANT F1.0
% FPI FCONSTANT PI

: -FROT    FROT FROT ;
: F2*   2.0e0 F*     ;
: F2/   2.0e0 F/     ;
: F2DUP     FOVER FOVER ;
: F2DROP    FDROP FDROP ;

\ 1-D array definition
\    -----------------------------
\    | cell_size | data area     |
\    -----------------------------

: MARRAY ( n cell_size -- | -- addr )             \ monotype array
     CREATE
       DUP , * ALLOT
     DOES> CELL+
;

\    -----------------------------
\    | id | cell_size | data area |
\    -----------------------------

: SARRAY ( n cell_size -- | -- id addr )          \ structure array
     CREATE
       TYPE-ID ,
       DUP , * ALLOT
     DOES> DUP @ SWAP [ 2 CELLS ] LITERAL +
;
: ARRAY
     STRUCT-ARRAY? IF   SARRAY FALSE TO STRUCT-ARRAY?
                   ELSE MARRAY
                   THEN
;
: Array   ARRAY ;

\ word for creation of a dynamic array (no memory allocated)

\ Monotype
\    ------------------------
\    | data_ptr | cell_size |
\    ------------------------

: DMARRAY   ( cell_size -- )   CREATE  0 , ,
                              DOES>
                                    @ CELL+
;

\ Structures
\    ----------------------------
\    | data_ptr | cell_size | id |
\    ----------------------------

: DSARRAY   ( cell_size -- )  CREATE  0 , , TYPE-ID ,
                              DOES>
                                    DUP [ 2 CELLS ] LITERAL + @ SWAP
                                    @ CELL+
;
: DARRAY   ( cell_size -- )
     STRUCT-ARRAY? IF   DSARRAY FALSE TO STRUCT-ARRAY?
                   ELSE DMARRAY
                   THEN
;

\ word for aliasing arrays,
\  typical usage:  a{ & b{ &!  sets b{ to point to a{'s data

: &!    ( addr_a &b -- )
        SWAP CELL- SWAP >BODY  !
;
: }   ( addr n -- addr[n])       \ word that fetches 1-D array addresses
          OVER CELL- @ \ DUP ." >>" .
          * SWAP +
;

VARIABLE print-width      6 print-width !

: }fprint ( n 'addr -- )       \ print n elements of a float array
        SWAP 0 DO I print-width @ MOD 0= I AND IF CR THEN
                  DUP I } F@ F. SPACE LOOP
        DROP
;

: }iprint ( n 'addr -- )       \ print n elements of an integer array
        SWAP 0 DO I print-width @ MOD 0= I AND IF CR THEN
                  DUP I } @ . LOOP
        DROP
;

: }fcopy ( 'src 'dest n -- )         \ copy one array into another
    0 DO
       OVER I } F@
       DUP  I } F!
    LOOP
  2DROP
;

\ 2-D array definition,

\ Monotype
\    ------------------------------
\    | m | cell_size |  data area |
\    ------------------------------

: MMATRIX  ( n m size -- )           \ defining word for a 2-d matrix
        CREATE
           OVER , DUP ,
           * * ALLOT
        DOES>  [ 2 CELLS ] LITERAL +
;

\ Structures
\    -----------------------------------
\    | id | m | cell_size |  data area |
\    -----------------------------------

: SMATRIX  ( n m size -- )           \ defining word for a 2-d matrix
        CREATE TYPE-ID ,
           OVER , DUP ,
           * * ALLOT
        DOES>  DUP @ TO TYPE-ID
               [ 3 CELLS ] LITERAL +
;


: MATRIX  ( n m size -- )           \ defining word for a 2-d matrix
     STRUCT-ARRAY? IF   SMATRIX FALSE TO STRUCT-ARRAY?
                   ELSE MMATRIX
                   THEN
;


: DMATRIX ( size -- )      DARRAY ;


: }}    ( addr i j -- addr[i][j] )    \ word to fetch 2-D array addresses
               2>R                    \ indices to return stack temporarily
               DUP CELL- CELL- 2@     \ &a[0][0] size m
               R> * R> + *
               +
;
: }}fprint ( n m 'addr -- )       \ print nXm elements of a float 2-D array
        ROT ROT SWAP 0 DO
                         DUP 0 DO
                                  OVER J I  }} F@ F.
                         LOOP

                         CR
                  LOOP
        2DROP
;
: }}fcopy ( 'src 'dest n m  -- )      \ copy nXm elements of 2-D array src to dest
        SWAP 0 DO
                 DUP 0 DO
                            2 PICK J I  }} F@
                            OVER J I }} F!
                        LOOP
                  LOOP
        DROP 2DROP
;

\ function vector definition

: v: CREATE ['] NOOP , DOES> @ EXECUTE ;
: defines   ' >BODY STATE @ IF POSTPONE LITERAL POSTPONE !
            ELSE ! THEN ;   IMMEDIATE
: use(  STATE @ IF POSTPONE ['] ELSE ' THEN ;  IMMEDIATE
: &     POSTPONE use( ; IMMEDIATE

(
  Code for local fvariables, loosely based upon Wil Baden's idea presented
  at FORML 1992.
  The idea is to have a fixed number of variables with fixed names.
  I believe the code shown here will work with any, case insensitive,
  ANS Forth.

  i/tForth users are advised to use FLOCALS| instead.

  example:  : test  2e 3e FRAME| a b |  a f. b f. |FRAME ;
            test <cr> 3.0000 2.0000 ok

  PS: Don't forget to use |FRAME before an EXIT .
)

8 CONSTANT /FLOCALS

: (frame) ( n -- ) FLOATS ALLOT ;

: FRAME|
        0 >R
        BEGIN   BL WORD  COUNT  1 =
                SWAP C@  [CHAR] | =
                AND 0=
        WHILE   POSTPONE F,  R> 1+ >R
        REPEAT
        /FLOCALS R> - DUP 0< ABORT" too many flocals"
        POSTPONE LITERAL  POSTPONE (frame) ; IMMEDIATE

: |FRAME ( -- ) [ /FLOCALS NEGATE ] LITERAL (frame) ;

: &h            HERE [ 1 FLOATS ] LITERAL - ;
: &g            HERE [ 2 FLOATS ] LITERAL - ;
: &f            HERE [ 3 FLOATS ] LITERAL - ;
: &e            HERE [ 4 FLOATS ] LITERAL - ;
: &d            HERE [ 5 FLOATS ] LITERAL - ;
: &c            HERE [ 6 FLOATS ] LITERAL - ;
: &b            HERE [ 7 FLOATS ] LITERAL - ;
: &a            HERE [ 8 FLOATS ] LITERAL - ;

: a             &a F@ ;
: b             &b F@ ;
: c             &c F@ ;
: d             &d F@ ;
: e             &e F@ ;
: f             &f F@ ;
: g             &g F@ ;
: h             &h F@ ;

\EOF

