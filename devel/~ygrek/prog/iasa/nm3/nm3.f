REQUIRE .F lib/include/float.f
REQUIRE [IF] lib/include/tools.f

0 VALUE DEBUG
: [DEBUG] POSTPONE [ DEBUG ] POSTPONE [IF] ; IMMEDIATE

PRINT-FIX
FLONG

10 VALUE N
0e FVALUE h

0e FVALUE error
0e FVALUE xn 0e FVALUE yn

0e FVALUE an  0e FVALUE an-1
0e FVALUE bn  0e FVALUE bn-1

0e FVALUE An 0e FVALUE Bn 0e FVALUE Cn

0 VALUE data 0 VALUE datb

: FSQR FDUP F* ;

\ -------------------------------- Краевые условия
2.243e FVALUE a
-0.168e FVALUE b
2.545e FVALUE c
-2.549e FVALUE d
-0.213e FVALUE e
: solution 1e  d xn F* e F+   F/
           c F+
           b xn F* F+
           a xn FSQR F* F+ ;
: deriv     2e a F* xn F* 
            b F+
             d   d xn F* e F+ FSQR  F/  F- ;
: deriv2    2e a F*  
            2e d FSQR F* 
            d xn F* e F+ FDUP FDUP F* F*  F/  F+ ;

: pi -0.5e xn F/ ;
: qi 0.8e ; 
: fi deriv2   pi deriv F* F+   solution qi F* F+ ;
2e FVALUE right 1.7e FVALUE left
1.2e FVALUE ka2
  1e FVALUE ka1
left FTO xn 
 deriv ka2 F* 
 solution F+ FVALUE f1
right FTO xn
 deriv FVALUE f2
\ --------------------------------

0e FVALUE Xi1 0e FVALUE Mju1 
0e FVALUE Xi2 0e FVALUE Mju2
0e FVALUE delitel

: h^2 h FSQR ;

: Ai 1e h^2 F/  0.5e h F/ pi F* F- ;
: Bi 1e h^2 F/  0.5e h F/ pi F* F+ ;
: Ci 2e h^2 F/  qi  F- ;

: ai Bn  Cn An an F* F- F/ ;
: bi An bn F* fi F-   Cn  An an F*  F- F/ ;

: run
  Ai FTO An Bi FTO Bn Ci FTO Cn 
  ai FTO an-1  bi FTO bn-1 
;

: F[] ( addr i ) F-SIZE @ * + ;
: F[]@ F[] F@ ;
: F[]! F[] F! ;

: main 
  right left F- N DS>F F/ FTO h

 right FTO xn
  -2e qi h^2 F* 2e F- F/
  ( Xi2) FTO Xi2 

  fi h^2 F* 
  pi f2 F* h^2 F* F- 
  2e h F* f2 F* F- 
  qi h^2 F* 2e F- F/
  ( Mju2) FTO Mju2 

 left FTO xn
  2e ka1 F* h F/ ka2 F/
  2e h^2 F/ F-
  pi ka1 F* ka2 F/ F-
  qi F+ FTO delitel

  -2e h^2 F/ delitel F/ 
  ( Xi1) FTO Xi1

  fi \ FNEGATE
  pi f1 F* ka2 F/ F-
  2e f1 F* h F/ ka2 F/ F+
  delitel F/ 
  ( Mju1) FTO Mju1

 [DEBUG]
  ." f1 = " f1 F. SPACE ." f2 = " f2 F. CR 
  ." Xi1 " Xi1 F. SPACE ." Mju1 " Mju1 F. CR
  ." Xi2 " Xi2 F. SPACE ." Mju2 " Mju2 F. CR
 [THEN]
  
  N 1+ F-SIZE @ * ALLOCATE THROW TO data
  N 1+ F-SIZE @ * ALLOCATE THROW TO datb

  left FTO xn 

  Xi1 FDUP data N F[]! FTO an
  Mju1 FDUP datb N F[]! FTO bn
  0 N 1- DO
   run
 [DEBUG] I . 
  ." An=" An h^2 F* F. SPACE
  ." Cn=" Cn h^2 F* F. SPACE 
  ." Bn=" Bn h^2 F* F. SPACE
  ." fi=" fi h^2 F* F. SPACE 
  CR
 [THEN] 
   an-1 FTO an  bn-1 FTO bn
   an data I F[]!  bn datb I F[]! 
   xn h F+ FTO xn
   -1 +LOOP
[DEBUG]
  CR
  N 1+ 0 DO
  I . ." alpha=" data I F[]@ F. SPACE ." beta=" datb I F[]@ F. SPACE CR
  LOOP
  CR
[THEN]
  
  Mju2  Xi2 datb 1 F[]@ F* F+
    1e  Xi2 data 1 F[]@ F* F- 
                           F/ FTO yn
  right FTO xn 
   0e FTO error
  N 0 DO
 [DEBUG]  xn F. SPACE yn F. SPACE solution F. SPACE [THEN]
  solution yn F- FABS 
 [DEBUG]  FDUP F.  CR [THEN]
  FDUP error F< IF FDROP ELSE FTO error THEN
  data I F[]@ yn F* datb I F[]@ F+ FTO yn
   xn h F- FTO xn
  LOOP
  [DEBUG] CR [THEN]
  ." Step " h F. SPACE ." Error " error FDUP F. CR
  data FREE THROW
  datb FREE THROW
;

: many 
 2000 TO N
 BEGIN
  main FDROP
  N 100 - TO N
  N 101 <  
 UNTIL
;
S" log.txt"  R/W CREATE-FILE THROW TO H-STDOUT

\ 10 TO N
\ main
 many
BYE
