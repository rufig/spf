\ lsp/dict.f -- the LSP server's knowledge of THIS spf64's dictionary.
\ Two sources:
\   * the live image: walk _VOC-LIST (guarded by (in-dict?), as WordByAddr does)
\     and each wordlist's nt chain via FOR-WORDLIST; per word: name, wordlist
\     title (VOC-NAME@), the IMMEDIATE bit (nt+8 length byte, bit 128);
\   * .wdb files (the (WLOG) TSV emitted at SAVE: name TAB addr TAB voc TAB
\     file TAB line) -- they add the defining file:line for baked words.
\ Entries live in a bump pool (allocated once, never freed).

REQUIRE { lib/ext/locals.f
REQUIRE JSON-PARSE lsp/json.f

DECIMAL

\ ======================== bump pool ========================

VARIABLE POOL-CUR   VARIABLE POOL-END
0 POOL-CUR !   0 POOL-END !

1048576 CONSTANT /POOL-CHUNK

: POOL-ALLOC { u \ a -- a }
  u 7 + -8 AND -> u
  POOL-CUR @ 0=  POOL-CUR @ u + POOL-END @ U>  OR IF
    /POOL-CHUNK ALLOCATE THROW -> a
    a POOL-CUR !  a /POOL-CHUNK + POOL-END !
  THEN
  POOL-CUR @  DUP u + POOL-CUR !
;

: POOL-S, { a u \ p -- p u }              \ copy a string into the pool, NUL-terminated
  u 1+ POOL-ALLOC -> p
  a p u MOVE  0 p u + C!  p u
;

\ ======================== word entries ========================

9 CELLS CONSTANT /WENTRY                  \ flags bit 0 = IMMEDIATE

: we.next   ( e -- a ) 0 CELLS + ;
: we.name-a ( e -- a ) 1 CELLS + ;
: we.name-u ( e -- a ) 2 CELLS + ;
: we.voc-a  ( e -- a ) 3 CELLS + ;
: we.voc-u  ( e -- a ) 4 CELLS + ;
: we.flags  ( e -- a ) 5 CELLS + ;
: we.file-a ( e -- a ) 6 CELLS + ;
: we.file-u ( e -- a ) 7 CELLS + ;
: we.line   ( e -- a ) 8 CELLS + ;

: WE-NAME ( e -- a u )  DUP we.name-a @ SWAP we.name-u @ ;
: WE-VOC  ( e -- a u )  DUP we.voc-a @ SWAP we.voc-u @ ;
: WE-FILE ( e -- a u )  DUP we.file-a @ SWAP we.file-u @ ;
: WE-IMM? ( e -- flag ) we.flags @ 1 AND 0<> ;

VARIABLE LIVE-HEAD   VARIABLE WDB-HEAD   VARIABLE #LIVE   VARIABLE #WDB
0 LIVE-HEAD !  0 WDB-HEAD !  0 #LIVE !  0 #WDB !

: WE-NEW { na nu va vu flags head \ e -- e }
  /WENTRY POOL-ALLOC -> e
  e /WENTRY ERASE
  na nu POOL-S, e we.name-u ! e we.name-a !
  va vu POOL-S, e we.voc-u !  e we.voc-a !
  flags e we.flags !
  head @ e we.next !
  e head !
  e
;

: UPCH ( c -- c' )  DUP [CHAR] a [CHAR] z 1+ WITHIN IF 32 - THEN ;

: S-CI= { a1 u1 a2 u2 -- flag }
  u1 u2 <> IF FALSE EXIT THEN
  u1 0 ?DO
    a1 I + C@ UPCH  a2 I + C@ UPCH <> IF FALSE UNLOOP EXIT THEN
  LOOP TRUE
;

: PREFIX-CI? { a1 u1 a2 u2 -- flag }      \ a2 u2 starts with a1 u1 (case-blind)
  u1 u2 > IF FALSE EXIT THEN
  u1 0 ?DO
    a1 I + C@ UPCH  a2 I + C@ UPCH <> IF FALSE UNLOOP EXIT THEN
  LOOP TRUE
;

: (FIND-IN) { a u head ci \ e -- e|0 }
  head @ -> e
  BEGIN e WHILE
    ci IF a u e WE-NAME S-CI= ELSE a u e WE-NAME COMPARE 0= THEN
    IF e EXIT THEN
    e we.next @ -> e
  REPEAT 0
;

: FIND-LIVE    ( a u -- e|0 )  LIVE-HEAD FALSE (FIND-IN) ;
: FIND-LIVE-CI ( a u -- e|0 )  LIVE-HEAD TRUE  (FIND-IN) ;
: FIND-WDB     ( a u -- e|0 )  WDB-HEAD  FALSE (FIND-IN) ;
: FIND-WDB-CI  ( a u -- e|0 )  WDB-HEAD  TRUE  (FIND-IN) ;

: EACH-LIVE ( xt -- )                     \ xt ( e -- ) over every live entry
  LIVE-HEAD @
  BEGIN DUP WHILE
    2DUP 2>R  SWAP EXECUTE  2R>
    we.next @
  REPEAT 2DROP
;

: EACH-WDB ( xt -- )
  WDB-HEAD @
  BEGIN DUP WHILE
    2DUP 2>R  SWAP EXECUTE  2R>
    we.next @
  REPEAT 2DROP
;

\ ======================== live snapshot ========================

VARIABLE CUR-VOC-A   VARIABLE CUR-VOC-U

: (SNAP-NT) { nt \ na nu -- }             \ FOR-WORDLIST handler
  nt NAME>STRING -> nu -> na
  nu 0= IF EXIT THEN
  na nu FIND-LIVE IF EXIT THEN            \ redefinitions: first hit (=newest) wins
  na nu  CUR-VOC-A @ CUR-VOC-U @
  nt 8 + C@ 128 AND IF 1 ELSE 0 THEN
  LIVE-HEAD WE-NEW DROP
  #LIVE 1+!
;

: DICT-INIT { \ node wid vna -- }
  _VOC-LIST @ -> node
  BEGIN node (in-dict?) WHILE
    node CELL+ -> wid
    wid VOC-NAME@ -> vna
    vna IF vna C@ 0= ELSE TRUE THEN IF
      S" FORTH" ELSE vna COUNT THEN
    CUR-VOC-U ! CUR-VOC-A !
    wid ['] (SNAP-NT) FOR-WORDLIST
    node @ -> node
  REPEAT
;

\ ======================== .wdb loading ========================

: FILE-SLURP { a u \ h sz buf -- a2 u2 }  \ whole file ("" on any error)
  a u R/O OPEN-FILE IF DROP S" " EXIT THEN -> h
  h FILE-SIZE IF 2DROP h CLOSE-FILE DROP S" " EXIT THEN DROP -> sz
  sz 1+ ALLOCATE IF DROP h CLOSE-FILE DROP S" " EXIT THEN -> buf
  buf sz h READ-FILE IF DROP h CLOSE-FILE DROP buf FREE DROP S" " EXIT THEN -> sz
  h CLOSE-FILE DROP
  0 buf sz + C!
  buf sz
;

9 CONSTANT TAB

: SPLIT-CH { a u c \ i -- a1 u1 a2 u2 }   \ split at first c: before, after (a2 u2 = "" if absent)
  0 -> i
  BEGIN i u < WHILE
    a i + C@ c = IF
      a i  a i + 1+  u i - 1-  EXIT
    THEN
    i 1+ -> i
  REPEAT
  a u  a u +  0
;

: -CR ( a u -- a u' )                     \ strip one trailing CR
  DUP IF 2DUP + 1- C@ 13 = IF 1- THEN THEN
;

: WDB-LINE { a u \ na nu va vu fa fu ln e -- }
  a u TAB SPLIT-CH 2SWAP -> nu -> na      ( addr+rest )
  TAB SPLIT-CH 2SWAP 2DROP                ( voc+rest ) \ addr field dropped
  TAB SPLIT-CH 2SWAP -> vu -> va
  TAB SPLIT-CH 2SWAP -> fu -> fa
  -CR ?NUM 0= IF 0 THEN -> ln
  nu 0= IF EXIT THEN
  na nu va vu 0 WDB-HEAD WE-NEW -> e
  fa fu POOL-S, e we.file-u ! e we.file-a !
  ln e we.line !
  #WDB 1+!
;

: WDB-LOAD { a u \ ba bu la lu -- }       \ load one .wdb file (silently skip on error)
  a u FILE-SLURP -> bu -> ba
  bu 0= IF EXIT THEN
  BEGIN bu WHILE
    ba bu 10 SPLIT-CH -> bu -> ba -> lu -> la
    la lu -CR DUP IF WDB-LINE ELSE 2DROP THEN
  REPEAT
  ba DROP                                 \ all strings are pool copies; the slurped buffer just stays
;
