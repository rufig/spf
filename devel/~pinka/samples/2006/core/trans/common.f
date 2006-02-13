\ 10.Feb.2006 Fri 20:44

: XT, ( xt -- )
  COMPILE,
;
: T-SLIT ( addr u -- | addr u )
  POSTPONE SLITERAL
;
: T-XT ( i*x xt -- j*x )
  STATE @ IF XT, EXIT THEN
  EXECUTE
;
