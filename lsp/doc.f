\ lsp/doc.f -- open documents: text store, line table, per-document definition
\ index, unknown-word diagnostics, word-at-position.
\
\ A document's text is the client's UTF-8 (didOpen/didChange, full sync).
\ Reindex = two WALK-F passes: pass 1 collects the document's own definitions,
\ pass 2 checks every code token against (locals | doc defs | workspace defs |
\ live dictionary | .wdb) with numbers recognized by the Forth's own ?NUM
\ (decimal, then hex -- HEX-mode sources).  Per-document memory (defs, diags,
\ line table) lives in a small arena freed on every reindex.

REQUIRE SCAN-TREE lsp/scan.f

DECIMAL

\ ======================== arena ========================
\ block: [next][used] data...; ARENA var holds the newest block.

65536 CONSTANT /ARENA-BLOCK

: ARENA-FREE { avar \ b n -- }
  avar @ -> b
  BEGIN b WHILE b @ -> n  b FREE DROP  n -> b REPEAT
  0 avar !
;

: ARENA-ALLOC { avar u \ b -- a }
  u 7 + -8 AND -> u
  u /ARENA-BLOCK 2 CELLS - > IF -8 THROW THEN
  avar @ -> b
  b 0=  b IF b CELL+ @ u + /ARENA-BLOCK > ELSE TRUE THEN  OR IF
    /ARENA-BLOCK ALLOCATE THROW -> b
    avar @ b !  2 CELLS b CELL+ !  b avar !
  THEN
  b b CELL+ @ +  u b CELL+ +!
;

: ARENA-S, { avar a u \ p -- p u }        \ NUL-terminated copy into the arena
  avar u 1+ ARENA-ALLOC -> p
  a p u MOVE  0 p u + C!  p u
;

\ ======================== document record ========================

16 CELLS CONSTANT /DOC

: doc.next    ( d -- a ) 0 CELLS + ;
: doc.uri-a   ( d -- a ) 1 CELLS + ;
: doc.uri-u   ( d -- a ) 2 CELLS + ;
: doc.text-a  ( d -- a ) 3 CELLS + ;
: doc.text-u  ( d -- a ) 4 CELLS + ;
: doc.arena   ( d -- a ) 5 CELLS + ;
: doc.lines-a ( d -- a ) 6 CELLS + ;      \ cell array of line-start byte offsets
: doc.#lines  ( d -- a ) 7 CELLS + ;
: doc.defs    ( d -- a ) 8 CELLS + ;      \ /DENTRY chain (de.next) in the arena
: doc.#defs   ( d -- a ) 9 CELLS + ;
: doc.diags   ( d -- a ) 10 CELLS + ;
: doc.#diags  ( d -- a ) 11 CELLS + ;
: doc.reqs    ( d -- a ) 12 CELLS + ;     \ [next][a][u] chain: REQUIRE/INCLUDE paths as written
: doc.ctx     ( d -- a ) 13 CELLS + ;     \ [next][pa][pu] chain: canonical files in this doc's context

: DOC-URI  ( d -- a u )  DUP doc.uri-a @ SWAP doc.uri-u @ ;
: DOC-TEXT ( d -- a u )  DUP doc.text-a @ SWAP doc.text-u @ ;

VARIABLE DOCS-HEAD   0 DOCS-HEAD !

: FIND-DOC { a u \ d -- d|0 }
  DOCS-HEAD @ -> d
  BEGIN d WHILE
    a u d DOC-URI COMPARE 0= IF d EXIT THEN
    d doc.next @ -> d
  REPEAT 0
;

: EACH-DOC ( xt -- )                      \ xt ( d -- )
  DOCS-HEAD @
  BEGIN DUP WHILE
    2DUP 2>R  SWAP EXECUTE  2R>
    doc.next @
  REPEAT 2DROP
;

\ ======================== diagnostics ========================

7 CELLS CONSTANT /DIAG
: dg.next   ( g -- a ) 0 CELLS + ;
: dg.line   ( g -- a ) 1 CELLS + ;
: dg.col    ( g -- a ) 2 CELLS + ;
: dg.len    ( g -- a ) 3 CELLS + ;        \ UTF-16 units
: dg.name-a ( g -- a ) 4 CELLS + ;
: dg.name-u ( g -- a ) 5 CELLS + ;

200 CONSTANT MAX-DIAGS

\ ======================== per-doc walking ========================

VARIABLE CUR-DOC

