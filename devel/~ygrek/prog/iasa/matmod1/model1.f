( Модель нагревания Ньютона
  T'= -tau*[T-Tc]
)
VOCABULARY Model1
GET-CURRENT
ALSO Model1 DEFINITIONS

100e FVALUE Tc    \ Температура среды 
0.1e FVALUE tau   \ теплопроводность?
70e  FVALUE T0    \ Начальная температура тела
: limit Tc ; \ стационарная точка

: func FSWAP FDROP Tc F- tau F* FNEGATE ; 
: solution tau F* FNEGATE FEXP Tc T0 F- F* FNEGATE 
   Tc F+ ; 
: init 
   0.05e FTO step
   60E FTO interval
   0e FTO tn 
   T0 FTO fn 
   0e FTO err-norma 
; 
PREVIOUS
SET-CURRENT