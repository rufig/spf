anew FSL-Utilities

\ fsl_util.f            An auxiliary file for the Forth Scientific Library
\                       contains commonly needed definitions for Win32Forth.

\ dxor, dor, dand       double xor, or, and
\ v: defines use( &     For defining and setting execution vectors
\ %                     Parse next token as a FLOAT
\ S>F  F>S              Conversion between (single) integer and float
\ F,                    Store FLOAT at (aligned) HERE
\ INTEGER DOUBLE FLOAT  For setting up ARRAY types
\ ARRAY DARRAY          For declaring static and dynamic arrays
\ }                     For getting an ARRAY or DARRAY element address
\ }MALLOC }FREE         Allocate and free dynamic arrays
\ &!                    For storing ARRAY aliases in a DARRAY
\ PRINT-WIDTH           The number of elements per line for printing arrays
\ }FPRINT               Print out a given array
\ Matrix                For declaring a 2-D array
\ }}                    gets a Matrix element address
\ }}MALLOC }}FREE       Allocate and free dynamic matrices
\ Public: Private: Reset_Search_Order   controls the visibility of words
\ |frame frame|             sets up/removes a local variable frame
\ a b c d e f g h           local FVARIABLE values
\ &a &b &c &d &e &f &g &h   local FVARIABLE addresses

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set with separate floating stack
\      2. The Memory word set
\      3. The words \ pick tuck nip from Core Extensions
\      4. The word d+ from Double
\      5. The words: defer is f# internal external module
\         and others which are implemented in Win32Forth,
\         marked by commented-out definitions and synonyms

\ This code has an environmental dependency on CAPS being -1 ( ignore case )
\ which is the default in Win32Forth.

\ This code is released to the public domain Pierre Henri Michel., Abbat
\ February, 1998

