: 2.E  
[ BASE @ HEX
 C7  C, 45  C, FC  C, 2  C,
 0  C, 0  C, 0  C, DB  C,
 45  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: 10.E  
[ BASE @ HEX
 C7  C, 45  C, FC  C, A  C,
 0  C, 0  C, 0  C, DB  C,
 45  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FPI       \ *
[ BASE @ HEX
 D9  C, EB  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLG2  
[ BASE @ HEX
 D9  C, EC  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLN2  
[ BASE @ HEX
 D9  C, ED  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FL2T  
[ BASE @ HEX
 D9  C, E9  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FL2E  
[ BASE @ HEX
 D9  C, EA  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: .E  
[ BASE @ HEX
 D9  C, EE  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: 1.E  
[ BASE @ HEX
 D9  C, E8  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F0=       \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 33  C, DB  C,
 D9  C, E4  C, DD  C, C0  C,
 D9  C, F7  C, 9B  C, DF  C,
 E0  C, 9E  C, 75  C, 6  C,
 C7  C, C3  C, FF  C, FF  C,
 FF  C, FF  C, 8B  C, C3  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F0<       \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 33  C, DB  C,
 D9  C, E4  C, DD  C, C0  C,
 D9  C, F7  C, 9B  C, DF  C,
 E0  C, 9E  C, 73  C, 6  C,
 C7  C, C3  C, FF  C, FF  C,
 FF  C, FF  C, 8B  C, C3  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F<               \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 33  C, DB  C,
 DE  C, D9  C, 9B  C, DF  C,
 E0  C, 9E  C, 72  C, 6  C,
 C7  C, C3  C, FF  C, FF  C,
 FF  C, FF  C, 8B  C, C3  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F=              \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 33  C, DB  C,
 DE  C, D9  C, 9B  C, DF  C,
 E0  C, 9E  C, 75  C, 6  C,
 C7  C, C3  C, FF  C, FF  C,
 FF  C, FF  C, 8B  C, C3  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FMAX  \ *
[ BASE @ HEX
 8B  C, D8  C, D8  C, D1  C,
 9B  C, DF  C, E0  C, 9E  C,
 72  C, 2  C, D9  C, C9  C,
 DD  C, C0  C, D9  C, F7  C,
 8B  C, C3  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FMIN  \ *
[ BASE @ HEX
 8B  C, D8  C, D8  C, D1  C,
 9B  C, DF  C, E0  C, 9E  C,
 77  C, 2  C, D9  C, C9  C,
 DD  C, C0  C, D9  C, F7  C,
 8B  C, C3  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FNEGATE   \ *
[ BASE @ HEX
 D9  C, E0  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FCOS  
[ BASE @ HEX
 D9  C, FF  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FSIN  
[ BASE @ HEX
 D9  C, FE  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FSINCOS  
[ BASE @ HEX
 D9  C, FB  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FABS    
[ BASE @ HEX
 D9  C, E1  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F*      \ * DE C9
[ BASE @ HEX
 DE  C, C9  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F+       \   DE C1
[ BASE @ HEX
 DE  C, C1  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F-        \ DE E9
[ BASE @ HEX
 DE  C, E9  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F/        \ DE F9
[ BASE @ HEX
 DE  C, F9  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FSQRT  
[ BASE @ HEX
 D9  C, FA  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FDROP   \ *
[ BASE @ HEX
 DD  C, C0  C, D9  C, F7  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FDUP    \ *
[ BASE @ HEX
 D9  C, C0  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FOVER   \ *
[ BASE @ HEX
 D9  C, C1  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FINT  
[ BASE @ HEX
 D9  C, FC  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FSWAP  \ *
[ BASE @ HEX
 D9  C, C9  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FROT  \ *
[ BASE @ HEX
 D9  C, CA  C, D9  C, C9  C,
 D9  C, CA  C, D9  C, C9  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FDEPTH   \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 9B  C, DF  C,
 E0  C, C1  C, E8  C, B  C,
 83  C, E0  C, 7  C, 74  C,
 5  C, F7  C, D8  C, 8D  C,
 40  C, 8  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F1+     \ *
[ BASE @ HEX
 D9  C, E8  C, DE  C, C1  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: D>F     \ *
[ BASE @ HEX
 8B  C, 5D  C, 0  C, 89  C,
 45  C, FC  C, 89  C, 5D  C,
 F8  C, DF  C, 6D  C, F8  C,
 8B  C, 45  C, 4  C, 8D  C,
 6D  C, 8  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F>D      \ *
[ BASE @ HEX
 8D  C, 6D  C, F8  C, DF  C,
 7D  C, 0  C, 87  C, 45  C,
 4  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: DF!  
[ BASE @ HEX
 DD  C, 18  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: DF@  
[ BASE @ HEX
 DD  C, 0  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F!  
[ BASE @ HEX
 DB  C, 38  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLOAT>DATA  
[ BASE @ HEX
 8D  C, 6D  C, F8  C, DD  C,
 5D  C, 0  C, 87  C, 45  C,
 4  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: DATA>FLOAT  
[ BASE @ HEX
 87  C, 45  C, 4  C, DD  C,
 45  C, 0  C, 8D  C, 6D  C,
 8  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F@  
[ BASE @ HEX
 DB  C, 28  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: SF!  
[ BASE @ HEX
 D9  C, 18  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: SF@  
[ BASE @ HEX
 D9  C, 0  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLN    \ *
[ BASE @ HEX
 D9  C, ED  C, D9  C, C9  C,
 D9  C, F1  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLNP1  \ *
[ BASE @ HEX
 D9  C, E8  C, DE  C, C1  C,
 D9  C, ED  C, D9  C, C9  C,
 D9  C, F1  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FLOG  ( F: r1 -- r2 ) \ *
[ BASE @ HEX
 D9  C, EC  C, D9  C, C9  C,
 D9  C, F1  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FEXP   \ *
[ BASE @ HEX
 D9  C, EA  C, DE  C, C9  C,
 D9  C, F4  C, D9  C, C9  C,
 8D  C, 64  C, 24  C, FC  C,
 DB  C, 1C  C, 24  C, 6A  C,
 4  C, DA  C, 34  C, 24  C,
 D9  C, F0  C, D9  C, E8  C,
 DE  C, C1  C, C7  C, C1  C,
 2  C, 0  C, 0  C, 0  C,
 5B  C, 5B  C, 3  C, CB  C,
 D8  C, C8  C, E2  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FEXPM1  
[ BASE @ HEX
 D9  C, EA  C, DE  C, C9  C,
 D9  C, C0  C, D9  C, C0  C,
 D9  C, FC  C, DE  C, E9  C,
 D9  C, F0  C, D9  C, E8  C,
 DE  C, C1  C, D9  C, FD  C,
 DD  C, D9  C, D9  C, E8  C,
 DE  C, E9  C, C3  C, 0  C,

BASE ! ] ;

: F**      \ *
[ BASE @ HEX
 D9  C, C9  C, D9  C, F1  C,
 D9  C, F4  C, D9  C, C9  C,
 8D  C, 64  C, 24  C, FC  C,
 DB  C, 1C  C, 24  C, 6A  C,
 4  C, DA  C, 34  C, 24  C,
 D9  C, F0  C, D9  C, E8  C,
 DE  C, C1  C, C7  C, C1  C,
 2  C, 0  C, 0  C, 0  C,
 5B  C, 5B  C, 3  C, CB  C,
 D8  C, C8  C, E2  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FTAN  \ *
[ BASE @ HEX
 D9  C, F2  C, DE  C, F9  C,

BASE ! ] ;

: FATAN  \ *
[ BASE @ HEX
 D9  C, E8  C, D9  C, F3  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FATAN2  
[ BASE @ HEX
 D9  C, F3  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FACOS  \ *
[ BASE @ HEX
 D8  C, C8  C, D9  C, E8  C,
 D9  C, C9  C, DE  C, E9  C,
 D9  C, FA  C, D9  C, E8  C,
 D9  C, F3  C, C7  C, 45  C,
 FC  C, 2  C, 0  C, 0  C,
 0  C, DA  C, 4D  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FASIN  
[ BASE @ HEX
 D9  C, C0  C, D8  C, C8  C,
 DB  C, 7D  C, F6  C, D9  C,
 E8  C, D8  C, 65  C, F6  C,
 D9  C, FA  C, D9  C, F3  C,
 C7  C, 45  C, FC  C, 2  C,
 0  C, 0  C, 0  C, DA  C,
 4D  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F>DEG  
[ BASE @ HEX
 C7  C, 45  C, FC  C, B4  C,
 0  C, 0  C, 0  C, DA  C,
 4D  C, FC  C, D9  C, EB  C,
 DE  C, F9  C, C3  C, 0  C,

BASE ! ] ;

: F>RAD  
[ BASE @ HEX
 D9  C, EB  C, DE  C, C9  C,
 C7  C, 45  C, FC  C, B4  C,
 0  C, 0  C, 0  C, DA  C,
 75  C, FC  C, C3  C, 0  C,

BASE ! ] ;

: FINIT  
[ BASE @ HEX
 9B  C, DB  C, E3  C, C3  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: SETFPUCW  ( u -- )
[ BASE @ HEX
 89  C, 45  C, FC  C, D9  C,
 6D  C, FC  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,

BASE ! ] ;

: GETFPUCW  ( -- u )     \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 9B  C, D9  C,
 7D  C, FC  C, 8B  C, 45  C,
 FC  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: DS>F     \ *
[ BASE @ HEX
 89  C, 45  C, FC  C, DB  C,
 45  C, FC  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F>DS      \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, DB  C, 5D  C,
 FC  C, 8B  C, 45  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F--DS      \ *
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, DB  C, 55  C,
 FC  C, 8B  C, 45  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: GETFPUSW  
[ BASE @ HEX
 8D  C, 6D  C, FC  C, 89  C,
 45  C, 0  C, 9B  C, DF  C,
 E0  C, C3  C, 0  C, 0  C,

BASE ! ] ;

: FLOG2  ( F: r1 -- r2 )
[ BASE @ HEX
 D9  C, E8  C, D9  C, C9  C,
 D9  C, F1  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F[LOG]  \ *        \ исп 2 регистра
[ BASE @ HEX
 D9  C, EC  C, D9  C, C9  C,
 D9  C, F1  C, D9  C, FC  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: TRUNC-MODE   \ *
[ BASE @ HEX
 9B  C, D9  C, 7D  C, FC  C,
 F  C, BA  C, 6D  C, FC  C,
 A  C, F  C, BA  C, 6D  C,
 FC  C, B  C, D9  C, 6D  C,
 FC  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: ROUND-MODE   \ *
[ BASE @ HEX
 9B  C, D9  C, 7D  C, FC  C,
 F  C, BA  C, 75  C, FC  C,
 A  C, F  C, BA  C, 75  C,
 FC  C, B  C, D9  C, 6D  C,
 FC  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: UP-MODE  
[ BASE @ HEX
 9B  C, D9  C, 7D  C, FC  C,
 F  C, BA  C, 75  C, FC  C,
 A  C, F  C, BA  C, 6D  C,
 FC  C, B  C, D9  C, 6D  C,
 FC  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: LOW-MODE  
[ BASE @ HEX
 9B  C, D9  C, 7D  C, FC  C,
 F  C, BA  C, 6D  C, FC  C,
 A  C, F  C, BA  C, 75  C,
 FC  C, B  C, D9  C, 6D  C,
 FC  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F10*    \ *
[ BASE @ HEX
 C7  C, 45  C, FC  C, A  C,
 0  C, 0  C, 0  C, DA  C,
 4D  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F10/    \ *
[ BASE @ HEX
 C7  C, 45  C, FC  C, A  C,
 0  C, 0  C, 0  C, DA  C,
 75  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F>ENV  ( addr -- )
[ BASE @ HEX
 9B  C, D9  C, 30  C, 8B  C,
 45  C, 0  C, 8D  C, 6D  C,
 4  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FENV>  ( addr -- )
[ BASE @ HEX
 D9  C, 20  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FSAVE  ( addr -- )
[ BASE @ HEX
 9B  C, DD  C, 30  C, 8B  C,
 45  C, 0  C, 8D  C, 6D  C,
 4  C, C3  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FRSTOR  ( addr -- )
[ BASE @ HEX
 DD  C, 20  C, 8B  C, 45  C,
 0  C, 8D  C, 6D  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: FD<      \ *
[ BASE @ HEX
 33  C, DB  C, 89  C, 45  C,
 FC  C, DA  C, 55  C, FC  C,
 9B  C, DF  C, E0  C, 9E  C,
 73  C, 6  C, C7  C, C3  C,
 FF  C, FF  C, FF  C, FF  C,
 8B  C, C3  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: `F1+  
[ BASE @ HEX
 C7  C, 45  C, FC  C, 1  C,
 0  C, 0  C, 0  C, DA  C,
 45  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: F**2  
[ BASE @ HEX
 D8  C, C8  C, C3  C, FE  C,
 FF  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: `F1-  
[ BASE @ HEX
 C7  C, 45  C, FC  C, 1  C,
 0  C, 0  C, 0  C, D8  C,
 65  C, FC  C, C3  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: _FLIT-CODE8  
[ BASE @ HEX
 5B  C, DD  C, 3  C, 83  C,
 C3  C, 8  C, FF  C, E3  C,

BASE ! ] ;

: _FLIT-CODE10  
[ BASE @ HEX
 5B  C, DB  C, 2B  C, 83  C,
 C3  C, A  C, FF  C, E3  C,

BASE ! ] ;

: RP+@  ( offs -- x )
[ BASE @ HEX
 8B  C, 44  C, 4  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: RP+  ( offs -- addr )
[ BASE @ HEX
 8D  C, 44  C, 4  C, 4  C,
 C3  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,
 0  C, 0  C, 0  C, 0  C,

BASE ! ] ;

: RP+!  ( x offs -- )
[ BASE @ HEX
 8B  C, 5D  C, 0  C, 89  C,
 5C  C, 4  C, 4  C, 8D  C,
 6D  C, 8  C, 8B  C, 45  C,
 FC  C, C3  C, 0  C, 0  C,

BASE ! ] ;

