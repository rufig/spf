\ lsp/lsp-server.f -- the spf64 LSP server (stdio transport).
\
\ run:  spf64.exe lsp\lsp-server.f      (the VS Code extension does exactly this)
\
\ Speaks LSP 3.x over stdin/stdout: Content-Length framing on the raw handles
\ (READ-FILE on H-STDIN is byte-exact, WRITE-FILE on H-STDOUT -- stdout carries
\ nothing else; logging goes to H-STDERR, which VS Code shows in the output
\ channel).  Knowledge of Forth comes from THIS running spf64:
\   * the live dictionary snapshot (lsp/dict.f DICT-INIT),
\   * .wdb build logs for the baked words' source file:line,
\   * a workspace/library *.f index (lsp/scan.f),
\   * open documents with two-pass reindex + diagnostics (lsp/doc.f).
\
\ Supported: initialize/initialized, shutdown/exit, textDocument/didOpen,
\ didChange (full sync), didClose + publishDiagnostics, completion, hover,
\ definition, documentSymbol.

REQUIRE DOC-OPEN lsp/doc.f

DECIMAL

\ ======================== logging (stderr) ========================

: LOG ( a u -- )  H-STDERR WRITE-FILE DROP ;
CREATE LF-S 10 C,
: LOG-CR ( -- )  LF-S 1 LOG ;
: LOG-N ( n -- ) 0 <# #S #> LOG ;

\ ======================== framing ========================

CREATE RD1-BUF 4 ALLOT

: RD1 ( -- c eof? )                       \ one byte from stdin
  RD1-BUF 1 H-STDIN READ-FILE THROW
  0= IF 0 TRUE ELSE RD1-BUF C@ FALSE THEN
;

256 CONSTANT /HDR-BUF
CREATE HDR-BUF /HDR-BUF ALLOT

: READ-HDR-LINE { \ n c eof -- a u eof? } \ up to LF, CR stripped
  0 -> n
  BEGIN
    RD1 -> eof -> c
    eof IF HDR-BUF n TRUE EXIT THEN
    c 10 =
  0= WHILE
    c 13 <> n /HDR-BUF < AND IF
      c HDR-BUF n + C!  n 1+ -> n
    THEN
  REPEAT
  HDR-BUF n FALSE
;

: HDR-CL? { a u \ p -- len true | false } \ "Content-Length: NNN" ?
  u 15 < IF FALSE EXIT THEN
  a 15 S" Content-Length:" S-CI= 0= IF FALSE EXIT THEN
  15 -> p
  BEGIN p u <  a p + C@ 32 =  AND WHILE p 1+ -> p REPEAT
  a p +  u p -  ?NUM 0= IF FALSE EXIT THEN
  TRUE
;

: READ-HEADERS { \ a u eof cl got -- len | -1 } \ -1 = EOF / no length
  0 -> cl  FALSE -> got
  BEGIN
    READ-HDR-LINE -> eof -> u -> a
    eof IF -1 EXIT THEN
    u 0=
  0= WHILE
    a u HDR-CL? IF -> cl TRUE -> got THEN
  REPEAT
  got IF cl ELSE -1 THEN
;

: READ-BODY { len \ buf pos n -- a u }    \ exactly len bytes (THROWs on EOF)
  len 1+ ALLOCATE THROW -> buf
  0 -> pos
  BEGIN pos len < WHILE
    buf pos +  len pos -  H-STDIN READ-FILE THROW -> n
    n 0= IF buf FREE DROP -1002 THROW THEN
    pos n + -> pos
  REPEAT
  0 buf len + C!
  buf len
;

CREATE HDRO-BUF 64 ALLOT

: SEND-OB { \ n u -- }                    \ frame + send the output buffer
  S" Content-Length: " DUP -> n HDRO-BUF SWAP MOVE
  OB-LEN @ 0 <# 10 HOLD 13 HOLD 10 HOLD 13 HOLD #S #> -> u
  ( a ) HDRO-BUF n + u MOVE
  HDRO-BUF n u + H-STDOUT WRITE-FILE THROW
  OB-A @ OB-LEN @ H-STDOUT WRITE-FILE THROW
;

\ ======================== JSON composing shorthand ========================

: +{ ( -- ) [CHAR] { +C ;
: +} ( -- ) [CHAR] } +C ;
: +[ ( -- ) [CHAR] [ +C ;
: +] ( -- ) [CHAR] ] +C ;
: +, ( -- ) [CHAR] , +C ;
: +Q ( -- ) [CHAR] " +C ;
: +KEY ( a u -- )  +Q +S +Q [CHAR] : +C ;
: +NULL ( -- )  S" null" +S ;

