REQUIRE F. lib/include/float.f

FLONG
2 FFORM !
PRINT-EXP

1e-5 FVALUE epsilon

15 VALUE N1 30 VALUE N2
0e FVALUE h1 0e FVALUE h2
0e FVALUE xn 0e FVALUE yn
0e FVALUE error 

: floats F-SIZE @ * ;
: array2D CREATE OVER ,
            * floats ALLOCATE THROW ,  
          DOES> >R R@ @ * + floats R> CELL+ @ + ;

N1 1+ N2 1+ array2D U
: F> F< INVERT ; : F? FDUP F. SPACE ; : FSQR FDUP F* ;
: U@ U F@ ; : U! U F! ;
: U! 2DUP U@
     FOVER U! ( F: new old )
 F- FABS FDUP 
         error F> IF FTO error ELSE FDROP THEN
;
: fill-U N2 1+ 0 DO   N1 1+ 0 DO 1e I J U! LOOP    LOOP ;
: print N2 1+ 0 DO   N1 1+ 0 DO I J U@ F. SPACE LOOP    CR LOOP ;

\ -------------------------------- Краевые условия
0.8e FVALUE L1 0.8e FVALUE L2
0.7e FVALUE a 0.1e FVALUE b 0.9e FVALUE c 1.3e FVALUE d -0.1e FVALUE e
: solution xn FSQR yn FSQR F-
           a F*
           xn yn F* b F* F+
           c xn F* F+
           d yn F* F+
           e F+ ;
: du/dx   2e a F* xn F*
                b yn F* F+
                c F+ ;
: du/dy   -2e a F* yn F*
                b xn F* F+
                d F+ ;
: F[] ( addr i ) floats + ; : F[]@ F[] F@ ; : F[]! F[] F! ;

: calc ( i j )
  2DUP 1- U@ 
  2DUP 1+ U@  F+ h2 FSQR F/

  2DUP SWAP 1- SWAP U@
( i j) SWAP 1+ SWAP U@  F+ h1 FSQR F/
  F+
  2e h1 FSQR F/ 2e h2 FSQR F/ F+ 
  F/
;

: index1 DS>F h1 F* ; : index2 DS>F h2 F* ;
: U0j ( j )  0e FTO xn  index2 FTO yn  solution ;
: UiN  ( i )
  DUP index1 FTO xn L2 FTO yn
  du/dy 
  h2 F* 
  ( i ) N2 1- U@ F+ ;
: UNj ( j )
  L1 FTO xn DUP index2 FTO yn 
  solution du/dx F+
  h1 F* 
  N1 1- SWAP U@ F+
  1e h1 F+ F/ ;
: Ui0 ( i )
  DUP index1 FTO xn 0e FTO yn 
  solution du/dy F-
  h2 F* 
  ( i ) 1 U@ F+
  h2 1e F+ F/ ;
: run
 N2 1+ 1 DO I U0j 0 I U! LOOP
 N2    1 DO I UNj N1 I U! LOOP
 N1 1+ 0 DO I Ui0 I 0 U! LOOP
 N1    1 DO I UiN I N2 U! LOOP
  N2 1 DO N1 1 DO I J calc I J U! LOOP LOOP ;

: main 
  L1 N1 DS>F F/ FTO h1
  L2 N2 DS>F F/ FTO h2
  fill-U
  BEGIN 0e FTO error run  error epsilon F<  UNTIL
  print
  CR
  ." ---------------------------------------------"
  CR CR
 0e FTO xn   h2 FTO yn
  0e
  N2 1 DO
   N1 0 DO 
     I J U@ 
     solution F- FABS F? 
     F+
    xn h1 F+ FTO xn  
   LOOP
   CR 
   yn h2 F+ FTO yn
   0e FTO xn
  LOOP
  N1 N2 * DS>F F/
  CR F. CR
;

S" out.txt" R/W CREATE-FILE THROW TO H-STDOUT
main BYE
