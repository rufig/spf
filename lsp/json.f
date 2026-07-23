\ lsp/json.f -- JSON for the spf64 LSP server: growing output buffer + parser.
\ The parser is the acWEB64 src/proto/http/json.f corpus with the per-request pool
\ (ACTCP-PALLOC/PFREE) replaced by plain ALLOCATE/FREE: the LSP server is
\ single-threaded and frees the whole tree after each message (JSON-FREE-VALUE).
\ Values are typed pairs ( x t ), t = JSON_* below; objects/arrays are linked
\ entry lists (jwl/je nodes), strings/numbers are [addr,len] pairs, all
\ NUL-terminated copies.

REQUIRE { lib/ext/locals.f

DECIMAL

\ ======================== output buffer ========================
\ One growing byte buffer; a response is built here, then framed and written.

VARIABLE OB-A   VARIABLE OB-LEN   VARIABLE OB-CAP

: OB-INIT ( -- )
  OB-A @ 0= IF
    65536 ALLOCATE THROW OB-A !
    65536 OB-CAP !
  THEN
  0 OB-LEN !
;

: OB-NEED { n \ cap -- }                  \ ensure room for n more bytes
  OB-LEN @ n + OB-CAP @ > IF
    OB-CAP @ -> cap
    BEGIN OB-LEN @ n + cap > WHILE cap 2* -> cap REPEAT
    OB-A @ cap RESIZE THROW OB-A !
    cap OB-CAP !
  THEN
;

: +S ( a u -- )
  DUP OB-NEED
  TUCK OB-A @ OB-LEN @ + SWAP MOVE
  OB-LEN +!
;

: +C ( c -- )
  1 OB-NEED
  OB-A @ OB-LEN @ + C!
  1 OB-LEN +!
;

: +NUM ( n -- )                           \ signed decimal
  DUP 0< IF [CHAR] - +C NEGATE THEN
  0 <# #S #> +S
;

: +U4 ( u -- )                            \ \uXXXX, exactly 4 hex digits
  S" \u" +S
  BASE @ >R HEX
  0 <# # # # # #> +S
  R> BASE !
;

: +ESC2 ( c2 -- )  [CHAR] \ +C +C ;       \ backslash + one char
: +JESC1 ( c -- )                         \ one byte, JSON-escaped
  DUP [CHAR] " = IF +ESC2 ELSE
  DUP [CHAR] \ = IF +ESC2 ELSE
  DUP 8  = IF DROP [CHAR] b +ESC2 ELSE
  DUP 9  = IF DROP [CHAR] t +ESC2 ELSE
  DUP 10 = IF DROP [CHAR] n +ESC2 ELSE
  DUP 12 = IF DROP [CHAR] f +ESC2 ELSE
  DUP 13 = IF DROP [CHAR] r +ESC2 ELSE
  DUP 32 < IF +U4 ELSE
  +C
  THEN THEN THEN THEN THEN THEN THEN THEN
;
: +JESC ( a u -- )                        \ string content, JSON-escaped
  OVER + SWAP ?DO I C@ +JESC1 LOOP
;

: +JSTR ( a u -- )                        \ quoted escaped string
  [CHAR] " +C  +JESC  [CHAR] " +C
;

\ ======================== parser ========================

0 CONSTANT JSON_NULL
1 CONSTANT JSON_BOOL
2 CONSTANT JSON_NUMBER
3 CONSTANT JSON_STRING
4 CONSTANT JSON_ARRAY
5 CONSTANT JSON_OBJECT
-1 CONSTANT JSON_ERROR

8 CELLS CONSTANT /JSON-WL
8 CELLS CONSTANT /JSON-ENTRY
2 CELLS CONSTANT /JSON-NUMBER

: (JALLOC) ( u -- a ior )  ALLOCATE ;
: (JFREE)  ( a -- ior )    FREE ;

: jwl.link ( wid -- addr ) 0 CELLS + ;
: jwl.class ( wid -- addr ) 1 CELLS + ;
: jwl.entries ( wid -- addr ) 2 CELLS + ;
: jwl.count ( wid -- addr ) 3 CELLS + ;

: je.next ( entry -- addr ) 0 CELLS + ;
: je.name-a ( entry -- addr ) 1 CELLS + ;
: je.name-u ( entry -- addr ) 2 CELLS + ;
: je.value ( entry -- addr ) 3 CELLS + ;
: je.type ( entry -- addr ) 4 CELLS + ;

USER json-src-a
USER json-src-u
USER json-pos
USER-CREATE json-path-name 64 USER-ALLOT

: JSON-SOURCE-END? ( -- flag )
  json-pos @ json-src-u @ < 0=
;

: JSON-CH@ ( -- c )
  JSON-SOURCE-END? IF 0 EXIT THEN
  json-src-a @ json-pos @ + C@
;

: JSON-ADVANCE ( -- )
  json-pos 1+!
;

: JSON-WS? ( c -- flag )
  DUP 32 = SWAP DUP 9 = SWAP DUP 10 = SWAP 13 = OR OR OR
;

: JSON-SKIP-WS ( -- )
  BEGIN JSON-SOURCE-END? 0= WHILE
    JSON-CH@ JSON-WS? 0= IF EXIT THEN
    JSON-ADVANCE
  REPEAT
;

: JSON-EXPECT ( c -- )
  JSON-SKIP-WS
  JSON-CH@ <> IF JSON_ERROR THROW THEN
  JSON-ADVANCE
;

: JSON-COPY { addr u \ mem -- addr2 u2 }
  u 1+ (JALLOC) THROW -> mem
  addr mem u MOVE
  0 mem u + C!
  mem u
;

VECT JSON-FREE-VALUE

: JSON-FREE-ENTRIES { entry \ next -- }
  BEGIN entry WHILE
    entry je.next @ -> next
    entry je.name-a @ ?DUP IF (JFREE) DROP THEN
    entry je.value @ entry je.type @ JSON-FREE-VALUE
    entry (JFREE) DROP
    next -> entry
  REPEAT
;

: JSON-FREE-WL ( wid -- )
  ?DUP 0= IF EXIT THEN
  DUP jwl.entries @ JSON-FREE-ENTRIES
  (JFREE) DROP
;

: (JSON-FREE-VALUE) { x t -- }
  t JSON_STRING = t JSON_NUMBER = OR
  IF x ?DUP IF DUP @ (JFREE) DROP (JFREE) DROP THEN EXIT THEN
  t JSON_ARRAY = t JSON_OBJECT = OR
  IF x JSON-FREE-WL EXIT THEN
;
' (JSON-FREE-VALUE) TO JSON-FREE-VALUE

: JSON-NEW-WL { class \ wid -- wid }
  /JSON-WL (JALLOC) THROW -> wid
  wid /JSON-WL ERASE
  class wid jwl.class !
  wid
;

: JSON-ENTRY-NAME ( entry -- addr u )
  DUP je.name-a @ SWAP je.name-u @
;

: JSON-ENTRY-VALUE ( entry -- x t )
  DUP je.value @ SWAP je.type @
;

: JSON-FIND-IN-WL { addr u wid \ entry -- x t true | false }
  wid jwl.entries @ -> entry
  BEGIN entry WHILE
    addr u entry JSON-ENTRY-NAME COMPARE 0=
    IF entry JSON-ENTRY-VALUE TRUE EXIT THEN
    entry je.next @ -> entry
  REPEAT
  FALSE
;

: JSON-ADD-ENTRY { name n x t wid \ entry na nu -- }
  /JSON-ENTRY (JALLOC) THROW -> entry
  entry /JSON-ENTRY ERASE
  name n JSON-COPY -> nu -> na
  na entry je.name-a !
  nu entry je.name-u !
  x entry je.value !
  t entry je.type !
  wid jwl.entries @ entry je.next !
  entry wid jwl.entries !
  1 wid jwl.count +!
;

: JSON-ADD-ARRAY-ENTRY { x t wid \ name-a name-u -- }
  wid jwl.count @ 0 <# #S #> -> name-u -> name-a
  name-a name-u x t wid JSON-ADD-ENTRY
;

: JSON-HEX? ( c -- flag )
  DUP [CHAR] 0 [CHAR] 9 1+ WITHIN
  SWAP DUP [CHAR] A [CHAR] F 1+ WITHIN
  SWAP [CHAR] a [CHAR] f 1+ WITHIN OR OR
;

: JSON-HEX-DIGIT ( c -- n )
  DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF [CHAR] 0 - EXIT THEN
  DUP [CHAR] A [CHAR] F 1+ WITHIN IF [CHAR] A - 10 + EXIT THEN
  [CHAR] a - 10 +
;

: JSON-HEX4 ( -- u )                      \ read 4 hex digits at json-pos
  0
  4 0 DO
    JSON-SOURCE-END? IF JSON_ERROR THROW THEN
    JSON-CH@ DUP JSON-HEX? 0= IF JSON_ERROR THROW THEN
    JSON-HEX-DIGIT SWAP 4 LSHIFT +
    JSON-ADVANCE
  LOOP
;

\ \uXXXX (with surrogate pairs) -> UTF-8 bytes at out+len; returns the new len
: JSON-UESC { out len \ cp lo -- len2 }
  JSON-HEX4 -> cp
  cp 0xD800 0xDC00 WITHIN IF              \ high surrogate: expect \uDC00..DFFF
    JSON-CH@ [CHAR] \ = IF
      JSON-ADVANCE
      JSON-CH@ [CHAR] u = IF
        JSON-ADVANCE
        JSON-HEX4 -> lo
        lo 0xDC00 0xE000 WITHIN IF
          cp 0xD800 - 10 LSHIFT  lo 0xDC00 -  +  0x10000 +  -> cp
        ELSE JSON_ERROR THROW THEN
      ELSE JSON_ERROR THROW THEN
    ELSE JSON_ERROR THROW THEN
  THEN
  cp 0x80 < IF
    cp out len + C!  len 1+ EXIT
  THEN
  cp 0x800 < IF
    cp 6 RSHIFT 0xC0 OR          out len +      C!
    cp 0x3F AND 0x80 OR          out len + 1+   C!
    len 2 + EXIT
  THEN
  cp 0x10000 < IF
    cp 12 RSHIFT 0xE0 OR         out len +      C!
    cp 6 RSHIFT 0x3F AND 0x80 OR out len + 1+   C!
    cp 0x3F AND 0x80 OR          out len + 2 +  C!
    len 3 + EXIT
  THEN
  cp 18 RSHIFT 0xF0 OR           out len +      C!
  cp 12 RSHIFT 0x3F AND 0x80 OR  out len + 1+   C!
  cp 6 RSHIFT 0x3F AND 0x80 OR   out len + 2 +  C!
  cp 0x3F AND 0x80 OR            out len + 3 +  C!
  len 4 +
;

: JSON-PARSE-STRING { \ out len c -- addr u }
  JSON-SKIP-WS
  JSON-CH@ [CHAR] " <> IF JSON_ERROR THROW THEN
  JSON-ADVANCE
  json-src-u @ json-pos @ - 5 + (JALLOC) THROW -> out
  0 -> len
  BEGIN JSON-SOURCE-END? 0= WHILE
    JSON-CH@ -> c
    c [CHAR] " = IF
      JSON-ADVANCE
      0 out len + C!
      out len EXIT
    THEN
    c [CHAR] \ = IF
      JSON-ADVANCE
      JSON-SOURCE-END? IF JSON_ERROR THROW THEN
      JSON-CH@ -> c
      c [CHAR] u = IF
        JSON-ADVANCE
        out len JSON-UESC -> len
      ELSE
        c [CHAR] " = IF [CHAR] " -> c ELSE
        c [CHAR] \ = IF [CHAR] \ -> c ELSE
        c [CHAR] / = IF [CHAR] / -> c ELSE
        c [CHAR] b = IF 8 -> c ELSE
        c [CHAR] f = IF 12 -> c ELSE
        c [CHAR] n = IF 10 -> c ELSE
        c [CHAR] r = IF 13 -> c ELSE
        c [CHAR] t = IF 9 -> c ELSE
        JSON_ERROR THROW
        THEN THEN THEN THEN THEN THEN THEN THEN
        c out len + C!
        len 1+ -> len
        JSON-ADVANCE
      THEN
    ELSE
      c out len + C!
      len 1+ -> len
      JSON-ADVANCE
    THEN
  REPEAT
  JSON_ERROR THROW
;

: JSON-NUM-CHAR? ( c -- flag )
  DUP [CHAR] 0 [CHAR] 9 1+ WITHIN IF DROP TRUE EXIT THEN
  DUP [CHAR] - = IF DROP TRUE EXIT THEN
  DUP [CHAR] + = IF DROP TRUE EXIT THEN
  DUP [CHAR] . = IF DROP TRUE EXIT THEN
  DUP [CHAR] e = IF DROP TRUE EXIT THEN
  [CHAR] E =
;

: JSON-PARSE-NUMBER { \ start u done -- addr u }
  JSON-SKIP-WS
  json-pos @ -> start
  FALSE -> done
  BEGIN JSON-SOURCE-END? 0= done 0= AND WHILE
    JSON-CH@ JSON-NUM-CHAR?
    IF JSON-ADVANCE ELSE TRUE -> done THEN
  REPEAT
  json-pos @ start - -> u
  u 0= IF JSON_ERROR THROW THEN
  json-src-a @ start + u JSON-COPY
;

: JSON-TEXT>VALUE { addr u \ text -- text }
  /JSON-NUMBER (JALLOC) THROW -> text
  addr text !
  u text CELL+ !
  text
;

: JSON-MATCH-LITERAL { addr u -- flag }
  json-src-u @ json-pos @ - u < IF FALSE EXIT THEN
  json-src-a @ json-pos @ + u addr u COMPARE 0= IF u json-pos +! TRUE ELSE FALSE THEN
;

VECT JSON-PARSE-VALUE

: JSON-PARSE-ARRAY { \ wid -- wid JSON_ARRAY }
  [CHAR] [ JSON-EXPECT
  JSON_ARRAY JSON-NEW-WL -> wid
  JSON-SKIP-WS
  JSON-CH@ [CHAR] ] = IF JSON-ADVANCE wid JSON_ARRAY EXIT THEN
  BEGIN
    JSON-PARSE-VALUE wid JSON-ADD-ARRAY-ENTRY
    JSON-SKIP-WS
    JSON-CH@ [CHAR] ] = IF JSON-ADVANCE wid JSON_ARRAY EXIT THEN
    [CHAR] , JSON-EXPECT
  AGAIN