: +J1251 ( a u -- )                       \ escaped cp1251 text (into a JSON string)
  OVER + SWAP ?DO
    I C@ DUP 0x80 < IF +JESC1 ELSE CP1251>UCP +UCP THEN
  LOOP
;

: +POS-OBJ { line col -- }
  +{ S" line" +KEY line +NUM +, S" character" +KEY col +NUM +}
;
: +RANGE" { line col len -- }             \ "range":{...}  (col/len in UTF-16 units)
  S" range" +KEY
  +{ S" start" +KEY line col +POS-OBJ +, S" end" +KEY line col len + +POS-OBJ +}
;

\ ======================== server config ========================

VARIABLE ROOT-A    VARIABLE ROOT-U        \ workspace root path (cp1251)
0 ROOT-A ! 0 ROOT-U !
VARIABLE SPFX64-A  VARIABLE SPFX64-U      \ spf-x64 checkout (wdb + source resolve)
0 SPFX64-A ! 0 SPFX64-U !
VARIABLE INIT-DONE  0 INIT-DONE !

8 CONSTANT MAX-ROOTS
CREATE SCAN-ROOTS MAX-ROOTS 2 * CELLS ALLOT   VARIABLE #SCAN-ROOTS
CREATE WDB-PATHS  MAX-ROOTS 2 * CELLS ALLOT   VARIABLE #WDB-PATHS
0 #SCAN-ROOTS !  0 #WDB-PATHS !

: +SCAN-ROOT ( a u -- )
  #SCAN-ROOTS @ MAX-ROOTS < IF
    POOL-S, SCAN-ROOTS #SCAN-ROOTS @ 2 * CELLS + TUCK CELL+ ! !
    #SCAN-ROOTS 1+!
  ELSE 2DROP THEN
;
: +WDB-PATH ( a u -- )
  #WDB-PATHS @ MAX-ROOTS < IF
    POOL-S, WDB-PATHS #WDB-PATHS @ 2 * CELLS + TUCK CELL+ ! !
    #WDB-PATHS 1+!
  ELSE 2DROP THEN
;
: NTH-ROOT ( i -- a u )  2 * CELLS SCAN-ROOTS + DUP @ SWAP CELL+ @ ;
: NTH-WDB  ( i -- a u )  2 * CELLS WDB-PATHS  + DUP @ SWAP CELL+ @ ;

\ ======================== small compose buffer (paths) ========================

1024 CONSTANT /WBUF
CREATE WBUF /WBUF ALLOT   VARIABLE WBUF-U
: W0 ( -- )  0 WBUF-U ! ;
: W+ ( a u -- )  WBUF WBUF-U @ + SWAP DUP WBUF-U +! MOVE ;
: W$ ( -- a u )  0 WBUF WBUF-U @ + C!  WBUF WBUF-U @ ;

\ ======================== uri <-> path ========================

1024 CONSTANT /PBUF
CREATE PBUF  /PBUF ALLOT
CREATE PBUF2 /PBUF ALLOT
CREATE U8TMP 8 ALLOT

: UCP>1251 ( cp -- c )                    \ inverse of CP1251>UCP (common ranges)
  DUP 0x100  < IF EXIT THEN
  DUP 0x410 0x450 WITHIN IF 0x410 - 0xC0 + EXIT THEN
  DUP 0x401 = IF DROP 0xA8 EXIT THEN
  DUP 0x451 = IF DROP 0xB8 EXIT THEN
  DUP 0x2116 = IF DROP 0xB9 EXIT THEN
  DROP [CHAR] ?
;

: UTF8>1251 { a u dst \ i c cp n -- u2 }  \ decode utf8, encode cp1251 into dst
  0 -> i  0 -> n
  BEGIN i u < WHILE
    a i + C@ -> c
    c 0x80 < IF c -> cp  i 1+ -> i
    ELSE c 0xE0 AND 0xC0 = i 1+ u < AND IF
      c 0x1F AND 6 LSHIFT  a i 1+ + C@ 0x3F AND OR -> cp  i 2 + -> i
    ELSE c 0xF0 AND 0xE0 = i 2 + u < AND IF
      c 0x0F AND 12 LSHIFT  a i 1+ + C@ 0x3F AND 6 LSHIFT OR  a i 2 + + C@ 0x3F AND OR -> cp  i 3 + -> i
    ELSE
      [CHAR] ? -> cp  i 1+ -> i
    THEN THEN THEN
    cp UCP>1251 dst n + C!  n 1+ -> n
  REPEAT
  n
