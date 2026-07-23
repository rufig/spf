\ lsp/tests/json-test.f -- unit test for lsp/json.f
\ run:  spf64.exe lsp\tests\json-test.f   (expects PASS lines + ALL PASS)

REQUIRE JSON-PARSE lsp/json.f

DECIMAL

VARIABLE #FAIL

: CHECK { flag a u -- }
  flag IF S" PASS " TYPE ELSE S" FAIL " TYPE #FAIL 1+! THEN
  a u TYPE CR
;

: OB= ( a u -- flag )  OB-A @ OB-LEN @ COMPARE 0= ;

\ J' : copy a string replacing ' with " -- lets tests write JSON with single quotes
CREATE JBUF 1024 ALLOT
: J' { a u \ c -- a2 u2 }
  u 0 ?DO
    a I + C@ -> c
    c [CHAR] ' = IF [CHAR] " -> c THEN
    c JBUF I + C!
  LOOP
  JBUF u
;

: T-OB
  OB-INIT
  S" ab" +S -7 +NUM
  S" ab-7" OB= S" ob-basic" CHECK
  OB-INIT
  S" a'b" J' +JSTR                              \ a"b -> "a\"b"
  S" 'a\'b'" J' OB= S" jstr-esc" CHECK
  OB-INIT
  1 +U4
  S" \u0001" OB= S" u4" CHECK
;

: T-PARSE1 { \ x t -- }
  S" {'jsonrpc':'2.0','id':1,'method':'initialize','params':{'rootUri':'file:///d%3A/PRO/spf','capabilities':{}}}"
  J' JSON-PARSE -> t -> x
  t JSON_OBJECT = S" parse-obj" CHECK
  x t S" method" J-S@ S" initialize" COMPARE 0= S" method" CHECK
  x t S" id" J-N@ 1 = S" id" CHECK
  x t S" params" J@ IF
    S" rootUri" J-S@ S" file:///d%3A/PRO/spf" COMPARE 0= S" rooturi" CHECK
  ELSE FALSE S" params" CHECK THEN
  x t JSON-FREE-VALUE
;

: T-PARSE2 { \ x t -- }
  S" [1,-2,'tri',true,null]" J' JSON-PARSE -> t -> x
  t JSON_ARRAY = S" arr" CHECK
  x t JSON-COUNT 5 = S" arr-count" CHECK
  x t 1 JIDX@ IF JSON-N@ -2 = ELSE FALSE THEN S" arr-neg" CHECK
  x t 2 JIDX@ IF JSON-S@ S" tri" COMPARE 0= ELSE FALSE THEN S" arr-str" CHECK
  x t 3 JIDX@ IF JSON-B@ ELSE FALSE THEN S" arr-true" CHECK
  x t JSON-FREE-VALUE
;

CREATE EXP-ESC 8 ALLOT
: T-PARSE-ESC { \ x t a u -- }
  S" ['a\'b\\c\nЖx']" J' JSON-PARSE -> t -> x
  x t 0 JIDX@ IF
    JSON-S@ -> u -> a
    [CHAR] a EXP-ESC C!  [CHAR] " EXP-ESC 1+ C!  [CHAR] b EXP-ESC 2 + C!
    [CHAR] \ EXP-ESC 3 + C!  [CHAR] c EXP-ESC 4 + C!  10 EXP-ESC 5 + C!
    0xD0 EXP-ESC 6 + C!  0x96 EXP-ESC 7 + C!
    a u 8 UMIN EXP-ESC 8 COMPARE 0=  u 9 =  AND S" esc-utf8" CHECK
  ELSE FALSE S" esc-idx" CHECK THEN
  x t JSON-FREE-VALUE
;

: T-SURROGATE { \ x t a u -- }
  S" ['\ud83d\ude00']" J' JSON-PARSE -> t -> x   \ surrogate pair U+1F600 -> F0 9F 98 80
  x t 0 JIDX@ IF
    JSON-S@ -> u -> a
    u 4 =
    a C@ 0xF0 =  AND
    a 3 + C@ 0x80 =  AND
    S" surrogate" CHECK
  ELSE FALSE S" surr-idx" CHECK THEN
  x t JSON-FREE-VALUE
;

: T-BAD { \ err -- }
  S" {broken" ['] JSON-PARSE CATCH -> err
  err JSON_ERROR = S" bad-throw" CHECK
;

: T-ALL
  T-OB T-PARSE1 T-PARSE2 T-PARSE-ESC T-SURROGATE T-BAD
  #FAIL @ 0= IF S" ALL PASS" TYPE ELSE S" FAILURES!" TYPE THEN CR
;
T-ALL
BYE
