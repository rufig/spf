\ $Id$

REQUIRE STR@ ~ac/lib/str5.f
REQUIRE BOUNDS ~ygrek/lib/string.f

MODULE: XMLSAFE

\ XML and HTML compatible 
\ http://www.w3.org/TR/xhtml-media-types/
: EMIT ( c -- )
   DUP 0x0C = IF DROP BL EMIT EXIT THEN \ A.15
   DUP 0x0A = IF DROP ." &#x0A;" EXIT THEN
   DUP 0x0D = IF DROP ." &#x0D;" EXIT THEN
   \ DUP BL < IF DROP BL EMIT EXIT THEN
   DUP [CHAR] < = IF DROP ." &lt;" EXIT THEN
   DUP [CHAR] > = IF DROP ." &gt;" EXIT THEN
   DUP [CHAR] " = IF DROP ." &quot;" EXIT THEN
   DUP [CHAR] & = IF DROP ." &amp;" EXIT THEN
   DUP [CHAR] ' = IF DROP ." &#39;" EXIT THEN \ A.16
   EMIT ;

: TYPE ( a u -- ) BOUNDS ?DO I C@ EMIT LOOP ;
: STYPE ( s -- ) DUP STR@ TYPE STRFREE ;

\ discuss
\ whether SPACE and BL EMIT should be equivalent?
: SPACE ( -- ) ." &nbsp;" ;
: SPACES ( n -- ) 0 ?DO SPACE LOOP ;

\ discuss
\ What is better: ." <br />" or ." &#x0A;" ?
: CR ( -- ) ." <br />" ; \ A.2

;MODULE

