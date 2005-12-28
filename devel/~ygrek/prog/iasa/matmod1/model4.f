( Односекторная модель экономической динамики Соллоу
  при условии Кобба-Дугласа
  k' = s*a*[k**alpha]-[mju+g]*k
)
VOCABULARY Model4
GET-CURRENT
ALSO Model4 DEFINITIONS

\ Коэфициенты для Украины на 1999 г.
0.3e FVALUE alpha 
0.1e FVALUE mju    \ норма амортизации
0.1e FVALUE g      \ прирост населения (модель Мальтюса)
2.5e FVALUE a      \ коэф развития экономики
0.2e FVALUE s      \ норма накопления
0.8e FVALUE k0     \ начальное значение капитало-озброености

: limit \ стационарная точка
 s a F*
 g mju F+
 F/ FLN
 1e 1e alpha F- F/ 
 F* FEXP 
;

: func 
 FSWAP FDROP 
 FDUP 
 FLN alpha F* FEXP s F* a F* FSWAP 
 mju g F+ F* 
 F-
;
: solution FDROP 0e ;
: init
   0.05e FTO step
   60E FTO interval
   0e FTO tn 
   k0 FTO fn
   0e FTO err-norma 
; 
PREVIOUS
SET-CURRENT