\ pass 1: collect defs
: (DOC-DEF) { a u line col kind \ d e ta tu -- }
  CUR-DOC @ -> d
  d doc.arena /DENTRY ARENA-ALLOC -> e
  e /DENTRY ERASE
  d doc.arena a u ARENA-S, e de.name-u ! e de.name-a !
  line e de.line !  col e de.col !  kind e de.kind !
  a LINE-OF -> tu -> ta
  d doc.arena ta tu ARENA-S, e de.text-u ! e de.text-a !
  d doc.defs @ e de.next !  e d doc.defs !
  d doc.#defs 1+!
;

: FIND-DOC-DEF { doc a u \ e -- e|0 }
  doc 0= IF 0 EXIT THEN
  doc doc.defs @ -> e
  BEGIN e WHILE
    a u e DE-NAME COMPARE 0= IF e EXIT THEN
    e de.next @ -> e
  REPEAT 0
;

\ ---- the document's REQUIRE context: files reachable via REQUIRE/INCLUDE ----

: (DOC-REQ) { a u \ d n -- }              \ pass-1 hook: remember the path as written
  CUR-DOC @ -> d
  d doc.arena 3 CELLS ARENA-ALLOC -> n
  d doc.reqs @ n !
  d doc.arena a u ARENA-S, n 2 CELLS + ! n CELL+ !
  n d doc.reqs !
;

: CTX-HAS-PTR? { d pa \ n -- flag }       \ pa = a canonical (pooled) path address
  d doc.ctx @ -> n
  BEGIN n WHILE
    n CELL+ @ pa = IF TRUE EXIT THEN
    n @ -> n
  REPEAT FALSE
;

: CTX-ADD? { d pa pu \ n -- added? }      \ FALSE if already present
  d pa CTX-HAS-PTR? IF FALSE EXIT THEN
  d doc.arena 3 CELLS ARENA-ALLOC -> n
  d doc.ctx @ n !
  pa n CELL+ !  pu n 2 CELLS + !
  n d doc.ctx !
  TRUE
;

: FIND-DEF-CTX { d a u \ e -- e|0 }       \ like FIND-DEF, but only files in d's context
  d 0= IF 0 EXIT THEN
  HTAB @ 0= IF 0 EXIT THEN
  a u HSLOT @ -> e
  BEGIN e WHILE
    a u e DE-NAME COMPARE 0=
    d e de.file-a @ CTX-HAS-PTR? AND IF e EXIT THEN
    e de.hnext @ -> e
  REPEAT 0
;

\ locals scope (pass 2): names collected from { }, cleared at ;
VARIABLE LOC-HEAD                          \ chain of [next][a][u] in the doc arena
: (DIAG-LOCAL) { a u \ d n -- }
  CUR-DOC @ -> d
  d doc.arena 3 CELLS ARENA-ALLOC -> n
  LOC-HEAD @ n !
  d doc.arena a u ARENA-S, n 2 CELLS + ! n CELL+ !
  n LOC-HEAD !
;
: (DIAG-ENDDEF) ( -- )  0 LOC-HEAD ! ;
: LOCAL? { a u \ n -- flag }
  LOC-HEAD @ -> n
  BEGIN n WHILE
    a u n CELL+ @ n 2 CELLS + @ COMPARE 0= IF TRUE EXIT THEN
    n @ -> n
  REPEAT FALSE
;

: KNOWN-NUMBER? { a u -- flag }
  a u ?NUM IF DROP TRUE EXIT THEN
  BASE @ >R HEX a u ?NUM R> BASE ! IF DROP TRUE EXIT THEN
  u 1 > IF                                 \ "123." double-number tail
    a u 1- ?NUM IF DROP a u + 1- C@ [CHAR] . = EXIT THEN
  THEN
  FALSE
;

: KNOWN-WORD? { a u -- flag }
  a u KNOWN-NUMBER?        IF TRUE EXIT THEN
  a u LOCAL?               IF TRUE EXIT THEN
  CUR-DOC @ a u FIND-DOC-DEF IF TRUE EXIT THEN
  a u FIND-DEF             IF TRUE EXIT THEN
  a u FIND-LIVE            IF TRUE EXIT THEN
  a u FIND-WDB             IF TRUE EXIT THEN
  FALSE
;

: (DIAG-WORD) { a u line col \ d g -- }
  CUR-DOC @ -> d
  d doc.#diags @ MAX-DIAGS < 0= IF EXIT THEN
  a u KNOWN-WORD? IF EXIT THEN
  d doc.arena /DIAG ARENA-ALLOC -> g
  line g dg.line !  col g dg.col !
  a u U16-LEN g dg.len !
  d doc.arena a u ARENA-S, g dg.name-u ! g dg.name-a !
  d doc.diags @ g dg.next !  g d doc.diags !
  d doc.#diags 1+!
;

\ ======================== line table ========================

