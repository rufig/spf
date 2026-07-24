\ lsp/scan.f -- Forth-source tokenizer + workspace definition index.
\
\ The tokenizer (WALK-F) understands the spf4 surface: `\` line comments,
\ `( )`/`.( )` comments, `"`-terminated string words (S" ." C" ABORT" ...),
\ `{ ... }` locals blocks, REQUIRE's two arguments, \EOF.  It reports through
\ VECT hooks, so the same walker drives both the disk index (here) and the
\ open-document diagnostics (doc.f):
\   ON-DEF   ( a u line col kind -- )  a defining word's name token
\   ON-WORD  ( a u line col -- )       any other code token
\   ON-LOCAL ( a u -- )                a name declared inside { }
\   ON-ENDDEF ( -- )                   `;` seen (locals scope ends)
\ Positions: line is 0-based, col is 0-based in UTF-16 units (LSP-style).
\
\ The index: every *.f under the scan roots is slurped and walked; each
\ definition is stored (name, full path, line, col, kind, the trimmed source
\ line) in the pool, hashed by name (FNV-1a) for O(1) FIND-DEF.
\ The directory walk is the spf4 ~ac/lib/win/file/FINDFILE.F shape on
\ WINAPI64: FindFirstFileA/FindNextFileA/FindClose.

REQUIRE DICT-INIT lsp/dict.f

DECIMAL

\ ======================== def kinds ========================

1 CONSTANT DK-COLON
2 CONSTANT DK-CODE
3 CONSTANT DK-VAR
4 CONSTANT DK-CONST
5 CONSTANT DK-VALUE
6 CONSTANT DK-VECT
7 CONSTANT DK-CREATE
8 CONSTANT DK-USER
9 CONSTANT DK-VOC
10 CONSTANT DK-FFI

: DEFINER-KIND ( a u -- kind|0 )
  2DUP S" :"           COMPARE 0= IF 2DROP DK-COLON  EXIT THEN
  2DUP S" CODE"        COMPARE 0= IF 2DROP DK-CODE   EXIT THEN
  2DUP S" M:"          COMPARE 0= IF 2DROP DK-COLON  EXIT THEN
  2DUP S" T:"          COMPARE 0= IF 2DROP DK-COLON  EXIT THEN
  2DUP S" :T"          COMPARE 0= IF 2DROP DK-COLON  EXIT THEN
  2DUP S" VARIABLE"    COMPARE 0= IF 2DROP DK-VAR    EXIT THEN
  2DUP S" 2VARIABLE"   COMPARE 0= IF 2DROP DK-VAR    EXIT THEN
  2DUP S" CONSTANT"    COMPARE 0= IF 2DROP DK-CONST  EXIT THEN
  2DUP S" 2CONSTANT"   COMPARE 0= IF 2DROP DK-CONST  EXIT THEN
  2DUP S" VALUE"       COMPARE 0= IF 2DROP DK-VALUE  EXIT THEN
  2DUP S" 2VALUE"      COMPARE 0= IF 2DROP DK-VALUE  EXIT THEN
  2DUP S" DEFER"       COMPARE 0= IF 2DROP DK-VECT   EXIT THEN
  2DUP S" VECT"        COMPARE 0= IF 2DROP DK-VECT   EXIT THEN
  2DUP S" USER"        COMPARE 0= IF 2DROP DK-USER   EXIT THEN
  2DUP S" USER-CREATE" COMPARE 0= IF 2DROP DK-USER   EXIT THEN
  2DUP S" USER-VALUE"  COMPARE 0= IF 2DROP DK-USER   EXIT THEN
  2DUP S" CREATE"      COMPARE 0= IF 2DROP DK-CREATE EXIT THEN
  2DUP S" CREATED"     COMPARE 0= IF 2DROP DK-CREATE EXIT THEN
  2DUP S" VOCABULARY"  COMPARE 0= IF 2DROP DK-VOC    EXIT THEN
  2DUP S" MODULE:"     COMPARE 0= IF 2DROP DK-VOC    EXIT THEN
  2DUP S" WINAPI:"     COMPARE 0= IF 2DROP DK-FFI    EXIT THEN
  2DUP S" WINAPI64:"   COMPARE 0= IF 2DROP DK-FFI    EXIT THEN
  2DUP S" WINAPI64P:"  COMPARE 0= IF 2DROP DK-FFI    EXIT THEN
  2DUP S" DLFN:"       COMPARE 0= IF 2DROP DK-FFI    EXIT THEN
  2DROP 0
