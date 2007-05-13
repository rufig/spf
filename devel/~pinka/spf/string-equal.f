\ 2006, 2007

: CEQUAL ( c-addr1 u1 c-addr2 u2 -- flag ) \ counts in chars
  DUP 3 PICK <> IF 2DROP 2DROP FALSE EXIT THEN
  COMPARE 0=
;

: EQUAL ( c-addr1 u1 c-addr2 u2 -- flag ) \ counts in addres units (bytes)
  DUP 3 PICK <> IF 2DROP 2DROP FALSE EXIT THEN
  \ 2>R >CHARS 2R> >CHARS
  COMPARE 0=
;
