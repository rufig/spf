\ ƒополнение CONVERT% возможностью раскодировани€ %u-unicode

REQUIRE CONVERT%      ~ac/lib/string/get_params.f 
REQUIRE UNICODE>UTF8  ~ac/lib/win/com/com.f

USER _convUnicode

: CONVERT% { a u \ a2 u2 i -- a2 u2 }
  a u [CHAR] + BL CONVERT
  u ALLOCATE THROW -> a2
  0 -> u2  0 -> i  HEX
  BEGIN
    i u U<
  WHILE
    a i + C@ DUP [CHAR] % =
    IF DROP a i + 1+ C@ [CHAR] u <>
       IF
         0 0 a i + CHAR+ 2 >NUMBER NIP
         IF 2DROP [CHAR] _ \ входной текст неправильно кодирован
         ELSE D>S THEN i 2+ -> i
       ELSE
         0 0 a i + 2+  4 >NUMBER 2DROP D>S i 5 + -> i
         _convUnicode !
         _convUnicode 2 UNICODE> DROP C@
       THEN
    THEN
    a2 u2 + C!
    i 1+ -> i
    u2 1+ -> u2
  REPEAT DECIMAL
  a2 u2
;

\ S" %u0411%u0430%u043B%u0430%u043A%u0438%u0440%u0435%u0432%u043E"  CONVERT% ANSI>OEM TYPE CR
\ S" %u0420%u043E%u0441%u0441%u0438%u044F" CONVERT% ANSI>OEM TYPE CR
