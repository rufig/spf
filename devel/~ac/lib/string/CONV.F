( base64, win-koi, urlencode è äð. êîíâåðòàöèÿ ñòðîê )

USER abase
USER lbase
USER nbase

CREATE ALP64 C" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ",
CREATE  AB64 C" ghijklmnopqrstuvwxyz0123456789+/ABCDEFGHIJKLMNOPQRSTUVWXYZabcdef" ",

: AL64 ( n -- char )
  1+ ALP64 + C@
;
: -AL64 ( char -- n flag )
  ALP64 COUNT 0 DO OVER OVER I + C@ = IF 2DROP I UNLOOP TRUE EXIT THEN LOOP DROP FALSE
;
: AL@
  DUP nbase @ < 0=
  IF DROP 0 ELSE C@ THEN
;
: base64 ( addr u -- addr1 u1 )
  DUP 0= IF 2DROP 4 ALLOCATE THROW abase ! abase @ 0 EXIT THEN
  2DUP + nbase !
  DUP 3 /MOD SWAP DUP >R IF 1+ THEN 4 * DUP >R ALLOCATE THROW abase ! lbase 0!
  0 ?DO
   DUP I + AL@ 65536 *
   OVER I + CHAR+ AL@ 256 * +
   OVER I + CHAR+ CHAR+ AL@ +
   64 /MOD abase @ lbase @ + 3 CHARS + ROT AL64 SWAP C!
   64 /MOD abase @ lbase @ + 2 CHARS + ROT AL64 SWAP C!
   64 /MOD abase @ lbase @ +     CHAR+ ROT AL64 SWAP C!
   AL64 abase @ lbase @ + C!
   lbase @ 4 + lbase !
  3 +LOOP
  DROP
  abase @ R>
  R@ 1 = IF 2DUP + 2 - 2 [CHAR] = FILL THEN
  R> 2 = IF 2DUP + 1 - [CHAR] = SWAP C! THEN
;
: debase64 ( addr u -- addr1 u1 )
  DUP 0= IF 2DROP 4 ALLOCATE THROW abase ! abase @ 0 EXIT THEN
  0 SWAP DUP 4 / 3 * CELL+ ALLOCATE THROW abase ! lbase 0! nbase 0!
  0 ?DO
    OVER I + C@ DUP [CHAR] = =
    IF DROP 0 nbase 1+! ELSE -AL64 DROP THEN 3 I 4 MOD - 0 ?DO 64 * LOOP +
    I 4 MOD 3 = IF abase @ lbase @ + DUP >R !
    R@ C@ R@ 2 CHARS + C@ R@ C! R> 2 CHARS + C!
    3 lbase +! 0 THEN
  LOOP 2DROP abase @ lbase @ nbase @ - 0 MAX
;

: +>BL ( addr u -- )
  0 ?DO DUP C@ [CHAR] + = IF BL OVER C! THEN 1+ LOOP DROP
;
(
: tHERE
  T-HERE T-BEGIN +
;
: tC,
  tHERE C! T-DP 1+!
;
: CONVERT% < addr u -- addr2 u2 >
  HEX
  2DUP +>BL
  tHERE >R >R
  BEGIN
    R@ 0 >
  WHILE
    DUP C@ [CHAR] % =
    IF R> 3 - >R
       3 + DUP 2 - 2 0 0 2SWAP >NUMBER 2DROP D>S tC,
    ELSE R> 1- >R
       DUP C@ tC, 1+
    THEN
  REPEAT DROP R> DROP

  R> tHERE OVER - OVER T-BEGIN - T-DP !
  DECIMAL 
  DUP >R
  DUP CHAR+ ALLOCATE THROW DUP >R SWAP MOVE
  R> R>
;
)
: />\ ( addr u -- )
  0 ?DO DUP I + C@ [CHAR] / = IF [CHAR] \ OVER I + C! THEN LOOP DROP
;
: \>/ ( addr u -- )
  0 ?DO DUP I + C@ [CHAR] \ = IF [CHAR] / OVER I + C! THEN LOOP DROP
;
: ?=&>BL ( addr u -- )
  2DUP S"  HTTP/" SEARCH IF DROP ( 8 BL FILL) TIB - #TIB ! ELSE 2DROP THEN
  0 ?DO
    DUP I + C@ [CHAR] ? = IF BL OVER I + C! THEN
  LOOP DROP
;
: TIB>BL ( addr u -- )
  0 ?DO DUP I + C@ 9 = IF BL OVER I + C! THEN LOOP DROP
;
: TIB;>BL ( addr u -- )
  0 ?DO DUP I + C@ DUP 9 = SWAP [CHAR] ; = OR
        IF BL OVER I + C! THEN 
    LOOP DROP
;
: TIB,>BL ( addr u -- )
  0 ?DO DUP I + C@ DUP [CHAR] , =
                  OVER [CHAR] ; = OR
                  OVER [CHAR] ( = OR
                  SWAP [CHAR] ) = OR
        IF BL OVER I + C! THEN 
    LOOP DROP
;
: TIB,<>>BL ( addr u -- )
  0 ?DO DUP I + C@ DUP [CHAR] , =
                  OVER [CHAR] ; = OR
                  OVER [CHAR] < = OR
                  OVER [CHAR] > = OR
                  OVER [CHAR] ( = OR
                  SWAP [CHAR] ) = OR
        IF BL OVER I + C! THEN 
    LOOP DROP
;
: Strip< ( addr u -- addr2 u2 )
  BEGIN
    OVER C@ 48 < >R
    OVER C@ DUP 57 > SWAP 64 < AND R> OR
  WHILE
    2 - 0 MAX SWAP 1+ SWAP
  REPEAT
;
: ..>-- ( addr u -- )
  S" .." SEARCH
  IF -4012 THROW ELSE 2DROP THEN
;
CREATE KOI C" áâ÷çäå³öúéêëìíîïðòóôõæèãþûýÿùøüàñÁÂ×ÇÄÅ£ÖÚÉÊËÌÍÎÏÐÒÓÔÕÆÈÃÞÛÝßÙØÜÀÑ" ",
CREATE WIN C" ÀÁÂÃÄÅ¨ÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖ×ØÙÚÛÜÝÞßàáâãäå¸æçèéêëìíîïðñòóôõö÷øùúûüýþÿ" ",

: CKOI>WIN ( char1 -- char2 )
  KOI COUNT 0 DO 2DUP I + C@ = IF 2DROP WIN I + 1+ C@ UNLOOP EXIT THEN LOOP DROP
;
: KOI>WIN ( addr u -- addr u )
  2DUP
  0 ?DO DUP I + C@ CKOI>WIN OVER I + C! LOOP DROP
;
: CWIN>KOI ( char1 -- char2 )
  WIN COUNT 0 DO 2DUP I + C@ = IF 2DROP KOI I + 1+ C@ UNLOOP EXIT THEN LOOP DROP
;
: WIN>KOI ( addr u -- addr u )
  2DUP
  0 ?DO DUP I + C@ CWIN>KOI OVER I + C! LOOP DROP
;
: asTib ( addr u -- )
  #TIB ! TO TIB >IN 0!
;
