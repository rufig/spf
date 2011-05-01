\ простейшая реализация декодирования кириллических имён IMAP-папок,
( там используется модифицированный вариант UTF-7, см. rfc2060 )
\ а то уж очень неудобно логи читать :)

REQUIRE {             lib/ext/locals.f
REQUIRE STR@          ~ac/lib/str5.f
REQUIRE base64        ~ac/lib/string/conv.f
REQUIRE BUNICODE>     ~ac/lib/lin/iconv/iconv.f

: />, ( addr u -- ) \ в IMAP-base64-кодировании используется "," вместо "/"
  0 ?DO DUP C@ [CHAR] / =
  IF [CHAR] , OVER C! THEN 1+ LOOP DROP
;
: ,>/ ( addr u -- )
  0 ?DO DUP C@ [CHAR] , =
  IF [CHAR] / OVER C! THEN 1+ LOOP DROP
;
: (UTF7-IMAP>) { \ s -- addr u }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR] & PARSE ?DUP
    IF s STR+ ELSE DROP THEN
    [CHAR] - PARSE ?DUP
    IF 2DUP ,>/ " {s}==" STR@ debase64
       1+ DUP 2 MOD IF 1+ THEN
       BUNICODE> DROP ASCIIZ> s STR+
    ELSE DROP THEN
  REPEAT
  s STR@
;
: UTF7-IMAP> ( a1 u1 -- a2 u2 ) >STR STR@ ['] (UTF7-IMAP>) EVALUATE-WITH ;

\ S" &BE8- &BDIERwQ1BEAEMA- &BDIEOAQ0BDUEOw- rack'&BD4EMg- &BD8EPg- 3 &BEAEQwQxBDsETw-/&BDA- &BEEENQQzBD4ENAQ9BE8- &BD8EPg- 5, &BD0EPg- &BD4ERwQ1BD0ETA- &BDEEPgQ7BEwESAQ4BDU-" 2DUP TYPE CR UTF7-IMAP> ANSI>OEM TYPE CR

: _Is8Bit ( addr u -- flag ) \ отличается от того, что в mime-decode.f
  0 ?DO DUP I + C@ 127 > IF DROP TRUE UNLOOP EXIT THEN LOOP
  DROP FALSE
;
: -CTRAILING ( a u c -- a u1 )
  >R OVER + BEGIN 2DUP <> WHILE /CHAR - DUP C@ R@ <> UNTIL /CHAR + THEN OVER - RDROP
;
: IsImapNP ( char -- flag )
  DUP 0x7E > IF DROP TRUE EXIT THEN
  0 32 WITHIN
;
: >UTF7-IMAP { a u \ s mode buf -- a2 u2 }
  a u _Is8Bit 0= IF a u EXIT THEN
  "" -> s
  u 0 ?DO
    a I + C@ DUP IsImapNP
    IF mode 0= IF S" &" s STR+ TRUE -> mode "" -> buf THEN
       SP@ 1 buf STR+
       DROP
    ELSE
       DUP [CHAR] & =
       IF DROP S" &-" s STR+
       ELSE
          mode
          IF buf STR@ >BUNICODE base64 [CHAR] = -CTRAILING 2DUP />, s STR+
             S" -" s STR+ FALSE -> mode buf STRFREE
          THEN
          SP@ 1 s STR+ DROP
       THEN
    THEN
  LOOP
  mode
  IF buf STR@ >BUNICODE base64 [CHAR] = -CTRAILING 2DUP />, s STR+
     S" -" s STR+ buf STRFREE
  THEN
  s STR@
;
