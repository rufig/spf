\ 02.Sep.2004 Thu 09:05

 GET-CURRENT 

VOCABULARY ZOP

ALSO ZOP CONTEXT @ PREVIOUS CONSTANT ZOP-WID

: [Z] ZOP   ; IMMEDIATE
: [F] FORTH ; IMMEDIATE


: COMPILE(nZS>) ( n -- )
  DUP 0 = IF DROP ELSE
  DUP 1 = IF DROP POSTPONE ZS>  ELSE
  DUP 2 = IF DROP POSTPONE 2ZS> ELSE
             LIT, POSTPONE ZSN> THEN THEN THEN
;
: COMPILE(n>ZS) ( n -- )
  DUP 0 = IF DROP ELSE
  DUP 1 = IF DROP POSTPONE >ZS  ELSE
  DUP 2 = IF DROP POSTPONE 2>ZS ELSE
             LIT, POSTPONE >ZSN THEN THEN THEN
;

\ : +   2ZS> + >ZS ;
\ : DO  POSTPONE 2ZS> _DO_  ; IMMEDIATE

: W:  ( n-in n-out "name" -- )

  SWAP
  >IN @ >R  :  R> >IN !
  >IN @ >R  NextWord  R> >IN !
  SIMMED? >R

  ?DUP IF
  R@ IF ( n )
    POSTPONE ?COMP
    LIT, ['] COMPILE(nZS>) COMPILE,
  ELSE
    COMPILE(nZS>)
  THEN THEN

  NextWord SCOMPILE,

  ?DUP IF
  R@ IF ( n )
    POSTPONE ?COMP
    LIT, ['] COMPILE(n>ZS) COMPILE,
  ELSE
    COMPILE(n>ZS)
  THEN THEN

  POSTPONE ;
  R> IF IMMEDIATE THEN
;
( 'W:' делает код дл€ слов немедленного исполнени€
  - только дл€ режима компил€ции..
)

ALSO ZOP DEFINITIONS PREVIOUS

: DUP
  ZSP@ @  -4 ZSP +!  ZSP@ !
;
: DROP
  4 ZSP +!
;
: SWAP
  ZSP@ @  ZSP@ CELL+ @
  ZSP@ !  ZSP@ CELL+ !
;
: OVER
  ZSP@ CELL+ @  -4 ZSP +!  ZSP@ !
;
: NIP
  ZSP@ @  4 ZSP +!  ZSP@ !
;
: DEPTH
  ZDEPTH >ZS
;
: PICK
  ZPICK >ZS
;
: 2DROP
  8 ZSP +!
;
: 2DUP
  ZSP@ 2@  -8 ZSP +!  ZSP@  2!
;
: 2SWAP
  ZSP@ 2@  ZSP@ 8 + 2@
  ZSP@ 2!  ZSP@ 8 + 2!
;
: 2OVER
  ZSP@ 8 + 2@   -8 ZSP +!   ZSP@ 2!
;

: @ ZS> @ >ZS ;
: ! 2ZS> ! ;

: R>  R> R> >ZS >R ;
: >R  R> ZS> >R >R ;

\ ===

: _CREATE-CODE
  R> >ZS
;
: CREATE
  HEADER
  HERE DOES>A !
  ZOP:: ['] _CREATE-CODE COMPILE,
;
: (DOES2)
  2R> >R >ZS
;
\ (DOES1) годитс€ штатный

ALSO ZOP
: DOES>
  ['] (DOES1) COMPILE,
  ['] (DOES2) COMPILE,
; IMMEDIATE

: VARIABLE CREATE 0 , ;
: CONSTANT CREATE ZS> ,  DOES> @ ;

1 1 W: CHARS
1 1 W: CELLS
1 0 W: ALLOT
0 1 W: HERE
1 0 W: IF
0 0 W: ELSE
0 0 W: THEN
0 0 W: BEGIN
0 0 W: REPEAT
0 0 W: AGAIN
1 0 W: WHILE
1 0 W: UNTIL
2 0 W: DO
0 1 W: I
0 1 W: J
0 0 W: LOOP
1 0 W: +LOOP
0 0 W: LEAVE
0 0 W: RECURSE
2 0 W: C!
1 1 W: C@
3 0 W: 2!
1 2 W: 2@
0 1 W: TRUE
0 1 W: FALSE
1 1 W: 1+
1 1 W: 1-
2 1 W: +
2 1 W: -
2 1 W: *
2 1 W: /
1 0 W: .
2 1 W: <
2 1 W: >
2 1 W: U<
2 1 W: U>
2 1 W: =
2 1 W: <>
2 1 W: AND
2 1 W: OR
2 1 W: 0=
2 1 W: XOR
0 0 W: BYE
0 0 W: .Z
0 0 W: ORDER
0 0 W: ALSO
0 0 W: ONLY
0 0 W: DEFINITIONS
0 1 W: '
0 0 W: WORDS
0 0 W: CR
0 0 W: \
0 0 W: ( \ )
0 2 W: S"
2 0 W: TYPE
2 0 W: INCLUDED
1 0 W: ABORT"

PREVIOUS

: s" [CHAR] " PARSE 2DUP + 0 SWAP C! 2>ZS ;

: : : ;

: ; POSTPONE ; ; IMMEDIATE

: NOTFOUND
  STATE @ IF
    POSTPONE SP@  POSTPONE >R
  ELSE
    SP@ 2 CELLS + >R
  THEN

  ['] NOTFOUND CATCH ?DUP IF THROW THEN

  STATE @ IF
    POSTPONE SP@    POSTPONE NEGATE     
    POSTPONE R>     POSTPONE + 
    POSTPONE >CELLS POSTPONE >ZSN 
  ELSE
    SP@ NEGATE R> + >CELLS >ZSN
  THEN
;

SET-CURRENT
