\ 02.Sep.2004 Thu 08:48

REQUIRE NDROP ~pinka\lib\ext\common.f

256 CELLS VALUE /ZS

10 CELLS USER-ALLOT  
USER-CREATE ZS9
/ZS USER-ALLOT
USER-CREATE ZS0
10 CELLS USER-ALLOT

USER ZSP  ZS0 ZSP !

: ZSP@ ( -- a ) ZSP @ ;
: ZSP! ( a -- ) ZSP ! ;

: ?ZSP ( -- )
  ZSP@ ZS0 U> ABORT" Z stack undeflow"
  ZSP@ ZS9 U< ABORT" Z stack overflow"
;

: >ZS ( x -- )
  -4 ZSP +!  ZSP@ !
;
: ZS> ( -- x )
  ZSP@ @   4 ZSP +!
;
: 2>ZS ( x x -- )
  SWAP  
  -4 ZSP +!  ZSP@ !
  -4 ZSP +!  ZSP@ !
;
: 2ZS> ( -- x x )
  ZSP@ @   4 ZSP +!
  ZSP@ @   4 ZSP +!
  SWAP
;
: ZNDROP ( n -- )
  CELLS ZSP +!
;
: >ZSN ( i*x i -- )
  >R
  SP@    R@ CELLS   DUP NEGATE ZSP +!  ZSP@  SWAP   MOVE
  R> NDROP
;
: ZSN> ( i -- i*x )
  CELLS >R
  SP@ R@ NEGATE + SP!
  SP@ ZSP@ SWAP R@ MOVE
  R> ZSP +!
;
: ZDEPTH ( -- u )
  ZS0 ZSP@ - 4 /
;
: ZPICK ( i -- x )
  CELLS ZSP@ + @
;

\ ==============================================

: .Z ( -- )
  ?ZSP
  ZDEPTH ?DUP IF
    0 SWAP 1- DO I ZPICK .  -1 +LOOP
  THEN
;
: .ZN ( n -- )
  ['] ?ZSP CATCH DUP IF ZS0 ZSP! THEN THROW
  ZDEPTH UMIN ?DUP IF
    0 SWAP 1- DO I ZPICK .  -1 +LOOP
  THEN
;
