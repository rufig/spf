REQUIRE { ~ac/lib/locals.f

USER STRLAST

(
: ValidateThreadHeap<
  DEBUG @ IF CR ." <" VTH THEN
;
: ValidateThreadHeap>
  DEBUG @ IF VTH ." >" CR THEN
;

\ VARIABLE DEBUG TRUE DEBUG !
: ALLOCATE
ValidateThreadHeap<
  DEBUG @ IF ." ALLOCATE:" SP@ 4 TYPE CR THEN
  ALLOCATE
  OVER R@ SWAP CELL- !
  DEBUG @ IF DUP IF ." ALLOCATE_FAILED" ELSE ." ALLOCATE_OK::[" OVER SP@ 4 TYPE ." ]" DROP THEN CR THEN
ValidateThreadHeap>
;
: RESIZE1 ValidateThreadHeap< RESIZE   OVER R@ SWAP CELL- !
ValidateThreadHeap>
;
: RESIZE
ValidateThreadHeap<
  DEBUG @ IF ." RESIZE:" SP@ 4 TYPE ." ::" OVER SP@ 4 TYPE DROP CR THEN
  RESIZE
  DEBUG @ IF DUP IF ." RESIZE_FAILED" ELSE   OVER R@ SWAP CELL- !
  ." RESIZE_OK::[" OVER SP@ 4 TYPE ." ]" DROP THEN CR THEN
ValidateThreadHeap>
;
: FREE
ValidateThreadHeap<
  DEBUG @ IF ." FREE:" DUP CELL- @ WordByAddr TYPE ." :[" SP@ 4 TYPE ." ]:" DUP 4 TYPE CR THEN
  FREE
  DEBUG @ IF DUP IF ." FREE_FAILED" ELSE ." FREE_OK" THEN CR THEN
ValidateThreadHeap>
;
)

: XCOUNT ( xs -- addr1 u1 )
\ получить строку addr1 u1 из строки со счетчиком xs
\ счетчик - ячейчка, а не байт, в отличие от обычного COUNT
  DUP @ SWAP CELL+ SWAP
\ DEBUG @ IF 2DUP TYPE CR THEN
;
: S'
  [CHAR] ' PARSE [COMPILE] SLITERAL
; IMMEDIATE

: SALLOT ( addr u -- xs )
  DUP 9 + ALLOCATE THROW >R
  DUP R@ ! R@ CELL+ SWAP CMOVE R>
;
: sALLOT
  SALLOT CELL ALLOCATE THROW DUP >R ! R>
;
: s@ ( s -- xs )
  @
;
: s! ( xs s -- )
  !
;
: STR@ ( s -- addr u )
  s@ XCOUNT
\  DEBUG @ IF ." STR@:" 2DUP TYPE ." |" VTH CR THEN
;
: STRFREE ( s -- )
  DUP s@ FREE THROW FREE THROW
;
: STYPE ( s -- )
  DUP STR@ TYPE
  STRFREE
;
: STR+ { addr u s -- }
\ DEBUG @ IF ." STR+:" addr u TYPE CR THEN
  u 0 < IF 0xC000000D THROW THEN
  u 0= IF EXIT THEN \ оптимизация :)
  s s@ DUP @
  u + 9 + RESIZE THROW DUP DUP s s!
  XCOUNT + addr SWAP u CMOVE
  u SWAP +!
;
: STR! { addr u s -- }
  s s@
  u 5 + RESIZE THROW DUP s s!
  addr OVER CELL+ u CMOVE
  u SWAP !
;
: S+ ( s1 s -- )
  OVER STR@ ROT STR+ STRFREE
;
: "" ( -- s )
  S" " sALLOT
;

VECT {NOTFOUND} ' LAST-WORD TO {NOTFOUND}

