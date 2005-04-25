\ http://forth.sourceforge.net/word/s-dollar/index.html
\ authors:
\    The following people contributed to the discussion:
\    Tom Zegub, Jos v.d.Ven, Michael Gassanenko, Ruvim Pinka

REQUIRE CASE lib\ext\case.f

\ Match delimiters for string
: (S-DELIM) ( c1 -- c2)
  CASE
    [CHAR] < OF [CHAR] > ENDOF
    [CHAR] { OF [CHAR] } ENDOF
    [CHAR] [ OF [CHAR] ] ENDOF
    [CHAR] ( OF [CHAR] ) ENDOF
    DUP                         \ use same character for all others
  ENDCASE
;
\ run-time routine for string parsing
: PARSE-S$ ( <char1>ccc<char2> -- addr u)
  SOURCE >IN @ MIN +          \ address of 1st character
  C@ (S-DELIM)                \ determine second delimiter
    1 CHARS >IN +!            \ bump past first  delimiter
  PARSE                       \ parse to  second delimiter
;
\ parse string; if compiling, compile it as a literal.
: S$ ( <char1>ccc<char2> -- addr u)
  PARSE-S$
  STATE @ IF ( compiling)
    POSTPONE SLITERAL      \ include parsed string in definition
  THEN
; IMMEDIATE

\ Notes:
\ 1. We assume that the character size is 1 CHARS.
\ 2. We assume that PARSE works correctly even when >IN
\ exceeds the input text buffer size (the length returned by SOURCE).
\ 3. We also assume that we can read the character at the address returned
\ by the phrase SOURCE +