CR .( FSL_UTIL.F        V1.0          February  1998  phma ) ( Modified from Skip Carter's fsl_util.seq 1.20 )
CR .( FSL_UTIL.F        V1.1          July      2005  mhx  )

\ ====================== compilation control ===========================
\ for control of conditional compilation test code
FALSE VALUE TEST-CODE?
FALSE VALUE ?TEST-CODE           \ obsolete, for backward compatiblity

\ for control of conditional compilation of Dynamic Memory
TRUE CONSTANT HAS-MEMORY-WORDS?

\ for control of conditional compilation of dereferencing unallocated array error
FALSE CONSTANT DEBUG-ARRAYS?

\ =======================================================================

: dxor       ( d1 d2 -- d )             \ double xor
      ROT XOR -ROT XOR SWAP
;

: dor       ( d1 d2 -- d )              \ double or
      ROT OR -ROT OR SWAP
;

: dand     ( d1 d2 -- d )               \ double and
     ROT AND -ROT AND SWAP
;

\ function vector definition
synonym v: defer
synonym defines is

: use(  STATE @ IF [COMPILE] ['] ELSE ' THEN ;  IMMEDIATE
: &     [COMPILE] use( ; IMMEDIATE


\ pushes following value to the float stack
synonym % f#

: -FROT    FROT FROT ;
[UNDEFINED] 1/F  [IF] : 1/F  ( F: r -- 1/r ) 1e FSWAP F/ ; [THEN]
[UNDEFINED] FSQR [IF] : FSQR ( F: r -- r^2 ) FDUP F* ;     [THEN]

0 VALUE TYPE-ID               \ for building structures
FALSE VALUE STRUCT-ARRAY?

\ size of a regular integer
1 cells CONSTANT INTEGER

\ size of a double integer
2 cells CONSTANT DOUBLE

\ size of a regular float
CR .( FLOAT had to be redefined )
1 floats CONSTANT FLOAT

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
                                    DUP 2 CELLS+ @ SWAP
                                    @ CELL+
;


: DARRAY   ( cell_size -- )
     STRUCT-ARRAY? IF   DSARRAY FALSE TO STRUCT-ARRAY?
                   ELSE DMARRAY
                   THEN
;

: }FREE ( &array{ )
( Usage: array{ }free )
  >BODY DUP @ FREE DROP OFF ;

synonym }}FREE }FREE

0 VALUE malloc-fail?

: }MALLOC ( &array{ #elements )
( Usage: & array{ 5 }malloc allocates an array of 5 elements )
 [ DEBUG-ARRAYS? ] [IF]
 OVER >BODY @ IF ." Warning: array is already allocated" THEN [THEN]
 OVER }FREE ( deallocate the array to prevent memory leaks )
 OVER >BODY CELL+ @ ( get the element size )
 TUCK * CELL+ ( add room to store the element size )
 ALLOCATE IF ( there was an error)
   TO malloc-fail?
   DROP 0 SWAP >BODY ! ( store 0 in the array pointer )
 ELSE
   0 TO malloc-fail?
   TUCK ! ( store the element size )
   SWAP >BODY ! ( store the array location )
 THEN ;

v: do-align
v: do-aligned

: default-alignments  & ALIGN defines do-align  & ALIGNED defines do-aligned ;
: float-alignments    & FALIGN defines do-align  & FALIGNED defines do-aligned ;

: XINTEGER  1 CELLS  default-alignments ;

: XDOUBLE   2 CELLS  default-alignments ;

: XFLOAT    1 FLOATS float-alignments ;


: XARRAY ( n size -- | -- addr )       \ experimental array with alignment
     CREATE
       DUP , DO-ALIGN * ALLOT
     DOES> CELL+ DO-ALIGNED
;


\ word for aliasing arrays,
\  typical usage:  a{ & b{ &!  sets b{ to point to a{'s data

: &!    ( addr_a &b -- )
        SWAP CELL- SWAP >BODY  !
;

DEBUG-ARRAYS? [IF]
: unallocated? ( array-address - array-address )
( Use ABORT" or THROW as you like. )
  DUP 0=
\ IF -9 THROW THEN
  ABORT" Array or matrix is not allocated"
  ;
[THEN]

: }   ( addr n -- addr[n])       \ word that fetches 1-D array addresses
  OVER CELL-
  [ DEBUG-ARRAYS? ] [IF] unallocated? [THEN]
  @ * SWAP + ;


VARIABLE print-width     6 print-width !

: }fprint ( n 'addr -- )       \ print n elements of a float array
        SWAP 0 DO I print-width @ MOD 0= I AND IF CR THEN
                  DUP I } F@ F. LOOP
        DROP
;

: }iprint ( n 'addr -- )        \ print n elements of an integer array
       SWAP 0 DO I print-width @ MOD 0= I AND IF CR THEN
                 DUP I } @ . LOOP
       DROP
;

: }fcopy ( 'src 'dest n -- )    \ copy one array into another
         0 DO
                 OVER I } F@
                 DUP  I } F!
               LOOP
         2DROP
;



\ 2-D array definition,

\ Monotype
\    -----------------------------------
\    | m | cell_size |  data area |
\    -----------------------------------

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

: }}    ( addr i j -- addr[i][j] )    \ word to fetch 2-D array addresses
  >R >R                  \ indices to return stack temporarily
  DUP CELL- CELL-
  [ DEBUG-ARRAYS? ] [IF] unallocated? [THEN]
  2@     \ &a[0][0] size m
  R> * R> + * + ;

\ Dynamic 2-D array definition,
\    ------------------------------
\    | data_ptr | cell_size | (id) |
\    ------------------------------

\ word for creation of a dynamic array (no memory allocated)

\ Monotype
\    ------------------------
\    | data_ptr | cell_size |
\    ------------------------

: DMMATRIX   ( cell_size -- )
  CREATE  0 , ,
  DOES>  @ 2 CELLS+
;

\ Structures
\    ----------------------------
\    | data_ptr | cell_size | id |
\    ----------------------------

: DSMATRIX   ( cell_size -- )
  CREATE  0 , , TYPE-ID ,
  DOES>  DUP 2 CELLS+ @ SWAP @ 2 CELLS+
;


: DMATRIX   ( cell_size -- )
     STRUCT-ARRAY? IF   DSMATRIX FALSE TO STRUCT-ARRAY?
                   ELSE DMMATRIX
                   THEN
;

