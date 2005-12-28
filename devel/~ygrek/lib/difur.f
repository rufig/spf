( 
  Модуль для решения дифуров
  yGREK heretix 
  06.Mar.2005
)

REQUIRE F.   lib/include/float2.f

PRINT-EXP

0e FVALUE tn 
0e FVALUE fn \ координаты текущей точки
0.01e FVALUE step \ шаг алгоритма 
2.E FVALUE interval \ длина интервала 

0e FVALUE err-norma

VECT difur-func ( F: x y -- F: f )
VECT difur-solution ( F: x -- f )
VECT difur-init \ установить начальные tn,fn ; обнулить err-norma
                \ указать interval и step

MODULE: DifUr_RungeKutta

: half 2e F/ ;
: F1 tn fn difur-func ;
: F2 tn step half F+
     F1 step half F* fn F+ difur-func ;
: F3 tn step half F+ 
     F2 step half F* fn F+ difur-func ;
: F4 tn step F+ 
     F3 step F* fn F+ difur-func ;

EXPORT

: RungeKutta ( -- F: f )
( Очередное значениу метода Рунге-Кутта 4-то порядка)
 F1 
 F2 2.E F* F+
 F3 2.E F* F+ 
 F4 F+
 step F* 
 6.E F/
 fn F+
;

: runRK RungeKutta FTO fn  tn step F+ FTO tn ;

: err-count
  tn difur-solution fn F- FABS FDUP F* err-norma F+ FTO err-norma
; 

: #steps ( - N ) interval step F/ F>DS ; \ кол-во шагов алгоритма при даном step

;MODULE

: output 
   tn F. SPACE fn F. 3 SPACES
   tn difur-solution FDUP F. SPACE
                 fn F- FABS F. SPACE 
;

  
( f'=-y*lny/x )
:NONAME FDUP FLN F* FSWAP F/ FNEGATE ; TO difur-func
\ f=exp(1/x)
:NONAME 1e FSWAP F/ FEXP ; TO difur-solution
\ f(1)=1
:NONAME 
 0.01e FTO step
 1e FTO interval
 1e FTO tn 
 1e FEXP FTO fn 
 0e FTO err-norma
; TO difur-init

\EOF
: check
 difur-init
 #steps 0 DO
  runRK err-count output CR
 LOOP
 err-norma FSQRT F.
;

check

