( Модель хищник-жертва Вольтерра
  x'=[A1*y-B1]*x
  y'=[A2-B2*x]*y
)
VOCABULARY Model6
ALSO Model6 DEFINITIONS

1e FVALUE Ax \ Норма поедания
1e FVALUE Ay \ Скорость прироста
2e FVALUE Bx \ Природная смертность
1e FVALUE By \ Норма поедания

1e FVALUE x0   1e FVALUE y0

0e FVALUE xn
0e FVALUE yn

: func_x ( tn fn=xn -- f )
 FSWAP FDROP 
 Ax yn F* Bx F- 
 ( xn zn ) F*
;
: func_y ( tn yn -- f )
 FSWAP FDROP
 By xn F* Ay FSWAP F- 
 ( yn zn ) F*
;
: solution FDROP 0e ;
: init
   0.01e FTO step
   10E FTO interval
   0e FTO tn 
   x0 FTO xn
   y0 FTO yn
   0e FTO err-norma 
; 
ONLY FORTH DEFINITIONS
ALSO Model6

' init TO difur-init
' solution TO difur-solution

: runRK
  xn FTO fn ['] func_x TO difur-func RungeKutta
   FDUP 0e F< IF FDROP 0e THEN FTO xn 
  yn FTO fn ['] func_y TO difur-func RungeKutta 
   FDUP 0e F< IF FDROP 0e THEN FTO yn \ ограничения по нулям не забыли

  tn step F+ FTO tn
;

PREVIOUS