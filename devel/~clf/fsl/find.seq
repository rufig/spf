\ find.seq               ACM Algorithm #65 (iterative implementation)

\ Forth Scientific Library Algorithm #26

\  }find ( n &p k -- k )
\             Find will assign to the floating point array element p[k],
\             the value which it would have if the floating point array
\             p[0..n-1] was sorted (downward).
\             Useful for finding the median or similar elements of an array.
\             Requires 1/3 N log(N) exchanges on the average

\             (P will be partially sorted in the process, and subsequent
\              calls to }find will run faster).

 
\ This is an ANS Forth program requiring:
\      1. The Floating-Point word set
\      2. The word '}' to dereference a one-dimensional array (ARRAY).
\      3. Uses the words 'FLOAT' and ARRAY to create floating point arrays.
\      4. Uses the words 'DARRAY' and '&!' to set array pointers.
\      5. Uses words 'Private:', 'Public:' and 'Reset_Search_Order'
\         to control visibility of internal code
\      6. The test code uses the immediate word '%' which takes the
\         next token and converts it to a floating-point literal
\      7. The word '}fprint' is needed to print a one dimensional
\         floating point array in the test code.
\      8. The compilation of the test code is controlled by VALUE TEST-CODE?
\         and the conditional compilation words in the Programming-Tools
\         wordset.
\ 

\ Collected Algorithms from ACM, Volume 1 Algorithms 1-220,
\ 1980; Association for Computing Machinery Inc., New York,
\ ISBN 0-89791-017-6

\ (c) Copyright 1994 Everett F. Carter.  Permission is granted by the
\ author to use this software for any application provided this
\ copyright notice is preserved.

CR .( FIND     V1.0                  13 November 1994   EFC )

Private:

FLOAT DARRAY p{                     \ pointer to user array

: inc-i ( i -- i' ) ( F: x -- x )
        BEGIN
          FDUP p{ OVER } F@ F<
        WHILE
          1+
        REPEAT
;

: dec-j ( j -- j' ) ( F: x -- x )
       BEGIN
         p{ OVER } F@ FOVER F<
       WHILE
         1-
       REPEAT
;

: exchange ( i j -- )
       p{ SWAP }   DUP F@
       p{ ROT }    DUP F@
       SWAP
       F! F!
;

: replace-l? ( k l r i j -- k l' r i j )     \ conditionally replace l with i
           DUP 5 PICK < IF 2>R  SWAP DROP R@ SWAP 2R>  THEN
;


: replace-r? ( k l r i j -- k l r' )        \ conditionally replace r with j
                                            \ and remove excess values
           4 PICK ROT < IF SWAP THEN  DROP
;

Public:

: }find ( n &p k -- k )

        SWAP & p{ &!

        SWAP 1- 0 SWAP     ( k l=0 r=n-1 )

        BEGIN
          2DUP <
        WHILE
           p{ 3 PICK } F@
           2DUP         ( k l r i=l j=r )
           
           BEGIN
             SWAP inc-i
             SWAP dec-j
             2DUP > 0= IF 2DUP exchange SWAP 1+ SWAP 1- THEN                      
             2DUP >
           UNTIL

           FDROP
           replace-l?
           replace-r?
        REPEAT

        2DROP
;

Reset_Search_Order


TEST-CODE? [IF]     \ test code =============================================


33 FLOAT ARRAY Test{

: fillTest{  ( -- )  33 0 do  I S>F % 0.7 F/ FSIN Test{ I } F!  LOOP  ;

: test-find  ( n -- )

   fillTest{

   33  Test{ }fprint CR

   33 Test{ ROT }find
   
   CR ." value is: "
   Test{ SWAP } F@ F. CR

;

[THEN]

