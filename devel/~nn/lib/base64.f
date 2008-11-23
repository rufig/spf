\ Основано на ~ac/lib/string/conv.f, но другая стековая нотация -
\ нет автовыделения буфера.

USER abase
USER lbase
USER nbase
USER-VALUE 64offset

CREATE ALP64 C" ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/" ",    \ "

: AL64 ( n -- char )
  64offset + 64 MOD 1+ ALP64 + C@
;
: -AL64 ( char -- n flag )
  ALP64 COUNT 0
  DO OVER OVER I + C@ =
    IF 2DROP I  64offset - DUP 0< IF 64 + THEN   UNLOOP TRUE EXIT THEN
  LOOP DROP FALSE
;
: AL@
  DUP nbase @ < 0=
  IF DROP 0 ELSE C@ THEN
;
: base64 ( addr u dest -- addr1 u1 )
  abase !
  DUP 0= IF 2DROP  abase @ 0 EXIT THEN
  2DUP + nbase !
  lbase 0!
  DUP 3 /MOD SWAP DUP >R IF 1+ THEN 4 *  >R
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
: debase64 ( addr u dest -- addr1 u1 )
  abase !
  DUP 0= IF 2DROP abase @ 0 EXIT THEN
  lbase 0! nbase 0!
  0 SWAP
  0 ?DO
    OVER I + C@ DUP [CHAR] = =
    IF DROP 0 nbase 1+! ELSE -AL64 DROP THEN 3 I 4 MOD - 0 ?DO 64 * LOOP +
    I 4 MOD 3 = IF abase @ lbase @ + DUP >R !
    R@ C@ R@ 2 CHARS + C@ R@ C! R> 2 CHARS + C!
    3 lbase +! 0 THEN
  LOOP 2DROP abase @ lbase @ nbase @ - 0 MAX
;
