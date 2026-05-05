\ 10.Feb.2006 Fri 20:44

: XT, ( xt -- )
  COMPILE,
;
: T-LIT ( x -- | x )
  [COMPILE] LITERAL \ it is specific to the Forth system implementation
;
: T-SLIT ( addr u -- | addr u )
  [COMPILE] SLITERAL \ it is specific to the Forth system implementation
;
: T-XT ( i*x xt -- j*x )
  STATE @ IF XT, EXIT THEN
  EXECUTE
;
: T-EXEC T-XT ;
