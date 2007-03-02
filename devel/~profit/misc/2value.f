\ Аналог ~ygrek/lib/2value.f
\ Вот только не 2TO , а просто TO
REQUIRE /TEST ~profit/lib/testing.f

: _2CONSTANT-CODE R@ @ R> 9 + @ ;
: _2TOVALUE-CODE R@ ! R> 9 - ! ;

: 2VALUE ( d "<spaces>name" -- )
  HEADER
  ['] _2CONSTANT-CODE COMPILE,
  SWAP , \ first cell
  ['] _2TOVALUE-CODE COMPILE,
  , \ second cell
;


/TEST

: foo S" foo" ;
foo 2VALUE s

: r
CR s TYPE 
S" bar" TO s
CR s TYPE ;
r