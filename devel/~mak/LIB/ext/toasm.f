REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE [IFNDEF] ~nn\lib\ifdef.f
S" LIB\EXT\CASE.F" INCLUDED

: DEFER CREATE ['] NOOP , DOES> @ EXECUTE ;
: DEFER@ ' >BODY STATE @ IF POSTPONE LITERAL POSTPONE @ ELSE @ THEN ; IMMEDIATE
: IS '  >BODY STATE @ IF POSTPONE LITERAL POSTPONE ! ELSE ! THEN ; IMMEDIATE

: +TO ' >BODY STATE @ IF POSTPONE LITERAL POSTPONE +! ELSE +! THEN ; IMMEDIATE

: REVEAL SMUDGE ;
: COMPILE ' POSTPONE LITERAL POSTPONE COMPILE, ; IMMEDIATE
: (;CODE) R> LATEST 5 - ! ;
: -IF POSTPONE DUP POSTPONE IF ; IMMEDIATE
[IFNDEF] ALIAS
: ALIAS         ( xt -<name>- )            \ W32F
\ *G Creates an alias of a word that is non-imediate (unless IMMEDIATE is used).
\ *P NOTE View of either name can go to the synonym instead (it depends which name
\ ** is found first in a full dictionary search).
                HEADER LAST-CFA ! ;
[THEN] 

VECT EXIT-ASSEMBLER

VOCABULARY ASSEMBLER

[IFNDEF] ((
: ((  ( -- )
  BEGIN
    PARSE-WORD DUP 0=
    IF  NIP  REFILL   0= IF DROP TRUE THEN
    ELSE  S" ))" COMPARE 0=  THEN
  UNTIL
; IMMEDIATE

[THEN]
