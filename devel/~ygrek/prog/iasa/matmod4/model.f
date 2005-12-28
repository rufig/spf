( Модель колебаний
  x''+2*delta*x'+w0*w0*x = f0*cos[w*t]

  y=x'
  y'+2*delta*y+w0*w0*x = f0*cos[w*t]
)
40e FVALUE show_time

VOCABULARY Model
ALSO Model DEFINITIONS

1e FVALUE delta \ Коэфициент затухания
1.4e FVALUE w0 \ Собственная частота ?
1e FVALUE f0 \ 
0.1e FVALUE w \

0.5e FVALUE x0 
0e FVALUE x0'

0e FVALUE xn
0e FVALUE yn

: func_x ( tn fn=xn -- f )
 FDROP FDROP 
 yn
;
 \ y' = f0*cos[w*t] - 2*delta*y - w0*w0*x
: func_y ( tn yn -- f )
  FSWAP w F* FCOS f0 F*
  FSWAP delta F* 2e F* F-
  w0 FDUP F* xn F* F-
;
: solution FDROP 0e ;
: init
   0.01e FTO step
   show_time FTO interval
   0e FTO tn 
   x0 FTO xn
   x0' FTO yn
   0e FTO err-norma 
; 
ONLY FORTH DEFINITIONS
ALSO Model

' init TO difur-init
' solution TO difur-solution

: runRK
  xn FTO fn ['] func_x TO difur-func RungeKutta FTO xn 
  yn FTO fn ['] func_y TO difur-func RungeKutta FTO yn

  tn step F+ FTO tn
;

PREVIOUS