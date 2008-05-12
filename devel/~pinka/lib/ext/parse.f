\ 01.2002
\ 04.Aug.2004 переименовал (были коллизии имен с acTCP )
\             SPARSE    в  PARSE-FOR
\             SPARSETO  в  PARSE-BEFORE

REQUIRE [UNDEFINED]   lib/include/tools.f
REQUIRE {             lib/ext/locals.f

[UNDEFINED] PARSE-AREA@ [IF]
\ for desc see http://forth.sourceforge.net/word/parse-area-fetch/index.html
: PARSE-AREA@ ( -- a u )
  SOURCE  DUP >IN @ UMIN  TUCK - >R + R>
;                       [THEN]

: PARSE-FOR ( sa su -- a1 u1 true | false )
\ Разбирает до разделителя sa su, разделитель пропускает.
\ При неуспехе >IN не меняется.
  PARSE-AREA@ { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP su + >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;
: PARSE-BEFORE ( sa su -- a1 u1 true | false )
\ Разбирает до разделителя sa su, разделитель НЕ пропускает.
\ При неуспехе >IN не меняется.
  PARSE-AREA@ { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;
