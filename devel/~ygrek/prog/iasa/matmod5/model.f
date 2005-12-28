( Модель автоколебаний
  q'' + [ R/L - M*S/[L*C]*[1-3*a/s*q*q ] ]*q' + 1/[L*C]*q = 0

  q'=x
  f[q']=0
)
100e FVALUE show_time

VOCABULARY Model
ALSO Model DEFINITIONS


  0e FVALUE R   1e4 FVALUE L 
  1e-2 FVALUE M  1e-4 FVALUE C
  2e FVALUE S
  2e FVALUE a 

0.1e FVALUE q0'
0e FVALUE q0

0e FVALUE xn
0e FVALUE yn

\ y = x'
: func_x ( tn fn=xn -- f )
 FDROP FDROP 
 yn
;

\ y' = [ M*S/[L*C]*[1-3*a/s*x*x ] - R/L ]*y - 1/[L*C]*x
: func_y ( tn yn -- f )
  FSWAP FDROP
  1e 3e a F* S F/ xn F* xn F* F- 
  L F/ C F/ M F* S F* 
  R L F/ F- 
  ( y ) F*
  xn L F/ C F/ F-
;
: solution FDROP 0e ;
: init
   0.01e FTO step
   show_time FTO interval
   0e FTO tn 
   q0 FTO xn
   q0' FTO yn
   0e FTO err-norma 
; 
ONLY FORTH DEFINITIONS
ALSO Model

' init TO difur-init
' solution TO difur-solution

: runRK
  1e5 yn FABS F< IF EXIT THEN
  xn FTO fn ['] func_x TO difur-func RungeKutta FTO xn 
  yn FTO fn ['] func_y TO difur-func RungeKutta FTO yn

  tn step F+ FTO tn
;

PREVIOUS
