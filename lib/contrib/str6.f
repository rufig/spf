\ 1999-10-12 Andrey Cherezov
\ 2000-12-25 - 2007-02-07 Andrey Cherezov -- many modifications
\ 2025-02-05 ~iva, ~ruv -- "str6.f", a fork of "str5.f"
\       - Allow loading in a case-insensitive mode,
\         - for this purpose the following words have been renamed:
\           - `SALLOT`  to `XSALLOT`    (to differentiate from `sALLOT`)
\           - `s@`      to `str>xs`     (to differentiate from `S@`)
\           - `s!`      to `str-xs!`    (to differentiate from `S!`)
\           - and some local varibales.
\       - Change comments to English.
\       - Replace the documentation with a link to the original file.
\       - Improve some definitions.
\       - Place implementation details in a word list. Use better naming (see the `EXPORT` section at the module end).



\ See the documentation in "devel/~ac/str5.f".

\ DataType: str => x\0          \ an opaque str identifier
\ DataType: xs => a-addr        \ the address of an xcounted string
\ DataType: sd => ( c-addr u )  \ a character string
\ DataTypePrivate: any => i*x
\ DataTypePrivate: str => a-addr  \ the address of an str internal structure


REQUIRE [IF]    lib/include/tools.f
REQUIRE SYNONYM lib/include/wordlist-tools.f
REQUIRE {       lib/ext/locals.f


[UNDEFINED] XCOUNT [IF]
: XCOUNT ( xs -- addr1 u1 )
\ addr1 is the sum of xs and the cell size,
\ u1 is the value stored at xs
\ This word is similar to `COUNT`, but the counter is a cell, not a character.
  DUP CELL+ SWAP @
;
[THEN]


MODULE: support-str6
( wid.compilation-prev )

USER STRLAST

: S' ( "ccc<tick>" -- ) \ RunTime: ( -- sd )
  [CHAR] ' PARSE [COMPILE] SLITERAL
; IMMEDIATE

: XSALLOT ( sd -- xs.new )
  DUP 9 + ALLOCATE THROW >R
  DUP R@ ! R@ CELL+ SWAP CMOVE R>
  0 OVER XCOUNT + C!
;
: sALLOT ( sd -- str.new )
  XSALLOT CELL ALLOCATE THROW DUP >R ! R>
;
: str>xs ( str -- xs )
  @
;
: str-xs! ( xs str -- )
  !
;
: STR@ ( str -- sd )
  str>xs XCOUNT
;
: STRFREE ( str.free -- )
  DUP STRLAST @ = IF STRLAST 0! THEN
  DUP str>xs FREE THROW FREE THROW
;
: STYPE ( str.free -- )
  DUP STR@ TYPE
  STRFREE
;
: STR+ ( addr +n str -- ) { addr u s -- } \ +n is a non-negative integer
  u 0 < IF -24 THROW THEN \ "invalid numeric argument"
  u 0= IF EXIT THEN \ optimization :)
  s str>xs DUP @
  u + 9 + RESIZE THROW DUP DUP s str-xs!
  XCOUNT + addr SWAP u CMOVE
  u SWAP +!
  0 s STR@ + C!
;
: STR! ( sd str ) { addr u s -- }
  s str>xs
  u 5 + RESIZE THROW DUP s str-xs!
  addr OVER CELL+ u CMOVE
  u SWAP !
  0 s STR@ + C!
;
: S+ ( str.free str -- )
  OVER STR@ ROT STR+ STRFREE
;
: "" ( -- str.new )
  S" " sALLOT
;

VECT {NOTFOUND} ' LAST-WORD TO {NOTFOUND}

: LSTRFREE1 ( -- )
  STRLAST @ ?DUP IF STRFREE STRLAST 0! THEN
;
VECT LSTRFREE ' LSTRFREE1 TO LSTRFREE

