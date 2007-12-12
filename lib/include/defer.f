\ http://www.forth200x.org/deferred.html
\ Deferred words
\ Accepted at the 2005 Forth200x meeting

\ На случай, для совместимости.

: DEFER ( "<spaces>name" -- )
  VECT
;
: IS
\ Interpretation: ( xt "<spaces>name" -- )
\ Compilation: ( "<spaces>name" -- )
\ Run-time: ( xt -- )
  POSTPONE TO
; IMMEDIATE

: DEFER@ ( xt1 -- xt2 )
  BEHAVIOR
;
: DEFER! ( xt2 xt1 -- )
  BEHAVIOR!
;
: ACTION-OF
\ Interpretation: ( "<spaces>name" -- xt )
\ Compilation: ( "<spaces>name" -- )
\ Run-time: ( -- xt )
  STATE @ IF
   POSTPONE ['] POSTPONE DEFER@
  ELSE
   ' DEFER@
  THEN
; IMMEDIATE