: DOC-LINES! { d \ n i a ta tu -- }       \ build the line-start offset table
  d DOC-TEXT -> tu -> ta
  1 -> n
  ta tu OVER + SWAP ?DO I C@ 10 = IF n 1+ -> n THEN LOOP
  d doc.arena n 1+ CELLS ARENA-ALLOC -> a
  a d doc.lines-a !  n d doc.#lines !
  0 a !  1 -> i
  tu 0 ?DO
    ta I + C@ 10 = IF I 1+ a i CELLS + ! i 1+ -> i THEN
  LOOP
  tu a i CELLS + !                        \ sentinel: end of text
;

: DOC-LINE ( d n -- a u )                 \ text of line n (without the LF)
  { d n -- }
  n d doc.#lines @ < 0= IF 0 0 EXIT THEN
  d doc.lines-a @ n CELLS + DUP @ SWAP CELL+ @   ( start next-start )
  OVER - d doc.text-a @ ROT + SWAP
  DUP IF 2DUP + 1- C@ 10 = IF 1- THEN THEN       \ strip LF
  DUP IF 2DUP + 1- C@ 13 = IF 1- THEN THEN       \ strip CR
;

\ ======================== reindex ========================

: DOC-REINDEX { d -- }
  d doc.arena ARENA-FREE
  0 d doc.defs !  0 d doc.#defs !
  0 d doc.diags !  0 d doc.#diags !
  0 d doc.reqs !  0 d doc.ctx !
  d DOC-LINES!
  d CUR-DOC !
  \ pass 1: definitions + REQUIRE list
  ['] (DOC-DEF)     TO ON-DEF
  ['] (NOOP-WORD)   TO ON-WORD
  ['] (NOOP-LOCAL)  TO ON-LOCAL
  ['] NOOP          TO ON-ENDDEF
  ['] (DOC-REQ)     TO ON-REQUIRE
  d DOC-TEXT WALK-F
  \ pass 2: diagnostics
  0 LOC-HEAD !
  ['] (NOOP-DEF)    TO ON-DEF
  ['] (DIAG-WORD)   TO ON-WORD
  ['] (DIAG-LOCAL)  TO ON-LOCAL
  ['] (DIAG-ENDDEF) TO ON-ENDDEF
  ['] (NOOP-LOCAL)  TO ON-REQUIRE
  d DOC-TEXT WALK-F
;

: DOC-SET-TEXT { d a u \ ta -- }
  d doc.text-a @ ?DUP IF FREE DROP THEN
  u 1+ ALLOCATE THROW -> ta
  ta d doc.text-a !
  a ta u MOVE  0 ta u + C!
  u d doc.text-u !
  d DOC-REINDEX
;

: DOC-OPEN { ua uu ta tu \ d -- d }       \ didOpen: create (or replace) + index
  ua uu FIND-DOC -> d
  d 0= IF
    /DOC ALLOCATE THROW -> d
    d /DOC ERASE
    ua uu POOL-S, d doc.uri-u ! d doc.uri-a !
    DOCS-HEAD @ d doc.next !  d DOCS-HEAD !
  THEN
  d ta tu DOC-SET-TEXT
  d
;

: DOC-CLOSE { ua uu \ d p -- }            \ didClose: unlink + free
  ua uu FIND-DOC -> d
  d 0= IF EXIT THEN
  DOCS-HEAD -> p
  BEGIN p @ d <> WHILE p @ doc.next -> p REPEAT
  d doc.next @ p !
  d doc.arena ARENA-FREE
  d doc.text-a @ ?DUP IF FREE DROP THEN
  d FREE DROP
;

\ ======================== word at position ========================

VARIABLE TS-COL                           \ start col (UTF-16) of the token TOKEN-SPAN returned

: TOKEN-SPAN { la lu char \ pos col ts u16 -- a u | 0 0 }
  \ scan one line's bytes; find the whitespace-delimited token whose
  \ [col, col+u16len) span contains the UTF-16 column `char`
  0 -> pos  0 -> col
  BEGIN pos lu < WHILE
    la pos + C@ WS? IF
      col 1+ -> col                       \ any whitespace byte = 1 unit
      pos 1+ -> pos
    ELSE
      pos -> ts
      BEGIN pos lu <  la pos + C@ WS? 0=  AND WHILE pos 1+ -> pos REPEAT
      la ts + pos ts - U16-LEN -> u16
      char col < 0=  char col u16 + <  AND IF
        col TS-COL !
        la ts +  pos ts -  EXIT
      THEN
      col u16 + -> col
      pos -> ts
    THEN
  REPEAT
  0 0
;

: WORD-AT ( d line char -- a u )          \ token at an LSP position ("" if none)
  { d line char -- }
  d line DOC-LINE char TOKEN-SPAN
;
