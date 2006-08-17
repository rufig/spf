WARNING 0!
S" ~micro/lib/oop23.f" INCLUDED
S" ~micro/lib/oop23.vis.f" INCLUDED
REQUIRE { ~1001/lib/args.f
: A>> POSTPONE ¢ ; IMMEDIATE

4 CONSTANT CELL

: PARSES ( i*x xt addr u -- j*x ) \ 94
  SOURCE-ID >R TIB >R #TIB @ >R >IN @ >R
  -1 TO SOURCE-ID
  #TIB ! TO TIB >IN 0!
  EXECUTE
  REFILL DROP
  R> >IN ! R> #TIB ! R> TO TIB R> TO SOURCE-ID
;

: UM/ ( ud u -- ud/u )
  UM/MOD NIP
;

: U/MOD
  2DUP
  UMOD
  ROT ROT
  U/
;

CLASS: PART \ ==============  P A R T  =======================
CELL -- NBASE
CELL -- VALUE
CELL -- /TEXT
33 -- TEXT

: SETBASE { inst -- base }
  BASE @
  inst NBASE @ BASE !
;
: RESTBASE ( base -- )
  BASE !
;

: SHOW { inst -- }
  CR
  ." BASE=" inst NBASE @ . CR
  ." VALUE=" BASE @ HEX inst VALUE @ U. BASE ! CR
  ." /TEXT=" inst /TEXT @ . CR
  ." TEXT=" inst TEXT inst /TEXT @ TYPE CR
;
;CLASS

CHILD: PART INT \ =============  I N T  =======================
: T>V { inst -- }
  inst SETBASE
  0.
  inst TEXT C@ DUP [CHAR] - = IF
    DROP
    ['] NEGATE >R
    inst TEXT 1+ inst /TEXT @ 1-
  ELSE
    ['] NOOP >R
    [CHAR] + = IF
      inst TEXT 1+ inst /TEXT @ 1-
    ELSE
      inst TEXT inst /TEXT @
    THEN
  THEN
  DUP 0= ABORT" Sign it is good, but it is not a INT part"
  >NUMBER ABORT" Bad INT part" DROP
  ABORT" INT part too big"
  R> EXECUTE
  inst VALUE !
  RESTBASE
;

: <STR { base addr u inst -- }
  u 1 < ABORT" INT part not found"
  u 32 > ABORT" INT part too big"
  addr inst TEXT u MOVE
  u inst /TEXT !
  base inst NBASE !
  inst T>V
;

: V>T { inst -- }
  inst SETBASE
  inst VALUE @ 0 <# #S #>
  DUP inst /TEXT !
  inst TEXT SWAP MOVE
  RESTBASE
;

: >STR { base inst -- addr u }
  base inst NBASE !
  inst V>T
  inst TEXT inst /TEXT @
;
;CLASS

: U>
  2DUP U< ROT ROT = OR 0=
;

HEX
CREATE 1/P-TAB 80000000 , 55555555 , 40000000 , 33333333 , 2AAAAAAB ,
24924925 , 20000000 , 1C71C71C , 1999999A , 1745D174 , 15555555 ,
13B13B14 , 12492492 , 11111111 , 10000000 ,
DECIMAL

: 1/P
  2- CELLS 1/P-TAB + @
;

CHILD: PART FRAC \ ============  F R A C  ======================
CELL -- K

: T>V { inst -- }
  inst NBASE @ 1/P 0 ( 1/p 0 )
  inst /TEXT @ 0 ?DO
    OVER
    inst TEXT I + C@ inst NBASE @ DIGIT 0= ABORT" Bad FRAC part"
    ( 1/p^i n 1/p^i d )
    * +
    SWAP DUP 1- inst K ! inst NBASE @ U/ SWAP
  LOOP
  inst VALUE !
  DROP
;

: <STR { base addr u inst -- }
  u inst /TEXT !
    base inst NBASE !
  u 1 < IF
    0 inst VALUE !
    -1 inst K !
  ELSE
    u 32 > ABORT" FRAC part too big"
    addr inst TEXT u MOVE
    inst T>V
  THEN
;

: CalcDigit ( n 1/p^i -- n1 d )
  U/MOD
  DUP 9 > IF
    [ CHAR A 10 - ] LITERAL
  ELSE
    [CHAR] 0
  THEN
  +
;

: PutDigit ( d ) { inst -- }
  inst TEXT
  inst /TEXT @ +
  C!
  inst /TEXT 1+!
;

: V>T { inst -- }
  inst NBASE @ 1/P inst VALUE @ ( 1/p n )
  0 inst /TEXT !
  BEGIN
    OVER
    inst K @ U>
  WHILE
    OVER CalcDigit
    inst PutDigit
    SWAP inst NBASE @ U/ SWAP
  REPEAT
  2DROP
;

: >STR { base inst -- addr u }
  base inst NBASE !
  inst V>T
  inst TEXT inst /TEXT @
;
;CLASS

: SignVal
  [CHAR] - = IF
    -1
  ELSE
    1
  THEN
;

: IsSign
  DUP [CHAR] - = OVER [CHAR] + = OR
;

CLASS: PNUM \ =============  P N U M  ============================
CLASS INT PI
CLASS FRAC PF
CELL -- P
66 -- TEXT
CELL -- /TEXT

: (PARSE-NUMBER) { inst -- }
  [CHAR] . PARSE
  DUP 0= ABORT" INT part not found"
  inst P @ ROT ROT inst PI <STR
  inst P @ 0 PARSE inst PF <STR
;

: <STR { base addr u inst -- }
  base inst P !
  u inst /TEXT !
  addr inst TEXT u MOVE
  inst ['] (PARSE-NUMBER) addr u PARSES
;

: >STR { base inst \ ^T -- addr u }
  base inst P !
  inst TEXT A>> ^T
  base inst PI >STR |CLASS DUP >R ^T SWAP MOVE R> ^T + A>> ^T
  [CHAR] . ^T C! ^T 1+ A>> ^T
  base inst PF >STR |CLASS DUP >R ^T SWAP MOVE R> ^T + A>> ^T
  ^T inst TEXT - inst /TEXT !
  inst TEXT inst /TEXT @
;

: + { inst1 inst2 -- }
  inst1 PF VALUE @ inst1 PI VALUE @
  inst2 PF VALUE @ inst2 PI VALUE @
  D+
  inst2 PI VALUE ! inst2 PF VALUE !
;

: SHOW { inst -- }
  CR
  ." BASE=" inst P @ . CR
  ." /TEXT=" inst /TEXT @ . CR
  ." TEXT=" inst TEXT inst /TEXT @ TYPE CR
  ." INT part:" CR
  inst PI SHOW
  ." FRAC part:" CR
  inst PF SHOW
  ." K=" inst PF K @ U. CR
;
;CLASS
