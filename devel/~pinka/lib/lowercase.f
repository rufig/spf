\ 27.Sep.2008

\ see also: ~ac/lib/string/uppercase.f è ~nn/lib/lower.f

: CHAR-LOWERCASE ( c -- c1 )
  DUP [CHAR] A [CHAR] Z 1+ WITHIN IF 32 + EXIT THEN \ ASCII
  DUP [CHAR] À [CHAR] ß 1+ WITHIN IF 32 + THEN \ Windows-1251
;

: LOWERCASE ( addr1 u1 -- )
  OVER + SWAP ?DO
    I C@ CHAR-LOWERCASE I C!
  LOOP
;

\ see also: http://forth.sourceforge.net/word/case-conversion/index.html
\ CHAR>LOWER ( c1 -- c2 )
\ CHAR>UPPER ( c1 -- c2 )

\ kw: LCASE