: }}MALLOC ( &matrix{{ rows cols )
( Allocates a matrix. The element size is known at compile time
 and is stored at &matrix{{; the array dimensions are specified
 at runtime. )
 [ DEBUG-ARRAYS? ] [IF]
 2 PICK >BODY @ IF ." Warning: matrix is already allocated" THEN [THEN]
 2 PICK }}FREE ( deallocate the array to prevent memory leaks )
 2 PICK >BODY CELL+ @ ( get the element size )
 2DUP 2>R * * 2 CELLS+ ( add room to store the element size and row length )
 ALLOCATE IF ( there was an error)
   TO malloc-fail?
   2R> 2DROP 0 SWAP >BODY ! ( store 0 in the array pointer )
 ELSE
   0 TO malloc-fail?
   R> R> 2 PICK 2! ( store the element size and row length )
   SWAP >BODY ! ( store the array location )
 THEN ;

: }}fprint ( n m 'addr -- )       \ print n×m elements of a float 2-D array
        CR ROT ROT SWAP 0 DO
                         DUP 0 DO
                                  OVER J I  }} F@ F.
                         LOOP

                         CR
                  LOOP
        2DROP
;

: }}iprint ( n m 'addr -- )       \ print n×m elements of a float 2-D array
  ROT ROT SWAP 0 DO
    DUP 0 DO
      OVER J I  }} @ .
    LOOP
    CR
  LOOP
  2DROP
;

: }}fcopy ( 'src 'dest n m  -- )      \ copy n×m elements of 2-D array src to dest
        SWAP 0 DO
                 DUP 0 DO
                            2 PICK J I  }} F@
                            OVER J I }} F!
                        LOOP
                  LOOP
        DROP 2DROP
;


\ Code for hiding words that the user does not need to access
\ into a hidden wordlist.
\ Private:
\          will add HIDDEN to the search order and make HIDDEN
\          the compilation wordlist.  Words defined after this will
\          compile into the HIDDEN vocabulary.
\ Public:
\          will restore the compilation wordlist to what it was before
\          HIDDEN got added, it will leave HIDDEN in the search order
\          if it was already there.   Words defined after this will go
\          into whatever the original vocabulary was, but HIDDEN words
\          are accessable for compilation.
\ Reset_Search_Order
\          This will restore the compilation wordlist and search order
\          to what they were before HIDDEN got added.  HIDDEN words will
\          no longer be visible.

\ These three words can be invoked in any order, multiple times, in a
\ file, but Reset_Search_Order should finally be called last in order to
\ restore things back to the way they were before the file got loaded.

\ WARNING: you can probably break this code by setting vocabularies while
\          Public: or Private: are still active.

synonym Private: internal
synonym Public: external
synonym Reset_Search_Order module

\  Code for local fvariables, loosely based upon Wil Baden's idea presented
\  at FORML 1992.
\  The idea is to have a fixed number of variables with fixed names.
\  I believe the code shown here will work with any, case insensitive,
\  ANS Forth.

\  FRAME| always pushes 8 floats onto the flocal stack; if your
\  arguments are A and B you can use C through H for local storage.

\  Note: The variables are in the opposite order than used by { ... } .

\  example:  : test  2e 3e FRAME| a b |  a f. b f. |FRAME ;
\            test <cr> 3.0000 2.0000 ok

\  PS: Don't forget to use |FRAME before an EXIT .


8 CONSTANT /flocals

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

: |FRAME ( -- ) [ /FLOCALS NEGATE ] LITERAL (FRAME) ;

: &h            HERE [ 1 FLOATS ] LITERAL - ;
: &g            HERE [ 2 FLOATS ] LITERAL - ;
: &f            HERE [ 3 FLOATS ] LITERAL - ;
: &e            HERE [ 4 FLOATS ] LITERAL - ;
: &d            HERE [ 5 FLOATS ] LITERAL - ;
: &c            HERE [ 6 FLOATS ] LITERAL - ;
: &b            HERE [ 7 FLOATS ] LITERAL - ;
: &a            HERE [ 8 FLOATS ] LITERAL - ;

CR .( Note: B and E were previously defined as words interfacing with the editor. )

: a             &a F@ ;
: b             &b F@ ;
: c             &c F@ ;
: d             &d F@ ;
: e             &e F@ ;
: f             &f F@ ;
: g             &g F@ ;
: h             &h F@ ;

