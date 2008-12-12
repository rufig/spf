\ $Id$

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE BOUNDS ~ygrek/lib/string.f

MODULE: XMLSAFE

: EMIT
   DUP BL < IF DROP BL EMIT EXIT THEN
   DUP [CHAR] < = IF DROP ." &lt;" EXIT THEN
   DUP [CHAR] > = IF DROP ." &gt;" EXIT THEN
   DUP [CHAR] " = IF DROP ." &quot;" EXIT THEN
   DUP [CHAR] & = IF DROP ." &amp;" EXIT THEN
   DUP [CHAR] ' = IF DROP ." &apos;" EXIT THEN
   EMIT ;

: TYPE BOUNDS ?DO I C@ EMIT LOOP ;
: STYPE DUP STR@ TYPE STRFREE ;

: CR ." <br/>" ;
: SPACE ." &nbsp;" ;
: SPACES 0 ?DO SPACE LOOP ;

;MODULE 
