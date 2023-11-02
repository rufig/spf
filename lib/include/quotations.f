\ 2023-10-10 ruv

\ See:
\   devel/~pinka/lib/lambda.f (since 2000)
\   https://github.com/Forth-Standard/forth200x/blob/master/quotations.txt
\   https://github.com/Forth-Standard/forth200x/blob/master/meetings/minutes2017.md#d-quotations

\ NB: local variables (by lib/ext/locals.f) cannot be used within quotations
\ (they are not compatible yet)


REQUIRE AHEAD   lib/include/tools.f


\ Interpretation: ( -- ) ( C: -- quotation-sys colon-sys )
\ Compilation: ( C: -- quotation-sys colon-sys )
: [:
  \ Interpretation ( -- xt 0 )
  \ Compilation ( -- 0|xt.prev orig xt )
  STATE @ 0= IF :NONAME 0 EXIT THEN
  LAST-NON
  POSTPONE  AHEAD
  HERE  DUP TO LAST-NON
; IMMEDIATE

\ Interpretation: ( -- xt ) ( C: quotation-sys colon-sys -- )
\ Compilation: ( C: quotation-sys colon-sys -- )
: ;]
  ( 0 -- | x orig xt -- ) \ Run-time: ( -- xt )
  DUP 0= IF DROP POSTPONE ; EXIT THEN
  >R
  POSTPONE EXIT
  POSTPONE THEN
  R> LIT,
  TO LAST-NON
; IMMEDIATE
