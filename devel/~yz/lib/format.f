REQUIRE " ~yz/lib/common.f

MODULE: FORMAT

USER-CREATE buf 2048 USER-ALLOT

USER stack-begin
USER ptr
USER old-sp
USER ?left
USER len
USER filler

: next  ( -- n) stack-begin @ @  CELL stack-begin -! ;
: >> ( c -- ) ptr @ C! ptr 1+! ;
: an>> ( a n -- ) ptr @ SWAP DUP >R CMOVE R> ptr +! ;
: padding ( n -- ) len @ - NEGATE 0 MAX 0 ?DO filler @ >> LOOP ;
: ?an>> ( a n -- ) 
  ?left @ IF DUP padding an>> ELSE DUP >R an>> R> padding THEN ;
: (signed) ( d -- ) DUP >R DABS <# #S R> SIGN #> ;
: (unsigned) ( d -- ) <# #S #> ;

: ~format ( a1 -- a2)
  ?left 0!  len 0!  BL filler !
  1+ DUP C@ c: < = IF 1+  TRUE ?left ! THEN
  DUP C@ c: 0 = IF c: 0 filler ! TRUE ?left ! THEN
  BEGIN ( a ) DUP C@ DUP c: 0 < OVER c: 9 > OR NOT WHILE
    c: 0 - len @ 10 * + len !
    1+
  REPEAT  
  ( a c) CASE
  c: S OF next next ?an>> ENDOF
  c: Z OF next ASCIIZ> ?an>> ENDOF
  c: C OF next >> ENDOF
  c: / OF 13 >> 10 >> ENDOF
  c: ' OF 34 >> ENDOF
  c: X OF len @ 0 ?DO BL >> LOOP ENDOF
  c: U OF next 0 (unsigned) ?an>> ENDOF
  c: N OF next 0 (signed) ?an>> ENDOF
  c: D OF next next (signed) ?an>> ENDOF
  c: H OF BASE @ HEX next 0 (unsigned) ?an>> BASE ! ENDOF
  DROP
  END-CASE
  1+
;

EXPORT

: <( ( ... format -- ) SP@ DUP old-sp ! CELL- stack-begin ! ;
: )> ( ... format -- z )
  buf ptr !
  BEGIN DUP C@ DUP WHILE
    DUP c: ~ = IF DROP ~format ELSE >> 1+ THEN
  REPEAT 0 >>
  old-sp @ SP!
  buf
;  
: )>. ( ... format -- ) )> .ASCIIZ ;

;MODULE
