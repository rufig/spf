\ http://www.forth200x.org/deferred.html
\ Deferred words
\ Accepted at the 2005 Forth200x meeting


REQUIRE SYNONYM lib/include/wordlist-tools.f


: (ABORT-DEFERRED) ( -- )  TRUE ABORT" A deferred word is not initialized" ;

: DEFER ( "<spaces>name" -- )
  VECT
  ['] (ABORT-DEFERRED)  GET-CURRENT @ NAME>  BEHAVIOR!
;

SYNONYM IS TO
\ Interpretation: ( xt "<spaces>name" -- )
\ Compilation: ( "<spaces>name" -- )
\ Run-time: ( xt -- )

SYNONYM DEFER@ BEHAVIOR   ( xt1 -- xt2 )
SYNONYM DEFER! BEHAVIOR!  ( xt2 xt1 -- )

: ACTION-OF
\ Interpretation: ( "<spaces>name" -- xt )
\ Compilation: ( "<spaces>name" -- )
\ Run-time: ( -- xt )
  STATE @ IF
    POSTPONE [']  POSTPONE DEFER@
  ELSE
    '  DEFER@
  THEN
; IMMEDIATE