;

\ ======================== tokenizer ========================

VECT ON-DEF     \ ( a u line col kind -- )
VECT ON-WORD    \ ( a u line col -- )
VECT ON-LOCAL   \ ( a u -- )
VECT ON-ENDDEF  \ ( -- )
VECT ON-REQUIRE \ ( a u -- )              \ path argument of REQUIRE/INCLUDE/S"..."-INCLUDED

: (NOOP-DEF)    ( a u line col kind -- ) DROP 2DROP 2DROP ;
: (NOOP-WORD)   ( a u line col -- ) 2DROP 2DROP ;
: (NOOP-LOCAL)  ( a u -- ) 2DROP ;
' (NOOP-DEF)   TO ON-DEF
' (NOOP-WORD)  TO ON-WORD
' (NOOP-LOCAL) TO ON-LOCAL
' NOOP         TO ON-ENDDEF
' (NOOP-LOCAL) TO ON-REQUIRE

VARIABLE wk-a   VARIABLE wk-u   VARIABLE wk-pos
VARIABLE wk-line   VARIABLE wk-col

: WK-EOF? ( -- flag )  wk-pos @ wk-u @ < 0= ;
: WK-CH   ( -- c )     WK-EOF? IF 0 EXIT THEN wk-a @ wk-pos @ + C@ ;

: WK-ADV ( -- )                           \ +1 byte, track line + UTF-16 col
  WK-EOF? IF EXIT THEN
  WK-CH
  DUP 10 = IF
    DROP wk-line 1+!  0 wk-col !
  ELSE
    DUP 0x80 AND 0=  OVER 0xC0 AND 0xC0 =  OR IF   \ ASCII or a UTF-8 lead byte
      0xF8 AND 0xF0 = IF 2 ELSE 1 THEN wk-col +!   \ 4-byte lead = 2 UTF-16 units
    ELSE DROP THEN                                 \ continuation byte: no col
  THEN
  wk-pos 1+!
;

: WS? ( c -- flag )
  DUP 32 = SWAP DUP 9 = SWAP DUP 10 = SWAP 13 = OR OR OR
;

: WK-SKIP-WS   ( -- )  BEGIN WK-EOF? 0= WK-CH WS? AND WHILE WK-ADV REPEAT ;
: WK-SKIP-LINE ( -- )  BEGIN WK-EOF? 0= WK-CH 10 <> AND WHILE WK-ADV REPEAT ;
: WK-SKIP-)    ( -- )  BEGIN WK-EOF? 0= WK-CH [CHAR] ) <> AND WHILE WK-ADV REPEAT WK-EOF? 0= IF WK-ADV THEN ;
VARIABLE wk-str-a   VARIABLE wk-str-u     \ the last string literal's content span

: WK-SKIP-STR  { \ s -- }                 \ to the closing " (or EOL: spf4 strings are one-line)
  WK-CH 32 = IF WK-ADV THEN               \ the single delimiter blank after S"/."/ABORT"
  wk-a @ wk-pos @ + -> s
  BEGIN WK-EOF? 0=  WK-CH [CHAR] " <> AND  WK-CH 10 <> AND WHILE WK-ADV REPEAT
  s wk-str-a !  wk-a @ wk-pos @ + s - wk-str-u !
  WK-CH [CHAR] " = IF WK-ADV THEN
;

: WK-TOKEN { \ a line col -- a u line col } \ u=0 at EOF
  WK-SKIP-WS
  WK-EOF? IF 0 0 0 0 EXIT THEN
  wk-a @ wk-pos @ + -> a
  wk-line @ -> line  wk-col @ -> col
  BEGIN WK-EOF? 0= WK-CH WS? 0= AND WHILE WK-ADV REPEAT
  a  wk-a @ wk-pos @ + a -  line col
;

