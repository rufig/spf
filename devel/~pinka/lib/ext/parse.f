\ 01.2002

REQUIRE [UNDEFINED]   lib\include\tools.f
REQUIRE {             ~ac\lib\locals.f

[UNDEFINED] PARSE-AREA@ [IF]
\ for desc see http://forth.sourceforge.net/word/parse-area-fetch/index.html
: PARSE-AREA@ ( -- a u )
  SOURCE SWAP >IN @ + SWAP >IN @ -
;                       [THEN]

: SPARSE ( sa su -- a1 u1 true | false )
\ Разбирает до разделителя sa su, разделитель пропускает.
\ При неуспехе >IN не меняется.
  PARSE-AREA@ { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP su + >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;
: SPARSETO ( sa su -- a1 u1 true | false )
\ Разбирает до разделителя sa su, разделитель НЕ пропускает.
\ При неуспехе >IN не меняется.
  PARSE-AREA@ { sa su a u }
  a u sa su SEARCH  IF 
  DROP a -  DUP >IN +!
  a SWAP TRUE  EXIT THEN
  2DROP FALSE
;
