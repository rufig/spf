REQUIRE TEMP-ALLOC ~nn/lib/memory/tempalloc.f
REQUIRE IS-/OR\? ~nn/lib/file/fract.f

: FILE>DIR ( addr u addr1 -- addr1 u2)
  OVER 0= IF NIP NIP 0 OVER C! 0 EXIT THEN
  SWAP >R SWAP OVER R@ CMOVE R>
  OVER >R +
  BEGIN
    1- DUP C@ IS-/OR\? OVER R@ = OR
    IF  DUP R@ <>
        IF DUP 1- C@ [CHAR] : = 
        ELSE DUP C@ IS-/OR\? THEN
        IF \ либо первый символ '\', либо X:\
            1+ 
        THEN
        0 SWAP C! 
        TRUE 
    ELSE FALSE THEN
  UNTIL
  R> ASCIIZ>
;

: ONLYNAME ( addr-az u -- addr1 u2)
    OVER + 
    BEGIN 2DUP < WHILE
      1- DUP C@ IS-/OR\?
      IF NIP 1+ DUP THEN
    REPEAT
    NIP ASCIIZ>
;

: ONLYDIR ( a u -- a1 u1) DUP 1+ TEMP-ALLOC FILE>DIR ;