: S= ( a1 u1 a2 u2 -- flag )  COMPARE 0= ;
: QUOTE-END? ( a u -- flag )  DUP 0> IF + 1- C@ [CHAR] " = ELSE 2DROP FALSE THEN ;

: SKIP1-WORD? ( a u -- flag )             \ words whose next token is data, not a word
  2DUP S" [DEFINED]"   S= IF 2DROP TRUE EXIT THEN
  2DUP S" [UNDEFINED]" S= IF 2DROP TRUE EXIT THEN
  2DUP S" CHAR"        S= IF 2DROP TRUE EXIT THEN
  2DUP S" [CHAR]"      S= IF 2DROP TRUE EXIT THEN
  2DROP FALSE
;

: REQ2-WORD? ( a u -- flag )              \ <word> <path> follow
  2DUP S" REQUIRE" S= IF 2DROP TRUE EXIT THEN
  S" Require" S=
;
: REQ1-WORD? ( a u -- flag )              \ <path> follows
  2DUP S" INCLUDE" S= IF 2DROP TRUE EXIT THEN
  S" Include" S=
;
: INCL$-WORD? ( a u -- flag )             \ takes the S" ..." string before it
  2DUP S" INCLUDED" S= IF 2DROP TRUE EXIT THEN
  S" Included" S=
;

: WALK-F { buf len \ a u line col brace dash pend skipn reqn kind -- }
  buf wk-a !  len wk-u !
  0 wk-pos !  0 wk-line !  0 wk-col !
  0 wk-str-u !
  0 -> brace  0 -> dash  0 -> pend  0 -> skipn  0 -> reqn
  BEGIN
    WK-TOKEN -> col -> line -> u -> a
    u 0<>
  WHILE
    skipn 0> IF
      skipn 1- -> skipn
    ELSE reqn 0> IF
      reqn 1- -> reqn
      reqn 0= IF a u ON-REQUIRE THEN      \ the path token of REQUIRE/INCLUDE
    ELSE brace IF
      a u S" }" S= IF 0 -> brace
      ELSE a u S" --" S= IF 1 -> dash
      ELSE a u S" \" S= IF                \ locals separator inside { }
      ELSE dash 0= IF a u ON-LOCAL THEN
      THEN THEN THEN
    ELSE
      pend IF
        a u line col pend ON-DEF  0 -> pend
      ELSE a u S" \" S= IF
        WK-SKIP-LINE
      ELSE a u S" \EOF" S= IF
        wk-u @ wk-pos !                   \ hard stop
      ELSE a u S" (" S=  a u S" .(" S=  OR IF
        WK-SKIP-)
      ELSE a u S" {" S= IF
        1 -> brace  0 -> dash
      ELSE a u S" ;" S= IF
        a u line col ON-WORD  ON-ENDDEF
      ELSE a u REQ2-WORD? IF
        a u line col ON-WORD  2 -> reqn
      ELSE a u REQ1-WORD? IF
        a u line col ON-WORD  1 -> reqn
      ELSE a u INCL$-WORD? wk-str-u @ 0<> AND IF
        a u line col ON-WORD
        wk-str-a @ wk-str-u @ ON-REQUIRE  0 wk-str-u !
      ELSE a u SKIP1-WORD? IF
        a u line col ON-WORD  1 -> skipn
      ELSE a u DEFINER-KIND -> kind kind IF
        a u line col ON-WORD  kind -> pend
      ELSE a u QUOTE-END? IF
        a u line col ON-WORD  WK-SKIP-STR
      ELSE
        a u line col ON-WORD
      THEN THEN THEN THEN THEN THEN THEN THEN THEN THEN THEN THEN
    THEN THEN THEN
  REPEAT
;

: U16-LEN ( a u -- n )                    \ UTF-16 length of a UTF-8 byte run
  0 -ROT OVER + SWAP ?DO
    I C@
    DUP 0xC0 AND 0x80 = IF DROP           \ continuation: nothing
    ELSE 0xF8 AND 0xF0 = IF 2 + ELSE 1+ THEN THEN
  LOOP
;

\ ======================== definition index ========================

11 CELLS CONSTANT /DENTRY