;

: URI>PATH { a u \ i c n -- a2 u2 }       \ file:///d%3A/x -> d:\x (in PBUF, NUL-terminated)
  0 -> i
  u 7 < 0= IF a 7 S" file://" S-CI= IF 7 -> i THEN THEN
  i u < IF a i + C@ [CHAR] / = IF i 1+ -> i THEN THEN   \ the slash before the drive
  0 -> n
  BEGIN i u < WHILE
    a i + C@ -> c
    c [CHAR] % =  i 2 + u <  AND IF
      a i 1+ + C@ JSON-HEX-DIGIT 4 LSHIFT  a i 2 + + C@ JSON-HEX-DIGIT OR -> c
      i 3 + -> i
    ELSE i 1+ -> i THEN
    c [CHAR] / = IF [CHAR] \ -> c THEN
    c PBUF2 n + C!  n 1+ -> n
  REPEAT
  PBUF2 n PBUF UTF8>1251 -> n             \ %-decoded utf8 -> cp1251 for the A-file-APIs
  0 PBUF n + C!
  PBUF n
;

: URI-SAFE? ( c -- flag )
  DUP [CHAR] A [CHAR] Z 1+ WITHIN
  OVER [CHAR] a [CHAR] z 1+ WITHIN OR
  OVER [CHAR] 0 [CHAR] 9 1+ WITHIN OR
  OVER [CHAR] - = OR  OVER [CHAR] . = OR
  OVER [CHAR] _ = OR  SWAP [CHAR] ~ = OR
;

: +%XX ( c -- )
  [CHAR] % +C
  BASE @ >R HEX 0 <# # # #> +S R> BASE !
;

: UCP>U8 { cp -- n }                      \ encode into U8TMP, return byte count
  cp 0x80 < IF cp U8TMP C! 1 EXIT THEN
  cp 0x800 < IF
    cp 6 RSHIFT 0xC0 OR U8TMP C!
    cp 0x3F AND 0x80 OR U8TMP 1+ C! 2 EXIT THEN
  cp 12 RSHIFT 0xE0 OR U8TMP C!
  cp 6 RSHIFT 0x3F AND 0x80 OR U8TMP 1+ C!
  cp 0x3F AND 0x80 OR U8TMP 2 + C!
  3
;

: +PATH>URI { a u \ c n -- }              \ append "file:///c%3A/..." for a cp1251 path
  S" file:///" +S
  u 0 ?DO
    a I + C@ -> c
    c [CHAR] \ = IF [CHAR] / +C
    ELSE c URI-SAFE? c [CHAR] / = OR IF c +C
    ELSE c 0x80 < IF c +%XX
    ELSE
      c CP1251>UCP UCP>U8 -> n
      U8TMP n OVER + SWAP ?DO I C@ +%XX LOOP
    THEN THEN THEN
  LOOP
;

\ ======================== param helpers ========================

: ?PARAMS ( x t -- px pt )  S" params" J@ 0= IF 0 JSON_NULL THEN ;
: J-URI ( px pt -- a u )
  S" textDocument" J@ 0= IF S" " EXIT THEN
  S" uri" J-S@
;
: J-DOC ( px pt -- d|0 )  J-URI FIND-DOC ;
: J-POS ( px pt -- line char )
  S" position" J@ 0= IF 0 0 EXIT THEN
  2DUP S" line" J-N@ -ROT S" character" J-N@
;

\ ======================== diagnostics publishing ========================

: (+DIAG) { g first \ na nu -- }
  first 0= IF +, THEN
  +{
  g dg.line @ g dg.col @ g dg.len @ +RANGE" +,
  S" severity" +KEY 2 +NUM +,
  S" source" +KEY S" spf64" +JSTR +,
  S" message" +KEY
  +Q S" unknown word: " +JESC
  g dg.name-a @ g dg.name-u @ +JESC
  S"  (not in the spf64 dictionary)" +JESC +Q
  +}
;

