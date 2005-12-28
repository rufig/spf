( Модель роста народонаселения Фергюльста
  N'=mju*N*[K-N]
)
VOCABULARY Model2
GET-CURRENT
ALSO Model2 DEFINITIONS

 0.02e FVALUE mju    \ прирост ABS(mju)<=1
  120e FVALUE K      \ возможности среды
   10e FVALUE N0     \ начальное значение населения
: limit  K ; \ стационарная точка

: func
  FSWAP FDROP
  FDUP FNEGATE K F+
  F* 
  mju F*
;
: solution FDROP 0e ; 
: init
   0.01e FTO step
   3E FTO interval
   0e FTO tn 
   N0 FTO fn 
   0e FTO err-norma 
;

PREVIOUS
SET-CURRENT