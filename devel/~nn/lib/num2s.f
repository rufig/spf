DECIMAL
: DOUBLE>S ( d - a u) DUP >R DABS <# #S R> SIGN #> ;
: N>S ( u -- addr u)  S>D DOUBLE>S ;
: NB>S ( n base -- a u )
     BASE @ >R BASE !
     N>S ( или DUP ABS S>D <# #S ROT SIGN #>)
     R> BASE ! ;
: N>H 16 NB>S ;