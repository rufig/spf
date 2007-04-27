\ hartley.tst       Additional Hartley Transform Utilities and test code

\ Supplement to Forth Scientific Library Algorithm #8

\ This code conforms with ANS requiring:
\      1. The Floating-Point word set

\ F2DUP                 FDUP two floats
\ F2DROP                FDROP two floats
\ F2*  F2/              Multiply and divide float by two
\ F>                    Test for greater than

\ : F2DUP     FOVER FOVER ;
\ : F2DROP    FDROP FDROP ;
\ : F2*   2.0e0 F*     ;
\ : F2/   2.0e0 F/     ;
\ : F>    FSWAP F<     ;

\  by Marcel Hendrix, October 8, 1994.
\  (c) Copyright 1994 Marcel Hendrix.  Permission is granted by the
\  author to use this software for any application provided this
\  copyright notice is preserved.


CR .( HARTLEY.TST         V1.0            8 October 1994   MH )


: ifht     ( addr #elts -- )     
     fht ;


\ Calculate Fourier coefficients from the FHT algorithm output 

\  1024 CONSTANT datasize  ( test for accuracy )
     64 CONSTANT datasize  ( test for speed )

datasize       FLOAT ARRAY data{
datasize 2/ 1+ FLOAT ARRAY RealPts{
datasize 2/ 1+ FLOAT ARRAY ImagPts{

\ Expects to work with an UNNORMALIZED Hartley transform result. 
\ Performs the normalization on the fly.

: FHT->FFT
     1e  datasize S>F FSQRT  F/  FRAME| a |
     datasize 2/  
         1 ?DO
                data{ I } F@
                data{ datasize I - } F@   F2DUP 
             F+ a F* RealPts{ I } F! 
             F- a F* ImagPts{ I } F! 
          LOOP 
     |FRAME ; 


\ Calculate the power spectrum from the FHT algorithm output.
\ Expects to work with an UNNORMALIZED Hartley transform result. 
\ Performs the normalization on the fly.

datasize 2/ 1+ FLOAT ARRAY PowerF{

: FHT->POWER     
        datasize 2/  
        1 ?DO
           data{ I } F@ FDUP F*  data{ datasize I - } F@ FDUP F*  
           F+ F2*  datasize S>F F/  PowerF{ I } F! 
         LOOP ; 


\ Generate a test function.

datasize FLOAT ARRAY InputData{

: GENERATE     PI datasize 2/ S>F F/  0E  FRAME| a b |
          datasize  
          0 ?DO 
               a         FCOS   2E F*
               a   3E F* FCOS   3E F* F+
               a  10E F* FCOS   5E F* F+
               datasize 200 > IF a 200E F* FCOS  50E F* F+
                         THEN
               FDUP data{ I } F!  InputData{ I } F!
               b a F+  &a F!
           LOOP 
          |FRAME ;

1E-3 FCONSTANT noisefloor \ Smaller than this, a coefficient is noise

: SHOW-DATA     datasize 0 ?DO 
                    data{ I } F@ FABS noisefloor
                     F> IF  CR ." component " I 1- 4 .R ."  = "
                         data{ I } F@ FE.
                      THEN
                 LOOP ;

: SHOW-DIFF     0e
          datasize 0 ?DO 
                    data{ I } F@  
                    InputData{ I } F@  F- FABS F+
                 LOOP 
          datasize S>F F/
          CR ." Total weighted error = " FE. ;

: SINE-TEST     GENERATE  
          data{ datasize  fht  SHOW-DATA 
          data{ datasize ifht  SHOW-DIFF ;


: SHOW-FFT     GENERATE data{ datasize fht FHT->FFT
          datasize 2/  
          1 ?DO 
               ImagPts{ I } F@  RealPts{ I } F@  F2DUP
               FABS FSWAP FABS F+ noisefloor 
               F> IF     CR I 4 .R 2 SPACES
                       ." (Real, Imag) = (" FE. ." ,"  FE. ." )"
                ELSE   F2DROP  
                THEN
           LOOP ;

: SHOW-POWER     GENERATE data{ datasize fht FHT->POWER
          datasize 2/  
          1 ?DO 
               PowerF{ I } F@ FDUP noisefloor 
               F> IF CR I 4 .R 2 SPACES ." Power component = " FE.
                ELSE FDROP 
                THEN
           LOOP ;

: .SPEED
     GENERATE
     ." Testing..." CR 
      100 0 DO
           data{ datasize fht
           data{ datasize ifht
          LOOP
     ."  (100 64-point FHT + IFHT pairs)" 
     CR ." 80386    @ 33 MHz in iForth (80 bit) : 2.80 sec." 
     CR ." T800     @ 20 MHzin tForth (32 bit) : 3.54 sec." 
     CR ." RTX-2000 @ 10 MHz in F83, FFT+IFFT   : 1.7 sec." CR ;


: .SPEED-FHT
     GENERATE
     ." Testing..." CR 
     100 0 DO
           data{ datasize fht
         LOOP
     ."  (100 " datasize 0 .R ." -point real FHT's)" CR ;


: .ABOUT
     CR ." SINE-TEST for an example," 
     CR ." SHOW-FFT   computes an example FFT from the FHT," 
     CR ." SHOW-POWER computes an example power spectrum from the FHT,"
     CR ." .SPEED     demonstrates conversion speed FHT + IFHT," 
     CR ." .SPEED-FHT demonstrates conversion speed FHT." ;

     CR .ABOUT


