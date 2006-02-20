\ 20.Feb.2006 ruvim@forth.org.ru

REQUIRE /STRING   lib\include\string.f
REQUIRE TAIL|HEAD ~pinka\samples\2006\lib\head-tail.f
REQUIRE SPLIT-    ~pinka\samples\2005\lib\split.f
REQUIRE HASH!     ~pinka\lib\hash-table.f

: DECODE-URN-CHAR ( a u -- a2 u2 c ) \ u > 0
  TAIL|HEAD DROP C@
  DUP [CHAR] + =  IF DROP BL EXIT THEN
  DUP [CHAR] % <> IF EXIT THEN
  DROP ( a1 u1 )
  DUP 2 CHARS U< IF DROP 0 -1 EXIT THEN
                                        BASE @ >R HEX
  OVER >R 2 /STRING  \ (???) 2 or 2 CHARS ?
  0. R> 2 CHARS >NUMBER 2DROP DROP ( c )
                                        R> BASE !
;
: DECODE-URN-INPLACE ( a u -- a u1 ) \ rfc2141
  OVER DUP 2>R
  BEGIN DUP WHILE DECODE-URN-CHAR R> DUP CHAR+ >R  C! REPEAT 2DROP
  2R> OVER -
;
: PARSE-URN-PARAMS ( addr u -- hash ) 
  \ [...?]z_on&a=x%3Dy%3F&b=2+3&c=%AF_
  \ will be parsed as: z_on='', a='x=y?', b='2 3', c='ï_'
  small-hash >R
  S" ?" SPLIT- IF 2DROP THEN
  BEGIN
    S" &" SPLIT- -ROT
    S" =" SPLIT 0= IF 0. THEN DECODE-URN-INPLACE
    2SWAP R@ HASH!
    0=
  UNTIL
  R>
;
