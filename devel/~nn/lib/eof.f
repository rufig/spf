REQUIRE [UNDEFINED] lib/include/tools.f

[UNDEFINED] \EOF [IF]
: \EOF  ( -- )
  POSTPONE \
  BEGIN REFILL 0= UNTIL
  POSTPONE \
;
[THEN]

: <EOF> \EOF ;

: >EOF ( h --)
    >R
    R@ FILE-SIZE 0=
    IF R@ REPOSITION-FILE DROP
    ELSE 2DROP THEN
    RDROP
;
