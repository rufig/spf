REQUIRE " ~yz/lib/common.f

MODULE: FORMAT

USER-CREATE buf 2048 USER-ALLOT

USER stack-begin
USER ptr
USER old-sp
USER ?left
USER ?trim
USER len
USER filler
USER buffer

: next  ( -- n) stack-begin @ @  CELL stack-begin -! ;
: >> ( c -- ) ptr @ C! ptr 1+! ;
: an>> ( a n -- ) 
  ?trim @ ?DUP IF MIN THEN
  ptr @ SWAP DUP >R CMOVE R> ptr +! 
;
: padding ( n -- ) len @ - NEGATE 0 MAX 0 ?DO filler @ >> LOOP ;
: ?an>> ( a n -- )
  ?left @ IF DUP >R an>> R> padding ELSE DUP padding an>> THEN 
;
: (signed) ( d -- ) DUP >R DABS <# #S R> SIGN #> ;
: (unsigned) ( d -- ) <# #S #> ;

: ~format ( a1 -- a2)
  ?left 0!  len 0!  BL filler !  ?trim 0!
  1+ DUP C@ c: < = IF 1+  TRUE ?left ! THEN
  DUP C@ c: ? = IF 1+ TRUE ?trim ! THEN
  DUP C@ c: 0 = IF c: 0 filler ! THEN
  BEGIN ( a ) DUP C@ DUP c: 0 < OVER c: 9 > OR NOT WHILE
    c: 0 - len @ 10 * + len !
    1+
  REPEAT  
  ?trim @ IF len @ ?trim ! len 0! THEN
  ( a c) CASE
  c: S OF next next ?an>> ENDOF
  c: Z OF next ASCIIZ> ?an>> ENDOF
  c: C OF next >> ENDOF
  c: / OF 13 >> 10 >> ENDOF
  c: ' OF 34 >> ENDOF
  c: . OF 0  >> ENDOF
  c: ~ OF c: ~ >> ENDOF
  c: X OF len @ 0 ?DO BL >> LOOP ENDOF
  c: U OF next S>D (unsigned) ?an>> ENDOF
  c: N OF next S>D (signed) ?an>> ENDOF
  c: D OF next next (signed) ?an>> ENDOF
  c: H OF BASE @ HEX next 0 (unsigned) ?an>> BASE ! ENDOF
  DROP
  END-CASE
  1+
;

EXPORT

: <(? ( a -- ) buffer !  SP@ DUP old-sp ! CELL- stack-begin ! ;
: <( ( -- ) buf <(? ;
: )> ( ... format -- z )
  buffer @ ptr !
  BEGIN DUP C@ DUP WHILE
    DUP c: ~ = IF DROP ~format ELSE >> 1+ THEN
  REPEAT 0 >>
  old-sp @ SP!
  buffer @
;  
: )>. ( ... format -- ) )> .ASCIIZ ;

;MODULE
