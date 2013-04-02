\ 2013-04-02

: PARSE-STRING ( -- addr u )
  BL SKIP
  SOURCE DROP >IN @ + C@ ( c )
  DUP [CHAR] " <> IF
  DUP [CHAR] ' <> IF
    DROP PARSE-NAME EXIT
  THEN THEN ( c-delimiter )
  /CHAR >IN +!  PARSE
;

\ see also: ./parse.f # ParseFileName
\ see also: http://forth.sourceforge.net/word/s-dollar/index.html # PARSE-S$

\EOF

[DEFINED] MATCH-HEAD [IF]

\ Another implementation without using '>IN'
\ It requires space after last quotation mark.

: PARSE-STRING ( -- addr u )
  PARSE-NAME
  `" MATCH-HEAD 0= IF
  `' MATCH-HEAD 0= IF
      EXIT
  THEN THEN
  OVER CHAR- /CHAR MATCH-TAIL IF EXIT THEN
  DROP DUP CHAR- C@
  PARSE + OVER -
;

[THEN]
