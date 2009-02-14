\ $Id$
\ 
\ Dynamically scoped name-value pairs
\ (probably useful for passing many arguments around)

REQUIRE new-hash ~pinka/lib/hash-table2.f
REQUIRE KEEP! ~profit/lib/bac4th.f
REQUIRE /TEST ~profit/lib/testing.f

USER _env

\ Current environment
: env ( -- h ) _env @ ;

\ Start new environment block, destroy it on backtracking
\ Hides previous environment
: [env] ( <--> )
  PRO
  10 new-hash _env KEEP!
  CONT
  env del-hash ;

\ Bind value to name in current environment
: env! ( `val `name -- ) env HASH! ;

\ Get name binding in current environment
: env@ ( `name -- `val ) env HASH@ ;

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE AsQWord ~pinka/spf/quoted-word.f

: test ( `v -- ? n ) `key env@ COMPARE 0= env hash-count ;

: inner ( -- ? n )
  [env]
  `value `key env!
  `value2 `key2 env!
  `value test ;

: outer ( -- ? n )
  [env]
  `value-prev `key env!
  inner
  `value-prev test ;

TESTCASES env
(( env -> 0 ))
(( inner -> TRUE 2 ))
(( env -> 0 ))
(( outer -> TRUE 2 TRUE 1 ))
(( env -> 0 ))
END-TESTCASES