: PUBLISH-DIAGS { d \ g first -- }
  OB-INIT
  +{ S" jsonrpc" +KEY S" 2.0" +JSTR +,
  S" method" +KEY S" textDocument/publishDiagnostics" +JSTR +,
  S" params" +KEY +{
    S" uri" +KEY +Q d DOC-URI +JESC +Q +,
    S" diagnostics" +KEY +[
    d doc.diags @ -> g  TRUE -> first
    BEGIN g WHILE
      g first (+DIAG)  FALSE -> first
      g dg.next @ -> g
    REPEAT
    +]
  +} +}
  SEND-OB
;

: PUBLISH-EMPTY { ua uu -- }              \ after didClose
  OB-INIT
  +{ S" jsonrpc" +KEY S" 2.0" +JSTR +,
  S" method" +KEY S" textDocument/publishDiagnostics" +JSTR +,
  S" params" +KEY +{
    S" uri" +KEY +Q ua uu +JESC +Q +,
    S" diagnostics" +KEY +[ +]
  +} +}
  SEND-OB
;

\ ======================== notifications: documents ========================

: H-DIDOPEN { px pt \ dx dt ta tu d -- }
  px pt S" textDocument" J@ 0= IF EXIT THEN
  -> dt -> dx
  dx dt S" uri" J-S@
  dx dt S" text" J-S@ -> tu -> ta
  ta tu DOC-OPEN -> d
  d PUBLISH-DIAGS
;

: H-DIDCHANGE { px pt \ ua uu ta tu d cx ct -- }
  px pt J-URI -> uu -> ua
  uu 0= IF EXIT THEN
  px pt S" contentChanges" J@ 0= IF EXIT THEN
  0 JIDX@ 0= IF EXIT THEN
  S" text" J-S@ -> tu -> ta
  ua uu FIND-DOC -> d
  d IF
    d ta tu DOC-SET-TEXT
  ELSE
    ua uu ta tu DOC-OPEN -> d
  THEN
  d PUBLISH-DIAGS
;

: H-DIDCLOSE { px pt \ ua uu -- }
  px pt J-URI -> uu -> ua                 \ the uri lives in the parse tree until DISPATCH returns
  uu 0= IF EXIT THEN
  ua uu DOC-CLOSE
  ua uu PUBLISH-EMPTY
;

\ ======================== hover ========================

: BASENAME { a u \ i -- a2 u2 }           \ path tail after the last \ or /
  u -> i
  BEGIN i 0 > WHILE
    a i 1- + C@ DUP [CHAR] \ = SWAP [CHAR] / = OR IF
      a i + u i -  EXIT
    THEN
    i 1- -> i
  REPEAT
  a u
;

: WDB-RESOLVE { e \ pa pu -- a u | 0 0 }  \ full path of a wdb entry's source file
  SPFX64-A @ 0= IF 0 0 EXIT THEN
  W0 SPFX64-A @ SPFX64-U @ W+ S" \src\runtime\" W+ e WE-FILE W+ W$ -> pu -> pa
  pa pu FILE-EXISTS IF pa pu EXIT THEN
  W0 SPFX64-A @ SPFX64-U @ W+ S" \src\seed\" W+ e WE-FILE W+ W$ -> pu -> pa
  pa pu FILE-EXISTS IF pa pu EXIT THEN
  0 0
;