: de.next   ( e -- a ) 0 CELLS + ;        \ global list
: de.hnext  ( e -- a ) 1 CELLS + ;        \ hash chain
: de.name-a ( e -- a ) 2 CELLS + ;
: de.name-u ( e -- a ) 3 CELLS + ;
: de.file-a ( e -- a ) 4 CELLS + ;
: de.file-u ( e -- a ) 5 CELLS + ;
: de.line   ( e -- a ) 6 CELLS + ;
: de.col    ( e -- a ) 7 CELLS + ;
: de.kind   ( e -- a ) 8 CELLS + ;
: de.text-a ( e -- a ) 9 CELLS + ;
: de.text-u ( e -- a ) 10 CELLS + ;

: DE-NAME ( e -- a u )  DUP de.name-a @ SWAP de.name-u @ ;
: DE-FILE ( e -- a u )  DUP de.file-a @ SWAP de.file-u @ ;
: DE-TEXT ( e -- a u )  DUP de.text-a @ SWAP de.text-u @ ;

65536 CONSTANT #HTAB
VARIABLE HTAB   0 HTAB !
VARIABLE DEFS-HEAD   VARIABLE #DEFS
0 DEFS-HEAD !  0 #DEFS !

: FNV ( a u -- h )
  -3750763034362895579 -ROT              \ FNV-1a 64-bit offset basis
  OVER + SWAP ?DO
    I C@ XOR 1099511628211 *
  LOOP
;

: DEFS-INIT ( -- )
  HTAB @ 0= IF #HTAB CELLS ALLOCATE THROW HTAB ! THEN
  HTAB @ #HTAB CELLS ERASE
  0 DEFS-HEAD !  0 #DEFS !
;

: HSLOT ( a u -- slot-addr )  FNV #HTAB 1- AND CELLS HTAB @ + ;

: DEF-ADD { na nu fa fu line col kind ta tu \ e slot -- }
  /DENTRY POOL-ALLOC -> e
  e /DENTRY ERASE
  na nu POOL-S, e de.name-u ! e de.name-a !
  fa fu             e de.file-u ! e de.file-a !   \ path string: already pooled by the caller
  line e de.line !  col e de.col !  kind e de.kind !
  ta tu POOL-S, e de.text-u ! e de.text-a !
  DEFS-HEAD @ e de.next !  e DEFS-HEAD !
  e DE-NAME HSLOT -> slot
  slot @ e de.hnext !  e slot !
  #DEFS 1+!
;

: FIND-DEF { a u \ e -- e|0 }
  HTAB @ 0= IF 0 EXIT THEN
  a u HSLOT @ -> e
  BEGIN e WHILE
    a u e DE-NAME COMPARE 0= IF e EXIT THEN
    e de.hnext @ -> e
  REPEAT 0
;

: FIND-DEF-CI { a u \ e -- e|0 }          \ linear (rare: hover fallback)
  DEFS-HEAD @ -> e
  BEGIN e WHILE
    a u e DE-NAME S-CI= IF e EXIT THEN
    e de.next @ -> e
  REPEAT 0
;

: EACH-DEF ( xt -- )                      \ xt ( e -- )
  DEFS-HEAD @
  BEGIN DUP WHILE
    2DUP 2>R  SWAP EXECUTE  2R>
    de.next @
  REPEAT 2DROP
;

\ ======================== indexed files + REQUIRE edges ========================
\ IFILES: every indexed file's canonical (pooled) path -- all de.file-a of one
\ file point at THE SAME pooled string, so context membership is pointer-equal.
\ REQS: (file, required-path) edges harvested from REQUIRE/INCLUDE/S"..."-INCLUDED.

VARIABLE IFILES-HEAD   0 IFILES-HEAD !
VARIABLE REQS-HEAD     0 REQS-HEAD !

: IFILE-ADD ( pa pu -- )                  \ pa = pooled canonical path
  3 CELLS POOL-ALLOC
  IFILES-HEAD @ OVER !
  TUCK 2 CELLS + !
  TUCK CELL+ !
  IFILES-HEAD !
;

