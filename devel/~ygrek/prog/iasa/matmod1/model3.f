( Модель роста народонаселения Пригожина
  N'=r*N*[K-N]+m*N=[rK-m]N-rNN
)

VOCABULARY Model3
GET-CURRENT
ALSO Model3 DEFINITIONS

 0.1e FVALUE r      \ рождаемость
 1e r F- FVALUE m   \ смертность
 120e FVALUE K      \ возможности среды
 10e FVALUE N0     \ начальное значение населения
: limit \ стационарная точка
 K m r F/ F- 
;

: func
  FSWAP FDROP
  FDUP K r F* m F- F*
  FSWAP FDUP F* r F* F-
; 
: solution FDROP 0e ; 
: init  
   0.01e FTO step
   1E FTO interval
   0e FTO tn
   N0 FTO fn
   0e FTO err-norma
; 
PREVIOUS
SET-CURRENT