: +FILE-LINE { pa pu line# \ ba bu base la lu n -- }  \ append line line# (1-based) of a cp1251 file, escaped

  pa pu FILE-SLURP -> bu -> ba
  bu 0= IF EXIT THEN
  ba -> base
  1 -> n
  BEGIN bu 0<> n line# < AND WHILE
    ba bu 10 SPLIT-CH -> bu -> ba 2DROP
    n 1+ -> n
  REPEAT
  n line# =  bu 0<>  AND IF
    ba bu 10 SPLIT-CH 2DROP -> lu -> la
    la lu -CR +J1251
  THEN
  base FREE DROP
;

: +HOVER-RESULT-BEGIN ( -- )
  +{ S" contents" +KEY +{ S" kind" +KEY S" markdown" +JSTR +, S" value" +KEY +Q
;
: +HOVER-RESULT-END ( -- )  +Q +} +} ;

: +MD-CODE-1251 ( a u -- )                \ ```forth ... ``` block, cp1251 source text
  S" \n```forth\n" +S  +J1251  S" \n```\n" +S
;
: +MD-CODE-U8 ( a u -- )
  S" \n```forth\n" +S  +JESC  S" \n```\n" +S
;

: DK-NAME ( kind -- a u )
  DUP DK-COLON  = IF DROP S" colon word"  EXIT THEN
  DUP DK-CODE   = IF DROP S" CODE word"   EXIT THEN
  DUP DK-VAR    = IF DROP S" variable"    EXIT THEN
  DUP DK-CONST  = IF DROP S" constant"    EXIT THEN
  DUP DK-VALUE  = IF DROP S" value"       EXIT THEN
  DUP DK-VECT   = IF DROP S" defer/vect"  EXIT THEN
  DUP DK-CREATE = IF DROP S" data word"   EXIT THEN
  DUP DK-USER   = IF DROP S" user variable" EXIT THEN
  DUP DK-VOC    = IF DROP S" vocabulary"  EXIT THEN
  DUP DK-FFI    = IF DROP S" foreign function" EXIT THEN
  DROP S" word"
;

VARIABLE HV-LIVE   \ live entry found for the hovered word (0 if none)

: +LIVE-NOTE { e -- }                     \ " -- wordlist FORTH, immediate"
  S"  — wordlist " +S
  e WE-VOC +J1251
  e WE-IMM? IF S" , **immediate**" +S THEN
;

: H-HOVER { px pt \ d wa wu e le pa pu -- }
  px pt J-DOC -> d
  d 0= IF +NULL EXIT THEN
  d px pt J-POS WORD-AT -> wu -> wa
  wu 0= IF +NULL EXIT THEN
  wa wu FIND-LIVE DUP 0= IF DROP wa wu FIND-LIVE-CI THEN -> le
  \ 1) the document's own definition
  d wa wu FIND-DOC-DEF -> e
  e IF
    +HOVER-RESULT-BEGIN
    S" **" +S e DE-NAME +JESC S" **" +S
    S"  — " +S e de.kind @ DK-NAME +JESC
    S" , defined in this file, line " +S e de.line @ 1+ +NUM
    le IF le +LIVE-NOTE THEN
    e DE-TEXT +MD-CODE-U8
    +HOVER-RESULT-END EXIT
  THEN
  \ 2) the workspace/library index
  wa wu FIND-DEF DUP 0= IF DROP wa wu FIND-DEF-CI THEN -> e
  e IF
    +HOVER-RESULT-BEGIN
    S" **" +S e DE-NAME +J1251 S" **" +S
    S"  — " +S e de.kind @ DK-NAME +JESC
    le IF le +LIVE-NOTE THEN
    e DE-TEXT +MD-CODE-1251
    S" \n*" +S e DE-FILE +J1251 S" :" +S e de.line @ 1+ +NUM S" *" +S
    +HOVER-RESULT-END EXIT
  THEN
  \ 3) the live dictionary (+ .wdb location if known)
  le 0= IF wa wu FIND-WDB-CI ELSE wa wu FIND-WDB THEN -> e
  le e OR 0= IF +NULL EXIT THEN
  +HOVER-RESULT-BEGIN
  S" **" +S
  le IF le WE-NAME ELSE e WE-NAME THEN +J1251
  S" **" +S
  S"  — a word of the running spf64 image" +S
  le IF le +LIVE-NOTE THEN
  e IF
    e WDB-RESOLVE -> pu -> pa
    pu IF
      S" \n```forth\n" +S
      pa pu e we.line @ +FILE-LINE
      S" \n```\n" +S
    THEN
    S" \n*" +S e WE-FILE +J1251 S" :" +S e we.line @ +NUM
    S"  (baked into spf64)*" +S
  THEN
  +HOVER-RESULT-END
;

\ ======================== definition ========================