: IFILE-FIND-CI { a u \ n -- pa pu TRUE | FALSE }   \ canonical path by CI compare
  IFILES-HEAD @ -> n
  BEGIN n WHILE
    a u n CELL+ @ n 2 CELLS + @ S-CI= IF
      n CELL+ @ n 2 CELLS + @ TRUE EXIT
    THEN
    n @ -> n
  REPEAT FALSE
;

: REQ-ADD { fa fu pa pu \ n -- }          \ fa = the requiring file's CANONICAL ptr
  7 CELLS POOL-ALLOC -> n                 \ [5][6] = resolved-target cache (0 = not yet, -1 = failed)
  REQS-HEAD @ n !
  fa n CELL+ !  fu n 2 CELLS + !
  pa pu POOL-S, n 4 CELLS + ! n 3 CELLS + !
  0 n 5 CELLS + !  0 n 6 CELLS + !
  n REQS-HEAD !
;

\ ======================== indexing one file ========================

VARIABLE IDX-FILE-A   VARIABLE IDX-FILE-U   \ pooled full path of the file being walked

200 CONSTANT /DEF-TEXT

: LINE-OF { p \ s e -- a u }              \ the source line containing address p (trimmed, capped)
  p -> s
  BEGIN s wk-a @ U> s 1- C@ 10 <> AND WHILE s 1- -> s REPEAT
  p -> e
  BEGIN e wk-a @ wk-u @ + U<  e C@ 10 <>  AND WHILE e 1+ -> e REPEAT
  BEGIN s e U<  s C@ 33 <  AND WHILE s 1+ -> s REPEAT           \ ltrim
  BEGIN e s U>  e 1- C@ 33 <  AND WHILE e 1- -> e REPEAT        \ rtrim (incl CR)
  s  e s -  /DEF-TEXT UMIN
;

: (IDX-DEF) { a u line col kind -- }
  a u
  IDX-FILE-A @ IDX-FILE-U @
  line col kind
  a LINE-OF
  DEF-ADD
;

: (IDX-REQ) ( a u -- )
  IDX-FILE-A @ IDX-FILE-U @ 2SWAP REQ-ADD
;

