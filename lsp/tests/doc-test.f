\ lsp/tests/doc-test.f -- document store + diagnostics test
\ run from D:\PRO\spf:  spf64.exe lsp\tests\doc-test.f

REQUIRE DOC-OPEN lsp/doc.f

DECIMAL
VARIABLE #FAIL
: CHECK { flag a u -- }
  flag IF S" PASS " TYPE ELSE S" FAIL " TYPE #FAIL 1+! THEN
  a u TYPE CR
;
: .N ( n -- ) 0 <# #S #> TYPE SPACE ;

CREATE TDOC 1024 ALLOT
VARIABLE TDOC-U
: +T ( a u -- )  TDOC TDOC-U @ + SWAP DUP TDOC-U +! MOVE ;
: +TNL ( -- )  10 TDOC TDOC-U @ + C! 1 TDOC-U +! ;

: BUILD-DOC
  0 TDOC-U !
  S" \ demo file" +T +TNL
  S" : SQUARE ( n -- n^2 ) DUP * ;" +T +TNL
  S" : CUBE { n \ t -- } n SQUARE n * -> t t . ;" +T +TNL
  S" VARIABLE COUNTER" +T +TNL
  S" : BUMP COUNTER 1+! FROBNICATE 0x1F + ;" +T +TNL
;

: T-OPEN { \ d -- }
  DICT-INIT
  DEFS-INIT
  BUILD-DOC
  S" file:///d%3A/test.f" TDOC TDOC-U @ DOC-OPEN -> d
  d 0<> S" open" CHECK
  S" file:///d%3A/test.f" FIND-DOC d = S" find-doc" CHECK
  d doc.#lines @ 6 = S" lines" CHECK              \ 5 lines + empty tail
  d doc.#defs @ 4 = S" defs" CHECK                \ SQUARE CUBE COUNTER BUMP
  d S" SQUARE" FIND-DOC-DEF 0<> S" def-square" CHECK
  d S" SQUARE" FIND-DOC-DEF de.line @ 1 = S" def-line" CHECK
  d doc.#diags @ 1 = S" one-diag" CHECK           \ only FROBNICATE unknown
  d doc.diags @ ?DUP IF
    DUP dg.name-a @ SWAP dg.name-u @ S" FROBNICATE" COMPARE 0= S" diag-name" CHECK
  ELSE FALSE S" diag-name" CHECK THEN
  d 1 DOC-LINE S" : SQUARE ( n -- n^2 ) DUP * ;" COMPARE 0= S" doc-line" CHECK
  d 1 2 WORD-AT S" SQUARE" COMPARE 0= S" word-at" CHECK
  d 1 0 WORD-AT S" :" COMPARE 0= S" word-at-colon" CHECK
  d 4 30 WORD-AT S" 0x1F" COMPARE 0= S" word-at-num" CHECK
;

: T-CHANGE { \ d -- }
  S" file:///d%3A/test.f" FIND-DOC -> d
  d S" : OK DUP ;" DOC-SET-TEXT
  d doc.#diags @ 0= S" rediag-clean" CHECK
  d doc.#defs @ 1 = S" redefs" CHECK
  S" file:///d%3A/test.f" DOC-CLOSE
  S" file:///d%3A/test.f" FIND-DOC 0= S" closed" CHECK
;

: T-ALL
  T-OPEN T-CHANGE
  #FAIL @ 0= IF S" ALL PASS" TYPE ELSE S" FAILURES!" TYPE THEN CR
;
T-ALL
BYE