: {eval} ( any str1 -- str1 ) { s \ orig-sp orig-base orig-state }
  SP@ -> orig-sp
  BASE @ -> orig-base DECIMAL
  STATE @ -> orig-state STATE 0!
  STRLAST 0!
  ['] INTERPRET CATCH
  ?DUP IF DUP -2003 = IF {NOTFOUND} THEN
          DUP -2 = ER-U @ 0<> AND
          IF DROP ER-A @ ER-U @ s STR+
          ELSE
            S" (Error: " s STR+
            ABS 0 <# [CHAR] ) HOLD #S #> s STR+
          THEN
          orig-base BASE !
          orig-state STATE !
          s EXIT
       THEN
  orig-base BASE !
  orig-state STATE !
  orig-sp SP@ -
  DUP 12 = IF DROP s STR+ s DUP STRLAST @ <> IF LSTRFREE THEN EXIT THEN
  DUP  8 = IF DROP 0 <# #S #> s STR+ s EXIT THEN
  DUP  4 = IF DROP s EXIT THEN
  DROP
  S" (Error: 2020)" s STR+
  orig-sp SP!
  s
;
: {sn} ( any str1 -- str1 ) { s }
  TIB C@ [CHAR] s = IF s STR+ s EXIT THEN
  TIB C@ [CHAR] n = IF 0 <# #S #> s STR+ s EXIT THEN
  TIB C@ [CHAR] d = IF <# #S #> s STR+ s EXIT THEN
  TIB C@ [CHAR] - = IF S>D DUP >R DABS <# #S R> SIGN #> s STR+ s EXIT THEN
  TIB C@ [CHAR] c = IF SP@ 1 s STR+ DROP s EXIT THEN
  s {eval}
;
: ({...}) ( any -- str.new ) { \ s }
  "" -> s
  #TIB @ 1 = IF s {sn} EXIT THEN
  s {eval}
;
: {...} ( any sd.placeholder -- str.new )
  ['] ({...}) EVALUATE-WITH
;

CHAR { VALUE [CHAR]{
CHAR } VALUE [CHAR]}
\ NB: this approach is not thread-safe
: S"{" ( -- sd.left-bracket )
  S" {" OVER [CHAR]{ SWAP C!
;
: S"}" ( -- sd.right-bracket )
  S" }" OVER [CHAR]} SWAP C!
;
: "delimiters ( addr 2 -- )
  DROP DUP C@ TO [CHAR]{ CHAR+ C@ TO [CHAR]}
;
: "delimiters: ( -- )
  NextWord "delimiters
;

: ((")) ( any -- str.new ) { \ s }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR]{ PARSE
    s STR+
    [CHAR]} PARSE ?DUP
    IF {...} s S+
    ELSE DROP THEN
  REPEAT
  s DUP STRLAST !
;


100 VALUE STR_DEEP_MAX

USER _STR_DEEP

: (") ( any sd.template -- str.new ) { \ c }
  [CHAR]{ -> c
  2DUP ^ c 1 SEARCH NIP NIP
  IF
    _STR_DEEP @ STR_DEEP_MAX  U< IF
      1  _STR_DEEP +!
      ['] ((")) EVALUATE-WITH
      -1 _STR_DEEP +!
      EXIT
    THEN
    2DROP S" (Error: STR TOO DEEP)"
  THEN
  sALLOT DUP STRLAST !
;

( Eternal glory to Andrey Filatkin : )
S" {R0 @ RP@ -}" (") DUP
STR@ ?SLITERAL
R0 @ RP@ - - 4 + CONSTANT LOCALS_STACK_OFFSET
STRFREE

: {STR@LOCAL} ( sd.placeholder str -- ) { s \ orig-base }
  BASE @ -> orig-base
  OVER C@ [CHAR] $ =
       IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
          IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
             0 <# #S [CHAR]{ HOLD #> s STR+
             S"  RP+@ str6::STR@" s STR+ S"}" s STR+
          THEN
       ELSE OVER C@ [CHAR] # =
            IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
               IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
                  0 <# #S [CHAR]{ HOLD #> s STR+
                  S"  RP+@" s STR+ S"}" s STR+
               THEN
            ELSE S"{" s STR+ s STR+ S"}" s STR+ THEN
       THEN
  orig-base BASE !
;
: (STR@LOCAL) ( -- str.new ) { \ s }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR]{ PARSE
    s STR+
    [CHAR]} PARSE ?DUP
    IF s {STR@LOCAL}
    ELSE DROP THEN
  REPEAT
  s
;

: STR@LOCALs ( sd.template -- str.new )
  ['] (STR@LOCAL) EVALUATE-WITH
;

: _STRLITERAL ( any -- str.new  ;  R: colon-sys1 -- colon-sys2 )
  R> XCOUNT 2DUP + CHAR+ >R
  (")
;
\ : S, ( addr u -- )
\   HERE SWAP DUP ALLOT CMOVE
\ ;
: STRLITERAL ( compil: false ; any sd.template -- str.new  |  compil: true ; sd.template -- ) \ RunTime: ( any -- str.new )
  \ It is similar to SLITERAL, but the length of the string is not limited to 255
  \ and the compiled string is "unrolled" by `(")` when "executed".
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP , S, 0 C,
          ELSE
             (")
          THEN
; IMMEDIATE

CREATE strCRLF 13 C, 10 C,

: CRLF ( -- addr 2 )
  strCRLF 2
;
CREATE _S""" CHAR " C,
: '' ( -- addr 1 )
  _S""" 1
;

USER _PARSED"
USER _STR_LOCAL

: _XSLITERAL-CODE ( -- sd ; R: colon-sys1 -- colon-sys2 ) R> XCOUNT 2DUP + CHAR+ >R ;

: XSLITERAL ( sd -- ) \ RunTime: ( -- sd )
  STATE @ IF
             ['] _XSLITERAL-CODE COMPILE,
             DUP , S, 0 C,
             EXIT
  THEN
  \ 2DUP + 0 SWAP C!
  sALLOT STR@ ( sd )
  \ - don't corrupt input, create a copy on the heap \ 2025-02-09 ~ruv
; IMMEDIATE

: XPARSE" ( -- sd )
  "" >R
  BEGIN
    [CHAR] " PARSE
    2DUP + C@ [CHAR] " <>
  WHILE
    R@ STR+
    CRLF R@ STR+
    REFILL 0= THROW
  REPEAT
  R@ STR+
  R> DUP _PARSED" !
  STR@
;

: PARSE" ( -- sd )
  XPARSE"
  [CHAR]{ >R
  2DUP RP@ 1 SEARCH NIP NIP RDROP
  IF STR@LOCALs DUP _STR_LOCAL ! STR@ THEN
;

: _PARSED"FREE ( -- ) _PARSED" @ ?DUP IF STRFREE _PARSED" 0! THEN ;

: XS" ( "ccc<quot>" -- ) \ RunTime: ( -- sd )
  XPARSE" [COMPILE] XSLITERAL
  STATE @ IF _PARSED"FREE THEN
; IMMEDIATE

: " ( "ccc<quot>" -- ) \ RunTime: ( any -- str.new )
  PARSE" [COMPILE] STRLITERAL
  \ STATE @ IF _PARSED" @ ?DUP IF STRFREE _PARSED" 0! THEN  THEN
  _PARSED" @ ?DUP IF STRFREE _PARSED" 0! THEN
  _STR_LOCAL @ ?DUP IF STRFREE _STR_LOCAL 0! THEN
; IMMEDIATE

USER _LASTFILE
USER _LASTFILESIZE

: LastFileFree ( -- ) _LASTFILE @ ?DUP IF FREE THROW _LASTFILE 0! _LASTFILESIZE 0! THEN ;
: LastFileSize ( -- u ) _LASTFILESIZE @ ;

: FFILE ( fileid -- sd.data ) { f \ mem -- a u } \ Read the entire file and close the handle
  f FILE-SIZE THROW D>S DUP _LASTFILESIZE !
  DUP CELL+ ALLOCATE THROW DUP _LASTFILE ! -> mem
  mem SWAP f READ-FILE THROW
  f CLOSE-FILE THROW
  mem SWAP
\  DUP IF OVER _LASTFILE ! THEN
;
: FFILEO ( fileid -- sd.data ) { f \ mem -- a u } \ Read the entire file and leave the handle open
  f FILE-SIZE THROW D>S DUP _LASTFILESIZE !
  DUP CELL+ ALLOCATE THROW DUP _LASTFILE ! -> mem
  mem SWAP f READ-FILE THROW
\  f CLOSE-FILE THROW
  mem SWAP
\  DUP IF OVER _LASTFILE ! THEN
;
: FILE ( sd.filename -- sd.data )
  R/O OPEN-FILE-SHARED IF DROP 0 ALLOCATE THROW DUP _LASTFILE ! _LASTFILESIZE 0! 0 EXIT THEN
  FFILE
;
: FILEFREE ( addr.data -- )
  DUP _LASTFILE @ =
  IF _LASTFILE 0! _LASTFILESIZE 0! THEN
  FREE THROW
;

: WFILE ( sd.data sd.filename-new -- )
  R/W CREATE-FILE THROW DUP >R
  WRITE-FILE THROW
  R> CLOSE-FILE THROW
;

: S@ ( sd.template -- sd.interpolated )
\ calculate '{}' in the string sd.template
\ NB: there is an str leak.
\ ValidateThreadHeap<
  (") STR@
\ ValidateThreadHeap>
;
: EVAL-FILE ( sd.filename -- sd.interpolated )
\ The original file contents can be freed by `LastFileFree`
\ sd.interpolated[addr] can be freed by `FREE`
\ NB: there is an str leak.
  FILE S@
;
: S! ( sd addr.cell -- )
\ ValidateThreadHeap<
  >R sALLOT R> !
\ ValidateThreadHeap>
;

\ ~ygrek:
: >STR ( sd -- str.new ) sALLOT ;
: STRLEN ( str -- u ) STR@ NIP ;
: STRA ( str -- addr ) STR@ DROP ;


EXPORT

SYNONYM CRLF            CRLF ( -- sd.crlf )
SYNONYM ''              '' ( -- sd.quot )
SYNONYM S'              S' ( "ccc<tick>" -- ) \ RunTime: ( -- sd )

SYNONYM NEW-STR         "" ( -- str.new ) \ an emtpy str
SYNONYM STR"            "  ( compil: false ; any "ccc<quot>" -- str.new  |  compil: true ; "ccc<quot>" -- ) \ RunTime: ( any -- str.new )
SYNONYM DEL-STR         STRFREE ( str.free -- )
SYNONYM PRINT-STR       STYPE ( str.free -- )
SYNONYM STR>STRING      STR@ ( str -- sd )
SYNONYM STR!            STR! ( sd str -- )
SYNONYM STR+!           STR+ ( sd str -- )
SYNONYM JOIN-STR        S+ ( str.free str -- )

SYNONYM >STR            sALLOT      ( sd.data -- str.new )
SYNONYM >STR!           S!          ( sd.data addr.cell -- )
SYNONYM STREVAL         S@          ( sd.template -- sd.interpolated )
SYNONYM STREVAL-FILE    EVAL-FILE   ( sd.filename -- sd.interpolated )

' support-str6 XT>WID CONSTANT str6 \ just a wordlist

( wid.compilation-prev )
;MODULE



(
\ Examples:

S" test1" >STR PRINT-STR CR
NEW-STR VALUE TEST1  S" test2" TEST1 STR+!  TEST1 PRINT-STR CR

str6::PARSE" test3" TYPE CR

str6::PARSE" test4
test4" TYPE CR

: TEST5 STR" test5" ; TEST5 PRINT-STR CR

: TEST6 STR" test6
test6
test6" ; TEST6 PRINT-STR CR

S" test7" 7  STR" test7__{n}{s}__test7" PRINT-STR CR

STR" test8_{5}__{S' test8'}_|{ \ nothing }|__{1 2 3}__" PRINT-STR CR

: TEST9 { \ str nn } STR" string" -> str  55 -> nn  STR" __{$str}__{#nn}__" PRINT-STR CR ;
 TEST9

: TEST { \ s } STR" zzz1" -> s  S" test0" s STR! s PRINT-STR CR ; TEST


\ : TEST { a b c } STR" 777{RP@ 180 DUMP HERE 0}888" STRTYPE ;
\ HEX 77 88 99 TEST

\ Tests:
: TEST S" test" ;
STR" abc{TEST}123 5+5={5 5 +} Ok" PRINT-STR CR

: TEST2 STR" abc{TEST}123 5+5={5 5 +} Ok {ZZZ} OK!" PRINT-STR CR ;
TEST2

STR"
  abc
  def
  {TEST}
  123
"
PRINT-STR CR

: TEST3  { \ n t k }
  9 -> n
  STR" abcd" -> t
  3 -> k
  STR" |123|{$t}|123|{#n}|123|{#k}|{S' file1.txt' STREVAL-FILE}<End of file>" PRINT-STR CR
;
TEST3

\ TEST4:
S" aaa" 15 CHAR z STR" char by code={c}=, number {n} and string:{s} - OK!" PRINT-STR CR

-5 DUP STR" {n} : {-}" PRINT-STR CR
)