: {eval} ( ... s -- s ) { s \ sp base state }
  SP@ -> sp
  BASE @ -> base DECIMAL
  STATE @ -> state STATE 0!
  ['] INTERPRET CATCH
  ?DUP IF DUP -2003 = IF {NOTFOUND} THEN
          S" (Error: " s STR+
          ABS 0 <# [CHAR] ) HOLD #S #> s STR+
          base BASE !
          state STATE !
          s EXIT
       THEN
  base BASE !
  state STATE !
  sp SP@ - 
  DUP 12 = IF DROP s STR+ s EXIT THEN
  DUP  8 = IF DROP 0 <# #S #> s STR+ s EXIT THEN
  DUP  4 = IF DROP s EXIT THEN
  DROP
  S" (Error: 2020)" s STR+
  sp SP!
  s
;
: {sn} ( ... s -- s ) { s }
  TIB C@ [CHAR] s = IF s STR+ s EXIT THEN
  TIB C@ [CHAR] n = IF 0 <# #S #> s STR+ s EXIT THEN
  s {eval}
;
: ({...}) ( -- s ) { \ s }
  "" -> s
  #TIB @ 1 = IF s {sn} EXIT THEN
  s {eval}
;
: {...} ( addr u -- ... )
  ['] ({...}) EVALUATE-WITH
;
CHAR { VALUE [CHAR]{
CHAR } VALUE [CHAR]}

: S"{" ( -- addr u )
  S" {" OVER [CHAR]{ SWAP C!
;
: S"}" ( -- addr u )
  S" }" OVER [CHAR]} SWAP C!
;
: "delimiters ( addr 2 -- )
  DROP DUP C@ TO [CHAR]{ CHAR+ C@ TO [CHAR]}
;
: "delimiters: ( -- )
  NextWord "delimiters
;

: ((")) ( -- s ) { \ s }
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
: (") ( addr u -- s )
  ['] ((")) EVALUATE-WITH
;

( вечная слава Андрею Филаткину: )
S" {R0 @ RP@ -}" (") DUP
STR@ ?SLITERAL
R0 @ RP@ - - 4 + CONSTANT LOCALS_STACK_OFFSET
STRFREE

: {STR@LOCAL} ( addr u s -- ) { s \ base }
  BASE @ -> base
  OVER C@ [CHAR] $ =
       IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
          IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
             0 <# #S [CHAR]{ HOLD #> s STR+
             S"  RP+@ STR@" s STR+ S"}" s STR+
          THEN
       ELSE OVER C@ [CHAR] # =
            IF 1- SWAP 1+ SWAP CONTEXT @ SEARCH-WORDLIST
               IF >BODY @ [ ALSO vocLocalsSupport ] LocalOffs [ PREVIOUS ] LOCALS_STACK_OFFSET +
                  0 <# #S [CHAR]{ HOLD #> s STR+
                  S"  RP+@" s STR+ S"}" s STR+
               THEN
            ELSE S"{" s STR+ s STR+ S"}" s STR+ THEN
       THEN
  base BASE !
;
: (STR@LOCAL) ( -- s ) { \ s }
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
: STR@LOCAL ( addr u -- addr u )
  ['] (STR@LOCAL) EVALUATE-WITH STR@
;

: _STRLITERAL ( -- s )
  R> XCOUNT 2DUP + CHAR+ >R
  (")
;
: S, ( addr u -- )
  HERE SWAP DUP ALLOT CMOVE
;
: STRLITERAL ( addr u -- )
  \ похоже на SLITERAL, но длина строки не ограничена 255
  \ и компилируемая строка при выполнении "разворачивается" по (")
  STATE @ IF
             ['] _STRLITERAL COMPILE,
             DUP , S, 0 C,
          ELSE
             (")
          THEN
; IMMEDIATE

: CRLF
  LT 2
;
CREATE _S""" CHAR " C,
: ''
  _S""" 1
;

: PARSE" { \ s -- addr u }
  "" -> s
  BEGIN
    [CHAR] " PARSE
    2DUP + C@ [CHAR] " <>
  WHILE
    s STR+
    CRLF s STR+
    REFILL 0= THROW
  REPEAT
  s STR+
  s STR@
  STR@LOCAL
;

: " ( "ccc" -- )
  PARSE" POSTPONE STRLITERAL
; IMMEDIATE

USER _LASTFILE 
: LastFileFree _LASTFILE @ ?DUP IF FREE THROW _LASTFILE 0! THEN ;

: FILE ( addr u -- addr1 u1 )
  { \ f mem }
  R/O OPEN-FILE-SHARED IF DROP S" " EXIT THEN
   -> f
  f FILE-SIZE THROW D>S DUP CELL+ ALLOCATE THROW -> mem
  mem SWAP f READ-FILE THROW
  f CLOSE-FILE THROW
  mem SWAP
  DUP IF OVER _LASTFILE ! THEN
;
: S@ ( addr u -- addr2 u2 )
\ вычислить {} в строке
\ ValidateThreadHeap<
  (") STR@
\ ValidateThreadHeap>
;
: EVAL-FILE ( addr u -- addr1 u1 )
  FILE S@
;
: S! ( addr u var_addr -- )
\ ValidateThreadHeap<
  "" DUP ROT ! STR+
\ ValidateThreadHeap>
;
: LSTRFREE ( -- )
  STRLAST @ STRFREE
;

(

S" test1" sALLOT STYPE CR
"" VALUE TEST1 S" test2" TEST1 STR+ TEST1 STYPE CR

PARSE" test3" TYPE CR

PARSE" test4
test4" TYPE CR

: TEST5 " test5" ; TEST5 STYPE CR

: TEST6 " test6
test6
test6" ; TEST6 STYPE CR

S" test7" 7  " test7__{n}{s}__test7" STYPE CR

" test8_{5}__{S' test8'}_|{ \ nothing }|__{1 2 3}__" STYPE CR

: TEST9 { \ str nn } " string" -> str 55 -> nn " __{$str}__{#nn}__" STYPE CR ;
 TEST9

: TEST { \ s } " zzz1" -> s S" test0" s STR! s STYPE CR ; TEST


\ : TEST { a b c } " 777{RP@ 180 DUMP HERE 0}888" STYPE ;

\ HEX 77 88 99 TEST

\ Тесты:

: TEST S" test" ;
" abc{TEST}123 5+5={5 5 +} Ok" STYPE CR

: TEST2 " abc{TEST}123 5+5={5 5 +} Ok {ZZZ} OK!" STYPE CR ;
TEST2

" 
  abc
  def
  {TEST}
  123
" 
STYPE

: TEST3  { \ n t k }
  9 -> n
  " abcd" -> t
  3 -> k
  " |123|{$t}|123|{#n}|123|{#k}|{S' file1.txt' EVAL-FILE}<End of file>" STYPE
;
TEST3

)