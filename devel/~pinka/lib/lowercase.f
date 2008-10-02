\ 27.Sep.2008

\ see also: ~ac/lib/string/uppercase.f

: CHAR-LOWERCASE ( c -- c1 )
  DUP [CHAR] A [CHAR] Z 1+ WITHIN IF 32 + EXIT THEN \ ASCII
  DUP [CHAR] À [CHAR] ß 1+ WITHIN IF 32 + THEN \ Windows-1251
;

: LOWERCASE ( addr1 u1 -- )
  OVER + SWAP ?DO
    I C@ CHAR-LOWERCASE I C!
  LOOP
;

\ kw: LCASE
