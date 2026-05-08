( Case insensitivity for SP-FORTH )
( CASE-INS - case sensitivity switcher )
( just include this lib :)

REQUIRE REPLACE-WORD lib/ext/patch.f
REQUIRE ON           lib/ext/onoff.f

REQUIRE string-ascii-ci  lib/ext/string/comparison-ascii-ci.f
\ It is case-insensitive only within ASCII charset (to avoid breaking UTF-8)

USER CASE-INS \ switcher  (do not use it directly, use the the getter and setters instead)

: sensitivity-mode ( -- flag ) CASE-INS @ 0= ; \ flag is true iff case-sensitive mode is active
: enter-sensitivity-mode ( -- ) CASE-INS OFF ;
: leave-sensitivity-mode ( -- ) CASE-INS ON ;


\ After loading this module, sensitivity-mode is turned off by default.

leave-sensitivity-mode \ Initialize: switch to the case-insensitive mode

..: AT-THREAD-STARTING leave-sensitivity-mode ;..


: FIND-NAME-IN.MAYBE-INSENSITIVE ( sd.name wid -- nt|0 )
  sensitivity-mode IF
    [ ' FIND-NAME-IN BEHAVIOR COMPILE, ] EXIT
  THEN
  LATEST-NAME-IN ( sd.name nt|0 )
  BEGIN
    DUP
  WHILE
    >R 2DUP
    R@ NAME>STRING string-ascii-ci::equals
    IF 2DROP R> EXIT THEN
    R> NAME>NEXT-NAME
  REPEAT NIP NIP
;

' FIND-NAME-IN.MAYBE-INSENSITIVE TO FIND-NAME-IN

: UDIGIT ( char.digit u.base -- u.digit true | false )
  SWAP
  DUP [CHAR] 0 [CHAR] 9 1+ WITHIN
  IF \ within 0..9
     [CHAR] 0 -
  ELSE
     DUP [CHAR] A 1- >
     IF
       DUP [CHAR] a 1- >
       IF
         CASE-INS @ IF [CHAR] a ELSE 2DROP 0 EXIT THEN
       ELSE [CHAR] A THEN
       - 10 +
     ELSE 2DROP 0 EXIT THEN
  THEN
  TUCK > DUP 0= IF NIP THEN
;

' UDIGIT ' DIGIT REPLACE-WORD



\ Helper that can be used to load a file in a specific mode

: execute-sensitively ( any1 xt[ any1 -- any2 ] -- any2 )
  \ Execute xt in case-sensitive mode.
  sensitivity-mode >r enter-sensitivity-mode
  ( xt ) catch
  r> invert if leave-sensitivity-mode then
  throw
;
: execute-insensitively ( any1 xt[ any1 -- any2 ] -- any2 )
  \ Execute xt in case-insensitive mode.
  sensitivity-mode >r leave-sensitivity-mode
  ( xt ) catch
  r> if enter-sensitivity-mode then
  throw
;
