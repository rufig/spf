\ REQUIRE   Matrix ~ygrek/lib/matrix/matrix.f
REQUIRE Matrix ~ygrek/prog/iasa/nm1/matrix.f


0Matrix VALUE a
0Matrix VALUE b
0Matrix VALUE c
0Matrix VALUE t 
0Matrix VALUE MAIN
0Matrix VALUE ml
0Matrix VALUE mr
0e FVALUE temp
CREATE FPU 200 ALLOT

1e-5 FVALUE Epsilon

PRINT-EXP
\ 17 SET-PRECISION 
0 VALUE N 0 VALUE N-1

: FormBC 
 \ c = Ci
 N-1 0 DO 0e c I 0 MXY! LOOP
 N 0 DO a N-1 I MXY@ c N-1 I MXY! LOOP
 N-1 0 DO
  N 1 DO
   I J 1+ = IF 1e ELSE 0e THEN
   c J I MXY!
  LOOP
 LOOP
 \       -1
 \ b = Ci
 N 1 DO 0e b I N-1 MXY! LOOP
 N-1 0 DO a N-1 I 1+ MXY@ a N-1 0 MXY@ F/ FNEGATE b 0 I MXY! LOOP
 1e a N-1 0 MXY@ F/ b 0 N-1 MXY!
 N 1 DO
  N-1 0 DO
   I 1+ J = IF 1e ELSE 0e THEN
   b J I MXY!
  LOOP
 LOOP
;
: FindLambdaMax ( m1 -- F: lambda_max )
 \ m1 - Frobenius Form
 1 N t ReMatrix
 N 0 DO 1e t 0 I MXY! LOOP
 0e
 BEGIN
\ t VNorma/ 
 DUP t MM* DUP VNorma  
 \ t MPrint
 t VNorma t MCopy t VNorma/
 F/ ( FDUP F.  CR ) FSWAP FOVER F- FABS 1e-15 F<
 UNTIL
 DROP
;
: ?Eigen ( matrix vector F: lambda -- F: ¦¦Av-lambda*v¦¦)
 >R 
 ( matrix ) R@ MM*  R@ ( F: lambda) -1e F* MConst* 
 R@ SWAP MM+
 R> VNorma 
;
: FMIDDLE FOVER FOVER F+ 2e F/ ;
: bisect ( xt F: a b -- F: x )
  BEGIN

\   CR FOVER F.
   FMIDDLE \ FDUP F.
\   FOVER F. CR
   FDUP DUP EXECUTE    
   FABS Epsilon F< INVERT
  WHILE
      FOVER DUP EXECUTE    
      FOVER DUP EXECUTE    
      F* F0< IF FROT FDROP FSWAP ELSE FSWAP FDROP THEN
  REPEAT
  FSWAP FDROP FSWAP FDROP DROP
;

: FI** FSWAP FDUP 0e F= IF FDROP FDROP 1e EXIT THEN
       FDUP F0< IF FNEGATE FSWAP F** FNEGATE ELSE FSWAP F** THEN ;

: polinom ( F: x -- f<x> ) 
 FTO temp
 FPU FSAVE \ сохраним стек во избежание переполнения
 temp
 0e 
 N 0 DO
  FOVER I DS>F FI** a N-1 I MXY@ F* F-
 LOOP
 FSWAP N DS>F FI** F+ 
 FTO temp
 FPU FRSTOR
 temp
;  

: Lambda-Vector ( F: lambda -- )
   ( uses a b t )
  a b MCopy
  1e FSWAP F/ ( 1/lambda)
  b MConst*
  1 N t ReMatrix
  N-1 0 DO 0e t 0 I MXY! LOOP
  1e t 0 N-1 MXY!
  N 0 DO
\   t MPrint                       
   b t MM* t MCopy
   N I 1+ ?DO 0e t 0 I MXY! LOOP
   1e t 0 N-1 MXY!
  LOOP
;


: lambda ( F: a b )
 ['] polinom ( F: a b ) bisect FDUP
 Lambda-Vector
 mr t MM* t MCopy t VNorma/ t MPrint
 MAIN t FDUP ?Eigen Epsilon F< IF ." OK " THEN F. CR CR
S" ===================" TYPE CR CR
;
          
: main
 S" matrix.dat" MAIN LoadMatrix
 MAIN .dimX TO N \ размерность матрицы поскольку квадратная
 N 1- TO N-1 \ индекс последнего элемента в строке/столбце поскольку [0..N-1]
 N N Matrix TO c
 N N Matrix TO b 
 N N Matrix TO ml
 N N Matrix TO mr

 \ Макс и Мин Собственные Числа
 MAIN a MCopy
 a FindLambdaMax
 t MPrint
 \ t c MCopy 
 a t FDUP ?Eigen Epsilon F< IF ." OK " THEN FDUP F. 

 b IdMatrix 
 b FDUP MConst*
 MAIN c MCopy
 c -1e MConst*
 b c MM+         \ b=lambda*I - A
 \ b MPrint
 b FindLambdaMax
 FDROP
 CR CR t MPrint
 b t MM* 
 N 0 DO DUP 0 I MXY@ FABS Epsilon F< INVERT  
             IF DUP 0 I MXY@ t 0 I MXY@ F/ LEAVE THEN 
 LOOP           \ lambda_max-lambda_min
 DROP
 t c MCopy
 b c FDUP ?Eigen Epsilon F< IF ." ok " THEN \ FDUP F. 
 F- \ lambda_min
 a t FDUP ?Eigen Epsilon F< IF ." OK " THEN F. 

 \ Данилевский
CR S" -------------------" TYPE CR CR
 MAIN a MCopy
 ml IdMatrix mr IdMatrix
 N N Matrix TO c
 N N Matrix TO b 

 \ a mr MCopy
( a MPrint
 c MPrint
 b MPrint)
 N-1 0 DO
  FormBC
 mr c MM* mr MCopy
 b ml MM* ml MCopy
\  b MPrint a MPrint c MPrint
  b a MM* a MCopy 
  a c MM* a MCopy
 a MPrint      
 LOOP
\ ml MPrint mr MPrint
\ ml t MM* t MCopy 
\ t mr MM* MPrint 
S" -------------------" TYPE CR CR
 \ a - Frobenius
 \ ml*A*mr=a 
 1e  3e lambda
 3e  5e lambda
 5e  7e lambda 
 7e 10e lambda
 CR CR DEPTH . FDEPTH .
;

S" nm1.log" W/O CREATE-FILE THROW TO H-STDOUT
main
BYE
: sd FSIN ;
' sd -10e 0e bisect F. 
