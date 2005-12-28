( Модель гонки вооружений Ричардсона
  x'=ay-mx+r
  y'=bx-ny+s
)
VOCABULARY Model5
GET-CURRENT
ALSO Model5 DEFINITIONS

1e FVALUE a 1e FVALUE b  \ темпы гонки, ресурсы страны >0
1e FVALUE m 1e FVALUE n  \ темпы затрат на вооружение  >0
-0.2e FVALUE r -0.2e FVALUE s    \ степень агрессивности       любые
\ a,m,r - Magenta  b,n,s - Yellow

0e FVALUE x0   0e FVALUE y0

0e FVALUE xn
0e FVALUE yn

: func_x ( tn fn=xn -- f )
 FSWAP FDROP 
 m F* FNEGATE
 yn a F* F+
 r F+
;
: func_y
 FSWAP FDROP
 n F* FNEGATE
 xn b F* F+
 s F+
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

PREVIOUS
SET-CURRENT
