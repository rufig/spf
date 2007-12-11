( Case insensitivity for SP-FORTH )
( CASE-INS - case sensitivity switcher )
( just include this lib :)

REQUIRE REPLACE-WORD lib\ext\patch.f
REQUIRE ON           lib\ext\onoff.f
REQUIRE [IF]         lib\include\tools.f \ должно быть подключено до caseins-варианта
REQUIRE [else]       lib\ext\caseins-tools.f

VARIABLE CASE-INS \ switcher
CASE-INS ON

WINAPI: CharLowerA USER32.DLL

: UCOMPARE ( addr1 u1 addr2 u2 -- 0 | -1 )
  ROT OVER <> IF DROP 2DROP -1 EXIT THEN
  0 DO
      2DUP C@ CharLowerA SWAP C@ CharLowerA <>
      IF UNLOOP 2DROP -1 EXIT THEN
      1+ SWAP 1+
    LOOP 2DROP 0
;

: USEARCH-WORDLIST ( c-addr u wid -- 0 | xt 1 | xt -1 )
  CASE-INS @ 0= IF
    [ ' SEARCH-WORDLIST BEHAVIOR COMPILE, ] EXIT
  THEN
  @
  BEGIN
    DUP
  WHILE
    >R 2DUP
    R@ COUNT UCOMPARE 0= 
    IF 2DROP R@ NAME> R> ?IMMEDIATE IF 1 ELSE -1 THEN EXIT THEN
    R> CDR
  REPEAT DROP 2DROP 0
;

' USEARCH-WORDLIST TO SEARCH-WORDLIST

: UDIGIT ( C, N1 -> N2, TF / FF ) 
\ N2 - значение литеры C как
\ цифры в системе счисления по основанию N1
\ hex-цифры могут быть строчными
  SWAP
  DUP 0x3A < OVER 0x2F > AND
  IF \ within 0..9
     0x30 -
  ELSE
     DUP 0x40 >
     IF
       DUP 0x60 > IF
         CASE-INS @ IF 0x57 ELSE 2DROP 0 EXIT THEN
       ELSE 0x37 THEN
       -
     ELSE 2DROP 0 EXIT THEN
  THEN
  TUCK > DUP 0= IF NIP THEN
;

' UDIGIT ' DIGIT REPLACE-WORD
