\ 2006, 2007

REQUIRE NAMING ~pinka/spf/compiler/native-wordlist.f

: CEQUALS ( c-addr1 u1 c-addr2 u2 -- flag ) \ counts in chars
  DUP 3 PICK <> IF 2DROP 2DROP FALSE EXIT THEN
  COMPARE 0=
;

: EQUALS ( c-addr1 u1 c-addr2 u2 -- flag ) \ counts in addres units (bytes)
  DUP 3 PICK <> IF 2DROP 2DROP FALSE EXIT THEN
  \ 2>R >CHARS 2R> >CHARS
  COMPARE 0=
;

( The idea:
  'EQUALS' as verb should be in the same form as 'STARTS-WITH', 'ENDS-WITH', 'CONTAINS'
)

\ aliases for back compatibility
S" EQUAL"   ' EQUALS    NAMING
S" CEQUAL"  ' CEQUALS   NAMING
