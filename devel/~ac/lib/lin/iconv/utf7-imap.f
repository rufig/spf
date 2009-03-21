\ простейшая реализация декодирования кириллических имён IMAP-папок,
( там используется модифицированный вариант UTF-7, см. rfc2060 )
\ а то уж очень неудобно логи читать :)

REQUIRE {             ~ac/lib/locals.f
REQUIRE STR@          ~ac/lib/str5.f
REQUIRE base64        ~ac/lib/string/conv.f
REQUIRE BUNICODE>     ~ac/lib/lin/iconv/iconv.f

: (UTF7-IMAP>) { \ s -- addr u }
  "" -> s
  BEGIN
    >IN @ #TIB @ <
  WHILE
    [CHAR] & PARSE ?DUP
    IF s STR+ ELSE DROP THEN
    [CHAR] - PARSE ?DUP
    IF " {s}==" STR@ debase64
       1+ DUP 2 MOD IF 1+ THEN
       BUNICODE> DROP ASCIIZ> s STR+
    ELSE DROP THEN
  REPEAT
  s STR@
;
: UTF7-IMAP> ( a1 u1 -- a2 u2 ) ['] (UTF7-IMAP>) EVALUATE-WITH ;

\ S" &BE8- &BDIERwQ1BEAEMA- &BDIEOAQ0BDUEOw- rack'&BD4EMg- &BD8EPg- 3 &BEAEQwQxBDsETw-/&BDA- &BEEENQQzBD4ENAQ9BE8- &BD8EPg- 5, &BD0EPg- &BD4ERwQ1BD0ETA- &BDEEPgQ7BEwESAQ4BDU-" UTF7-IMAP> ANSI>OEM TYPE CR
