\ lsp/tests/scan-test.f -- tokenizer + index + tree-scan test
\ run from D:\PRO\spf:  spf64.exe lsp\tests\scan-test.f

REQUIRE SCAN-TREE lsp/scan.f

DECIMAL
VARIABLE #FAIL

: CHECK { flag a u -- }
  flag IF S" PASS " TYPE ELSE S" FAIL " TYPE #FAIL 1+! THEN
  a u TYPE CR
;
: .N ( n -- ) 0 <# #S #> TYPE SPACE ;

\ --- walker smoke test on an in-memory buffer ---
CREATE TSRC 512 ALLOT
VARIABLE TSRC-U
: +T ( a u -- )  TSRC TSRC-U @ + SWAP DUP TSRC-U +! MOVE ;  \ append line text
: +TNL ( -- )  10 TSRC TSRC-U @ + C! 1 TSRC-U +! ;

VARIABLE #W  VARIABLE #D  VARIABLE #L
VARIABLE LAST-DEF-LINE  VARIABLE LAST-DEF-COL  VARIABLE LAST-DEF-KIND
CREATE LAST-DEF-NAME 64 ALLOT  VARIABLE LAST-DEF-NAME-U

: (T-DEF) { a u line col kind -- }
  #D 1+!
  a LAST-DEF-NAME u MOVE  u LAST-DEF-NAME-U !
  line LAST-DEF-LINE !  col LAST-DEF-COL !  kind LAST-DEF-KIND !
;
: (T-WORD) ( a u line col -- ) 2DROP 2DROP #W 1+! ;
: (T-LOCAL) ( a u -- ) 2DROP #L 1+! ;

: T-WALK
  0 TSRC-U !
  S" \ comment REQUIRE junk" +T +TNL
  S" : FOO { a b \ t -- } ( n -- n ) a b + -> t t ;" +T +TNL
  S" REQUIRE { lib/ext/locals.f" +T +TNL
  S" S:bad" +T +TNL
  S" VARIABLE BAR \ trailing" +T +TNL
  S" S~ ABORT" +T [CHAR] " TSRC TSRC-U @ + C! 1 TSRC-U +! S"  msg inside" +T [CHAR] " TSRC TSRC-U @ + C! 1 TSRC-U +! +TNL
  0 #W ! 0 #D ! 0 #L !
  ['] (T-DEF) TO ON-DEF
  ['] (T-WORD) TO ON-WORD
  ['] (T-LOCAL) TO ON-LOCAL
  ['] NOOP TO ON-ENDDEF
  TSRC TSRC-U @ WALK-F
  #D @ 2 = S" walk-defs" CHECK              \ FOO + BAR
  #L @ 3 = S" walk-locals" CHECK            \ a b t
  LAST-DEF-NAME LAST-DEF-NAME-U @ S" BAR" COMPARE 0= S" walk-lastdef" CHECK
  LAST-DEF-LINE @ 4 = S" walk-defline" CHECK
  LAST-DEF-KIND @ DK-VAR = S" walk-defkind" CHECK
;

\ --- definer table ---
: T-KINDS
  S" :" DEFINER-KIND DK-COLON = S" kind-colon" CHECK
  S" WINAPI64:" DEFINER-KIND DK-FFI = S" kind-ffi" CHECK
  S" FOO" DEFINER-KIND 0= S" kind-none" CHECK
;

\ --- index a real tree: lsp/ itself (small, contains our defs) ---
: T-TREE { \ e -- }
  DEFS-INIT
  0 #SCANNED !
  S" D:\PRO\spf\lsp" SCAN-TREE
  S" scanned files: " TYPE #SCANNED @ .N S"  defs: " TYPE #DEFS @ .N CR
  #SCANNED @ 4 > S" tree-files" CHECK
  S" WDB-LOAD" FIND-DEF -> e
  e 0<> S" tree-find" CHECK
  e IF
    e DE-FILE S" dict.f" SEARCH NIP NIP S" tree-file" CHECK
    e de.kind @ DK-COLON = S" tree-kind" CHECK
    e DE-TEXT S" WDB-LOAD" SEARCH NIP NIP S" tree-text" CHECK
  ELSE FALSE S" tree-file" CHECK FALSE S" tree-kind" CHECK FALSE S" tree-text" CHECK THEN
  S" no-such-def-xyz" FIND-DEF 0= S" tree-miss" CHECK
;

\ --- cp1251 -> utf8 ---
CREATE C51 4 ALLOT
: T-1251
  OB-INIT
  0xC0 C51 C!  0xFF C51 1+ C!  0x41 C51 2 + C!
  C51 3 +S1251
  OB-LEN @ 5 = S" 1251-len" CHECK                 \ D0 90 D1 8F 41
  OB-A @ C@ 0xD0 = OB-A @ 4 + C@ 0x41 = AND S" 1251-bytes" CHECK
;

: T-U16
  S" ABC" U16-LEN 3 = S" u16-ascii" CHECK
;

: T-ALL
  T-WALK T-KINDS T-TREE T-1251 T-U16
  #FAIL @ 0= IF S" ALL PASS" TYPE ELSE S" FAILURES!" TYPE THEN CR
;
T-ALL
BYE