: H-DEFINITION { px pt \ d wa wu e pa pu -- }
  px pt J-DOC -> d
  d 0= IF +NULL EXIT THEN
  d px pt J-POS WORD-AT -> wu -> wa
  wu 0= IF +NULL EXIT THEN
  d wa wu FIND-DOC-DEF -> e
  e IF
    +{ S" uri" +KEY +Q d DOC-URI +JESC +Q +,
    e de.line @ e de.col @ e DE-NAME U16-LEN +RANGE" +}
    EXIT
  THEN
  wa wu FIND-DEF -> e
  e IF
    +{ S" uri" +KEY +Q e DE-FILE +PATH>URI +Q +,
    e de.line @ e de.col @ e DE-NAME U16-LEN +RANGE" +}
    EXIT
  THEN
  wa wu FIND-WDB -> e
  e IF
    e WDB-RESOLVE -> pu -> pa
    pu IF
      +{ S" uri" +KEY +Q pa pu +PATH>URI +Q +,
      e we.line @ 1- 0 MAX  0  1  +RANGE" +}
      EXIT
    THEN
  THEN
  +NULL
;

\ ======================== completion ========================

VARIABLE CP-A  VARIABLE CP-U              \ the prefix being completed
VARIABLE CI-N  VARIABLE CI-DOC
300 CONSTANT MAX-ITEMS

: WORD-PREFIX { d line char \ a u units i c -- a u }
  char 0= IF 0 0 EXIT THEN
  d line char 1- WORD-AT -> u -> a
  u 0= IF 0 0 EXIT THEN
  char TS-COL @ - -> units                \ UTF-16 units of the token before the cursor
  0 -> i  0 -> c
  BEGIN i u <  c units <  AND WHILE
    a i + C@ DUP 0xC0 AND 0x80 = IF DROP
    ELSE 0xF8 AND 0xF0 = IF c 2 + ELSE c 1+ THEN -> c THEN
    i 1+ -> i
  REPEAT
  a i
;

: DK>CIK ( kind -- n )                    \ CompletionItemKind
  DUP DK-CONST = IF DROP 21 EXIT THEN
  DUP DK-VOC   = IF DROP 9  EXIT THEN
  DUP DK-VAR = OVER DK-VALUE = OR OVER DK-CREATE = OR OVER DK-USER = OR IF DROP 6 EXIT THEN
  DROP 3
;
: DK>SYM ( kind -- n )                    \ SymbolKind
  DUP DK-CONST = IF DROP 14 EXIT THEN
  DUP DK-VOC   = IF DROP 2  EXIT THEN
  DUP DK-VAR = OVER DK-VALUE = OR OVER DK-CREATE = OR OVER DK-USER = OR IF DROP 13 EXIT THEN
  DROP 12
;

: ITEM-BEGIN ( -- )
  CI-N @ IF +, THEN
  +{ S" label" +KEY +Q
;
: ITEM-MID ( kind -- )
  +Q +, S" kind" +KEY +NUM +, S" detail" +KEY +Q
;
: ITEM-END ( -- )
  +Q +}
  CI-N 1+!
;

: CP-MATCH? ( a u -- flag )
  CI-N @ MAX-ITEMS < 0= IF 2DROP FALSE EXIT THEN
  CP-A @ CP-U @ 2SWAP PREFIX-CI?
;

: (CI-DOCDEF) ( e -- )
  DUP DE-NAME CP-MATCH? 0= IF DROP EXIT THEN
  ITEM-BEGIN
  DUP DE-NAME +JESC
  DUP de.kind @ DK>CIK ITEM-MID
  S" this file:" +JESC DUP de.line @ 1+ 0 <# #S #> +JESC
  ITEM-END
  DROP
;

: (CI-WS) ( e -- )
  DUP DE-NAME CP-MATCH? 0= IF DROP EXIT THEN
  CI-DOC @ OVER DE-NAME FIND-DOC-DEF IF DROP EXIT THEN   \ shadowed by the open doc
  ITEM-BEGIN
  DUP DE-NAME +J1251
  DUP de.kind @ DK>CIK ITEM-MID
  DUP DE-FILE BASENAME +J1251
  S" :" +JESC DUP de.line @ 1+ 0 <# #S #> +JESC
  ITEM-END
  DROP
;

: (CI-LIVE) ( e -- )
  DUP WE-NAME CP-MATCH? 0= IF DROP EXIT THEN
  DUP WE-NAME FIND-DEF IF DROP EXIT THEN                 \ already emitted from the index
  CI-DOC @ OVER WE-NAME FIND-DOC-DEF IF DROP EXIT THEN
  ITEM-BEGIN
  DUP WE-NAME +J1251
  3 ITEM-MID
  S" wordlist " +JESC DUP WE-VOC +J1251
  DUP WE-IMM? IF S" , immediate" +JESC THEN
  ITEM-END
  DROP
;

: H-COMPLETION { px pt \ d line char e -- }
  px pt J-DOC -> d
  d CI-DOC !
  d 0= IF +NULL EXIT THEN
  px pt J-POS -> char -> line
  d line char WORD-PREFIX CP-U ! CP-A !
  0 CI-N !
  +{ S" isIncomplete" +KEY S" false" +S +, S" items" +KEY +[
  CP-U @ IF
    d doc.defs @ -> e
    BEGIN e WHILE e (CI-DOCDEF) e de.next @ -> e REPEAT
    ['] (CI-WS) EACH-DEF
    ['] (CI-LIVE) EACH-LIVE
  THEN
  +] +}
;

\ ======================== documentSymbol ========================

: (+SYMBOL) { e first -- }
  first 0= IF +, THEN
  +{ S" name" +KEY +Q e DE-NAME +JESC +Q +,
  S" kind" +KEY e de.kind @ DK>SYM +NUM +,
  e de.line @ e de.col @ e DE-NAME U16-LEN +RANGE" +,
  S" selectionRange" +KEY
  +{ S" start" +KEY e de.line @ e de.col @ +POS-OBJ +,
     S" end" +KEY e de.line @ e de.col @ e DE-NAME U16-LEN + +POS-OBJ +}
  +}
;

: H-SYMBOLS { px pt \ d e first -- }
  px pt J-DOC -> d
  d 0= IF +NULL EXIT THEN
  +[
  d doc.defs @ -> e  TRUE -> first
  BEGIN e WHILE
    e first (+SYMBOL)  FALSE -> first
    e de.next @ -> e
  REPEAT
  +]
;

\ ======================== initialize / initialized ========================

: H-INIT { px pt \ ox ot ax at n -- }
  px pt S" rootUri" J@ IF
    JSON-S@ DUP IF URI>PATH POOL-S, ROOT-U ! ROOT-A ! ELSE 2DROP THEN
  THEN
  ROOT-A @ 0= IF
    px pt S" workspaceFolders" J@ IF
      0 JIDX@ IF
        S" uri" J-S@ DUP IF URI>PATH POOL-S, ROOT-U ! ROOT-A ! ELSE 2DROP THEN
      THEN
    THEN
  THEN
  px pt S" initializationOptions" J@ IF
    -> ot -> ox
    ox ot S" spfx64Root" J-S@ DUP IF POOL-S, SPFX64-U ! SPFX64-A ! ELSE 2DROP THEN
    ox ot S" wdb" J@ IF
      -> at -> ax
      ax at JSON-COUNT -> n
      n 0 ?DO ax at I JIDX@ IF JSON-S@ +WDB-PATH THEN LOOP
    THEN
    ox ot S" scanRoots" J@ IF
      -> at -> ax
      ax at JSON-COUNT -> n
      n 0 ?DO ax at I JIDX@ IF JSON-S@ +SCAN-ROOT THEN LOOP
    THEN
  THEN
  +{ S" capabilities" +KEY +{
    S" textDocumentSync" +KEY 1 +NUM +,
    S" completionProvider" +KEY +{ S" resolveProvider" +KEY S" false" +S +} +,
    S" hoverProvider" +KEY S" true" +S +,
    S" definitionProvider" +KEY S" true" +S +,
    S" documentSymbolProvider" +KEY S" true" +S
  +} +,
  S" serverInfo" +KEY +{
    S" name" +KEY S" spf64-lsp" +JSTR +,
    S" version" +KEY S" 0.1.0" +JSTR
  +} +}
;

: DO-INITIALIZED { \ i -- }
  INIT-DONE @ IF EXIT THEN
  1 INIT-DONE !
  DICT-INIT
  S" spf64-lsp: live dictionary " LOG #LIVE @ LOG-N S"  words" LOG LOG-CR
  #WDB-PATHS @ 0= IF
    W0 ModuleName W+ S" .wdb" W+ W$ +WDB-PATH
    SPFX64-A @ IF
      W0 SPFX64-A @ SPFX64-U @ W+ S" \src\runtime\spf64.exe.wdb" W+ W$ +WDB-PATH
      W0 SPFX64-A @ SPFX64-U @ W+ S" \src\seed\seedw.wdb" W+ W$ +WDB-PATH
    THEN
  THEN
  #WDB-PATHS @ 0 ?DO I NTH-WDB WDB-LOAD LOOP
  S" spf64-lsp: wdb entries " LOG #WDB @ LOG-N LOG-CR
  #SCAN-ROOTS @ 0= IF
    ROOT-A @ IF ROOT-A @ ROOT-U @ +SCAN-ROOT THEN
    W0 ModuleDirName W+ S" devel" W+ W$ +SCAN-ROOT
  THEN
  DEFS-INIT
  0 #SCANNED !
  #SCAN-ROOTS @ 0 ?DO
    I NTH-ROOT 2DUP LOG S"  ..." LOG LOG-CR
    SCAN-TREE
  LOOP
  S" spf64-lsp: indexed " LOG #SCANNED @ LOG-N S"  files, " LOG
  #DEFS @ LOG-N S"  definitions" LOG LOG-CR
;

\ ======================== dispatch ========================

VARIABLE ID-X   VARIABLE ID-T   VARIABLE HAVE-ID

: +ID ( -- )
  HAVE-ID @ 0= IF +NULL EXIT THEN
  ID-T @ JSON_NUMBER = IF ID-X @ JSON_NUMBER JSON-S@ +S EXIT THEN
  ID-T @ JSON_STRING = IF ID-X @ JSON_STRING JSON-S@ +JSTR EXIT THEN
  +NULL
;

: RESP-BEGIN ( -- )
  OB-INIT
  +{ S" jsonrpc" +KEY S" 2.0" +JSTR +, S" id" +KEY +ID +, S" result" +KEY
;
: RESP-SEND ( -- )  +} SEND-OB ;

: RESP-ERROR { code ma mu -- }
  OB-INIT
  +{ S" jsonrpc" +KEY S" 2.0" +JSTR +, S" id" +KEY +ID +, S" error" +KEY
  +{ S" code" +KEY code +NUM +, S" message" +KEY ma mu +JSTR +} +}
  SEND-OB
;

: REQ-XT ( a u -- xt|0 )                  \ request handlers ( px pt -- result-appended )
  2DUP S" initialize"                  S= IF 2DROP ['] H-INIT       EXIT THEN
  2DUP S" textDocument/completion"     S= IF 2DROP ['] H-COMPLETION EXIT THEN
  2DUP S" textDocument/hover"          S= IF 2DROP ['] H-HOVER      EXIT THEN
  2DUP S" textDocument/definition"     S= IF 2DROP ['] H-DEFINITION EXIT THEN
  2DUP S" textDocument/documentSymbol" S= IF 2DROP ['] H-SYMBOLS    EXIT THEN
  2DROP 0
;

: DISPATCH { x t \ ma mu px pt xt err -- }
  x t S" method" J-S@ -> mu -> ma
  x t S" id" J@ DUP HAVE-ID ! IF ID-T ! ID-X ! THEN
  x t ?PARAMS -> pt -> px
  HAVE-ID @ IF
    ma mu S" shutdown" S= IF RESP-BEGIN +NULL RESP-SEND EXIT THEN
    ma mu REQ-XT -> xt
    xt 0= IF -32601 S" method not found" RESP-ERROR EXIT THEN
    RESP-BEGIN
    px pt xt CATCH -> err
    err IF
      2DROP                               \ the two garbage cells CATCH left
      S" spf64-lsp: handler exception " LOG err LOG-N S"  in " LOG ma mu LOG LOG-CR
      -32603 S" internal error" RESP-ERROR EXIT
    THEN
    RESP-SEND
  ELSE
    ma mu S" initialized" S= IF DO-INITIALIZED EXIT THEN
    ma mu S" exit" S= IF S" spf64-lsp: exit" LOG LOG-CR BYE THEN
    ma mu S" textDocument/didOpen" S= IF px pt H-DIDOPEN EXIT THEN
    ma mu S" textDocument/didChange" S= IF px pt H-DIDCHANGE EXIT THEN
    ma mu S" textDocument/didClose" S= IF px pt H-DIDCLOSE EXIT THEN
    \ all other notifications: ignore
  THEN
;

\ ======================== main loop ========================

: PARSE-MSG ( a u -- x t ok? )
  ['] JSON-PARSE CATCH IF 2DROP 0 0 FALSE ELSE TRUE THEN
;

: LSP-LOOP { \ len ba bu x t ok err -- }
  S" spf64-lsp: started (stdio)" LOG LOG-CR
  BEGIN
    READ-HEADERS -> len
    len 0 < IF S" spf64-lsp: eof, bye" LOG LOG-CR EXIT THEN
    len READ-BODY -> bu -> ba
    ba bu PARSE-MSG -> ok -> t -> x
    ba FREE DROP
    ok IF
      x t 2DUP 2>R ['] DISPATCH CATCH -> err
      err IF
        2DROP
        S" spf64-lsp: dispatch exception " LOG err LOG-N LOG-CR
      THEN
      2R> JSON-FREE-VALUE
    ELSE
      S" spf64-lsp: bad json, skipped" LOG LOG-CR
    THEN
  AGAIN
;

: LSP-MAIN
  DECIMAL
  OB-INIT
  LSP-LOOP
  BYE
;

LSP-MAIN

