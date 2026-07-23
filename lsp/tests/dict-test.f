\ lsp/tests/dict-test.f -- unit test for lsp/dict.f
\ run from D:\PRO\spf:  spf64.exe lsp\tests\dict-test.f

REQUIRE DICT-INIT lsp/dict.f

DECIMAL
VARIABLE #FAIL

: CHECK { flag a u -- }
  flag IF S" PASS " TYPE ELSE S" FAIL " TYPE #FAIL 1+! THEN
  a u TYPE CR
;

: .N ( n -- ) 0 <# #S #> TYPE SPACE ;

: T-SNAP { \ e -- }
  DICT-INIT
  S" live words: " TYPE #LIVE @ .N CR
  #LIVE @ 500 > S" live-count" CHECK
  S" DUP" FIND-LIVE 0<> S" find-dup" CHECK
  S" IF" FIND-LIVE -> e
  e 0<> S" find-if" CHECK
  e IF e WE-IMM? S" if-imm" CHECK ELSE FALSE S" if-imm" CHECK THEN
  S" DUP" FIND-LIVE -> e
  e IF e WE-IMM? 0= S" dup-not-imm" CHECK ELSE FALSE S" dup-not-imm" CHECK THEN
  S" dup" FIND-LIVE 0= S" case-sensitive" CHECK
  S" dup" FIND-LIVE-CI 0<> S" ci-fallback" CHECK
  S" NO-SUCH-WORD-XYZ" FIND-LIVE 0= S" find-miss" CHECK
;

: T-WDB { \ e -- }
  S" D:\PRO\spf-x64\src\runtime\spf64.exe.wdb" WDB-LOAD
  S" D:\PRO\spf-x64\src\seed\seedw.wdb" WDB-LOAD
  S" wdb words: " TYPE #WDB @ .N CR
  #WDB @ 500 > S" wdb-count" CHECK
  S" CASE" FIND-WDB -> e
  e 0<> S" wdb-case" CHECK
  e IF
    e WE-FILE S" ext-core.f" COMPARE 0= S" wdb-case-file" CHECK
    e we.line @ 13 = S" wdb-case-line" CHECK
  ELSE FALSE S" wdb-case-file" CHECK FALSE S" wdb-case-line" CHECK THEN
  S" DUP" FIND-WDB -> e
  e 0<> S" wdb-dup" CHECK
  e IF e WE-FILE S" prims.f" COMPARE 0= S" wdb-dup-file" CHECK
  ELSE FALSE S" wdb-dup-file" CHECK THEN
  S" no-file.wdb" WDB-LOAD                \ must not throw
  TRUE S" wdb-missing-ok" CHECK
;

: T-ALL
  T-SNAP T-WDB
  #FAIL @ 0= IF S" ALL PASS" TYPE ELSE S" FAILURES!" TYPE THEN CR
;
T-ALL
BYE