: INDEX-BUFFER ( buf len path-a path-u -- )     \ path must be pooled already
  IDX-FILE-U ! IDX-FILE-A !
  ['] (IDX-DEF) TO ON-DEF
  ['] (NOOP-WORD) TO ON-WORD
  ['] (NOOP-LOCAL) TO ON-LOCAL
  ['] NOOP TO ON-ENDDEF
  ['] (IDX-REQ) TO ON-REQUIRE
  WALK-F
;

2097152 CONSTANT MAX-IDX-FILE

: INDEX-FILE { pa pu \ ba bu ca cu -- }   \ slurp + index one .f file
  pa pu FILE-SLURP -> bu -> ba
  bu 0= IF EXIT THEN
  bu MAX-IDX-FILE > IF ba FREE DROP EXIT THEN
  pa pu POOL-S, -> cu -> ca               \ the canonical path copy
  ca cu IFILE-ADD
  ba bu ca cu INDEX-BUFFER
  ba FREE DROP
;

\ ======================== directory walk (Windows) ========================
\ the spf4 ~ac/lib/win/file/FINDFILE.F shape, with attributes kept.

2 WINAPI64P: FindFirstFileA KERNEL32.DLL  \ returns a HANDLE: raw 64-bit, no sign-extend
2 WINAPI64: FindNextFileA  KERNEL32.DLL
1 WINAPI64: FindClose      KERNEL32.DLL

16 CONSTANT FILE_ATTRIBUTE_DIRECTORY
44 CONSTANT fd-cFileName
420 CONSTANT /WIN32_FIND_DATA

: ZLEN ( az -- u )  DUP BEGIN DUP C@ WHILE 1+ REPEAT SWAP - ;

: .F-FILE? ( a u -- flag )                \ name ends in .f / .F
  DUP 2 < IF 2DROP FALSE EXIT THEN
  + 2 -
  DUP C@ [CHAR] . = SWAP 1+ C@ UPCH [CHAR] F = AND
;

: STARTS? { a1 u1 a2 u2 -- flag }         \ a2 u2 starts with a1 u1 (exact case)
  u1 u2 > IF FALSE EXIT THEN
  a1 u1 a2 u1 COMPARE 0=
;

: SCAN-EXCLUDED? ( a u -- flag )          \ directories we never descend into
  2DUP S" ."            S= IF 2DROP TRUE EXIT THEN
  2DUP S" .."           S= IF 2DROP TRUE EXIT THEN
  2DUP S" .git"         S= IF 2DROP TRUE EXIT THEN
  2DUP S" node_modules" S= IF 2DROP TRUE EXIT THEN
  2DUP S" scratch"      S= IF 2DROP TRUE EXIT THEN
  2DUP S" ini-stage"    S= IF 2DROP TRUE EXIT THEN
  2DUP S" service-stage" S= IF 2DROP TRUE EXIT THEN
  S" release-" 2SWAP STARTS? IF TRUE EXIT THEN
  FALSE
;

1024 CONSTANT /PATH-BUF

: PATH-JOIN { da du na nu buf -- a u }    \ "<dir>\<name>" NUL-terminated in buf
  da buf du MOVE
  [CHAR] \ buf du + C!
  na buf du + 1+ nu MOVE
  0 buf du + 1+ nu + C!
  buf  du nu + 1+
;

VARIABLE #SCANNED

: (SCAN-TREE) { da du \ data id pat name-a name-u attr pbuf -- }   \ recursive
  /WIN32_FIND_DATA ALLOCATE THROW -> data
  /PATH-BUF ALLOCATE THROW -> pbuf
  data /WIN32_FIND_DATA ERASE
  da du S" *" pbuf PATH-JOIN DROP DROP
  data pbuf FindFirstFileA -> id
  id -1 <> IF
    BEGIN
      data fd-cFileName + DUP ZLEN -> name-u -> name-a
      data @ 0xFFFFFFFF AND -> attr
      attr FILE_ATTRIBUTE_DIRECTORY AND IF
        name-a name-u SCAN-EXCLUDED? 0= IF
          da du name-a name-u pbuf PATH-JOIN RECURSE
        THEN
      ELSE
        name-a name-u .F-FILE? IF
          da du name-a name-u pbuf PATH-JOIN
          INDEX-FILE
          #SCANNED 1+!
        THEN
      THEN
      data id FindNextFileA 0=
    UNTIL
    id FindClose DROP
  THEN
  pbuf FREE DROP
  data FREE DROP
;

: SCAN-TREE ( a u -- )                    \ index every *.f under a root (DEFS-INIT first, once)
  (SCAN-TREE)
;

\ ======================== cp1251 -> UTF-8 (for hover text read from disk) ========================

: +UCP { cp -- }                          \ append one code point to OB as UTF-8
  cp 0x80 < IF cp +C EXIT THEN
  cp 0x800 < IF
    cp 6 RSHIFT 0xC0 OR +C
    cp 0x3F AND 0x80 OR +C EXIT THEN
  cp 12 RSHIFT 0xE0 OR +C
  cp 6 RSHIFT 0x3F AND 0x80 OR +C
  cp 0x3F AND 0x80 OR +C
;

: CP1251>UCP ( c -- cp )
  DUP 0x80 < IF EXIT THEN
  DUP 0xC0 U< 0= IF 0xC0 - 0x410 + EXIT THEN     \ А..я are contiguous
  DUP 0xA8 = IF DROP 0x401 EXIT THEN             \ Ё
  DUP 0xB8 = IF DROP 0x451 EXIT THEN             \ ё
  DUP 0x85 = IF DROP 0x2026 EXIT THEN            \ ellipsis
  DUP 0x96 = IF DROP 0x2013 EXIT THEN            \ en dash
  DUP 0x97 = IF DROP 0x2014 EXIT THEN            \ em dash
  DUP 0xB9 = IF DROP 0x2116 EXIT THEN            \ No sign
  DUP 0xA0 0xC0 WITHIN IF EXIT THEN              \ 0xA0..0xBF: latin-1-compatible enough
  DROP 0xFFFD
;

: +S1251 ( a u -- )                       \ append cp1251 bytes to OB as UTF-8
  OVER + SWAP ?DO
    I C@ CP1251>UCP +UCP
  LOOP
;