;

: JSON-PARSE-OBJECT { \ wid ka ku -- wid JSON_OBJECT }
  [CHAR] { JSON-EXPECT
  JSON_OBJECT JSON-NEW-WL -> wid
  JSON-SKIP-WS
  JSON-CH@ [CHAR] } = IF JSON-ADVANCE wid JSON_OBJECT EXIT THEN
  BEGIN
    JSON-PARSE-STRING -> ku -> ka
    [CHAR] : JSON-EXPECT
    JSON-PARSE-VALUE ka ku 2SWAP wid JSON-ADD-ENTRY
    ka (JFREE) DROP
    JSON-SKIP-WS
    JSON-CH@ [CHAR] } = IF JSON-ADVANCE wid JSON_OBJECT EXIT THEN
    [CHAR] , JSON-EXPECT
  AGAIN
;

: (JSON-PARSE-VALUE) ( -- x t )
  JSON-SKIP-WS
  JSON-CH@ [CHAR] { = IF JSON-PARSE-OBJECT EXIT THEN
  JSON-CH@ [CHAR] [ = IF JSON-PARSE-ARRAY EXIT THEN
  JSON-CH@ [CHAR] " = IF JSON-PARSE-STRING JSON-TEXT>VALUE JSON_STRING EXIT THEN
  JSON-CH@ DUP [CHAR] - = SWAP [CHAR] 0 [CHAR] 9 1+ WITHIN OR
  IF JSON-PARSE-NUMBER JSON-TEXT>VALUE JSON_NUMBER EXIT THEN
  S" true" JSON-MATCH-LITERAL IF TRUE JSON_BOOL EXIT THEN
  S" false" JSON-MATCH-LITERAL IF FALSE JSON_BOOL EXIT THEN
  S" null" JSON-MATCH-LITERAL IF 0 JSON_NULL EXIT THEN
  JSON_ERROR THROW
;
' (JSON-PARSE-VALUE) TO JSON-PARSE-VALUE

: JSON-PARSE { addr u \ x t -- x t }
  addr json-src-a !
  u json-src-u !
  0 json-pos !
  JSON-PARSE-VALUE -> t -> x
  JSON-SKIP-WS
  json-pos @ json-src-u @ <> IF x t JSON-FREE-VALUE JSON_ERROR THROW THEN
  x t
;

\ ======================== accessors ========================

: JSON-WL? ( t -- flag )
  DUP JSON_OBJECT = SWAP JSON_ARRAY = OR
;

: JSON-S@ { x t -- addr u }               \ string/number text (else empty)
  t JSON_STRING = t JSON_NUMBER = OR IF x DUP @ SWAP CELL+ @ EXIT THEN
  S" "
;

: JSON-N@ ( x t -- n )                    \ integer value (else 0)
  JSON_NUMBER <> IF DROP 0 EXIT THEN
  JSON_NUMBER JSON-S@ ?NUM 0= IF 0 THEN
;

: JSON-B@ ( x t -- flag )
  JSON_BOOL = IF 0<> ELSE DROP FALSE THEN
;

: JSON-COUNT { x t -- n }
  t JSON-WL? IF x jwl.count @ ELSE 0 THEN
;

: J@ { x t addr u -- x2 t2 true | false } \ object member by key
  t JSON_OBJECT <> IF FALSE EXIT THEN
  addr u x JSON-FIND-IN-WL
;

: JIDX@ { x t index -- x2 t2 true | false } \ array element by index
  t JSON_ARRAY <> IF FALSE EXIT THEN
  index 0 <# #S #> x JSON-FIND-IN-WL
;

: J-S@ ( x t addr u -- a2 u2 )            \ member string by key ("" if absent)
  J@ IF JSON-S@ ELSE S" " THEN
;

: J-N@ ( x t addr u -- n )                \ member integer by key (0 if absent)
  J@ IF JSON-N@ ELSE 0 THEN
;
