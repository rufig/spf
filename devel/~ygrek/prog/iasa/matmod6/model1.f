( Модель полёта снаряда
  v' = -c*ro*S*v*v/[2*m] - g*sin[Teta]
  Teta' = -g*cos[Teta]/v
  x'=v*cos[Teta]
  y'=v*sin[Teta]
)

VOCABULARY Model1
ALSO Model1 DEFINITIONS

10e FVALUE show_time
0 VALUE flag

  15e FVALUE m 
  50e FVALUE v   
0.07e FVALUE S
 0.6e FVALUE Teta
1.29e FVALUE ro
9.83e FVALUE g
 0.2e FVALUE c

floats
 xn x0 xmax
 yn y0 ymax
 vn Tn
 vEnd TEnd tEnd
 ;

\ v' = -c*ro*S*v*v/[2*m] - g*sin[Teta]
: func_v ( tn vn -- f )
 FSWAP FDROP 
 FDUP F* S F* ro F* c F*
 2e F/ m F/
 FNEGATE 
 g Tn FSIN F* F-
;

\  Teta' = -g*cos[Teta]/v
: func_T ( tn Tn -- f )
  FSWAP FDROP
  FCOS g F* vn F/ FNEGATE 
;

\  x'=v*cos[Teta]
: func_x ( tn xn -- f)
 FDROP FDROP
 Tn FCOS vn F*
;
\  y'=v*sin[Teta]
: func_y ( tn yn -- f)
 FDROP FDROP
 Tn FSIN vn F*
;

: solution FDROP 0e ;
: init
   0.01e FTO step
   show_time FTO interval
   0e FTO tn 
   x0 FTO xn
   y0 FTO yn
   Teta FTO Tn
   v FTO vn
   0e FTO err-norma 
   0e FTO xmax
   0e FTO ymax
0e FTO TEnd 0e FTO tEnd 0e FTO vEnd
0 TO flag
; 

: prepareRK
 ['] init TO difur-init
 ['] solution TO difur-solution
 difur-init
;

: runRK

  yn -0.01e F< 
  IF
   vn 0.1e F< IF -0.02e FTO yn 0e FTO vn
    ELSE
     yn FNEGATE FTO yn
     Tn FNEGATE FTO Tn
     vn 2e F/ FTO vn
     1 TO flag
    THEN
  ELSE
   yn FTO fn ['] func_y TO difur-func RungeKutta FTO yn
   xn FTO fn ['] func_x TO difur-func RungeKutta FTO xn 
   Tn FTO fn ['] func_T TO difur-func RungeKutta FTO Tn
   vn FTO fn ['] func_v TO difur-func RungeKutta FTO vn

   flag 0= IF
   tn FTO tEnd
   Tn FTO TEnd
   vn FTO vEnd
   THEN
  THEN 

  flag 0= IF
  xmax xn F< IF xn FTO xmax THEN
  ymax yn F< IF yn FTO ymax THEN
  THEN

  tn step F+ FTO tn
;

ONLY FORTH DEFINITIONS
