WARNING 0!
S" ~micro/lib/oop/oop23.f" INCLUDED
S" ~micro/lib/oop/oop23.vis.f" INCLUDED
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

: ?FILL ( addr n c -- )
  OVER 0< IF
    2DROP DROP
  ELSE
    FILL
  THEN
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
  inst TEXT inst /TEXT @
  DUP 0= ABORT" INT part not found"
  >NUMBER ABORT" Bad INT part" DROP
  ABORT" INT part too big"
  DUP 0< ABORT" INT part too big"
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

: **
  OVER SWAP
  1 ?DO
    OVER *
  LOOP
  NIP
;

CREATE MAXDIGITS
31 , 20 , 15 , 13 , 12 , 11 , 10 , 10 , 9 , 9 , 8 , 8 , 8 , 7 , 7 ,

: -ZEROS ( addr u -- addr u1 )
  BEGIN
    DUP
  WHILE
    2DUP
    + 1- C@ [CHAR] 0 =
  WHILE
    1-
  REPEAT
  THEN
;

CHILD: PART FRAC \ ============  F R A C  ======================
CELL -- K

: T>V { inst -- }
  inst SETBASE
  inst /TEXT @ inst NBASE @ 2- CELLS MAXDIGITS + @ MIN inst /TEXT !
  0 0. inst TEXT inst /TEXT @ >NUMBER ABORT" Bad FRAC part"
  DROP ABORT" FRAC part too big"
  inst NBASE @ inst /TEXT @ ** UM/MOD
  NIP
  inst VALUE !
  RESTBASE
;             

: <STR { base addr u inst -- }
  u inst /TEXT !
  base inst NBASE !
  u 1 < IF
    0 inst VALUE !
    -1 inst K !
  ELSE
    u 31 > ABORT" FRAC part too big"
    addr inst TEXT u MOVE
    inst T>V
  THEN
;

: V>T { inst -- }
  inst SETBASE
  inst NBASE @                   111 . .S
  DUP 2- CELLS MAXDIGITS + @     222 . .S
  DUP >R **                      333 . .S
  DUP >R
  inst VALUE @                   444 . .S
  UM*                            555 . .S
  SWAP 0< IF 1+ THEN             666 . .S
  R> 1- ( N MAX )
  MIN
  0 <# #S #> R> OVER - DUP inst TEXT SWAP [CHAR] 0 FILL
  inst TEXT + SWAP DUP inst /TEXT ! MOVE
  inst TEXT inst /TEXT @ -ZEROS inst /TEXT ! DROP
  RESTBASE
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

: D-
  DNEGATE D+
;

: Forw0bit ( u -- n )
  DUP IF
    0 SWAP
    BEGIN
      DUP 0< 0=
    WHILE
      1 LSHIFT
      SWAP 1+ SWAP
    REPEAT
    DROP
  ELSE
    DROP
    32
  THEN
;

: DForw0bit ( d -- n )
  Forw0bit
  DUP 32 = IF
    DROP
    Forw0bit 32 +
  ELSE
    NIP
  THEN
;

: 1DLSHIFT ( d -- d )
  SWAP DUP 0< SWAP 1 LSHIFT
  ROT ROT
  SWAP 1 LSHIFT SWAP IF 1+ THEN
;

: DLSHIFT ( d n -- d )
  0 ?DO
    1DLSHIFT
  LOOP
;

CLASS: PNUM \ =============  P N U M  ============================
CLASS INT PI
CLASS FRAC PF
CELL -- P
66 -- TEXT
CELL -- /TEXT
CELL -- SIGN

: PARSE-NUMBER { inst -- }
  [CHAR] . PARSE
  DUP 0= ABORT" INT part not found"
  inst P @ ROT ROT inst PI <STR
  inst P @ 0 PARSE inst PF <STR
;

: NORMSIGN { inst -- }
  inst DUP PI VALUE @ 0= SWAP PF VALUE @ 0= AND IF
    1 inst SIGN !
  THEN
;

: <STR { base addr u inst -- }
  u 0= ABORT" Number not found"
  base inst P !
  u inst /TEXT !
  addr inst TEXT u MOVE
  inst ['] PARSE-NUMBER 
  addr C@
  DUP [CHAR] - = IF
    DROP
    -1 inst SIGN !
    addr 1+ u 1-
  ELSE
    1 inst SIGN !
    [CHAR] + = IF
      addr 1+ u 1-
    ELSE
      addr u
    THEN
  THEN
  PARSES
  inst NORMSIGN
;

: >STR { base inst \ ^T -- addr u }
  inst NORMSIGN
  base inst P !
  inst TEXT A>> ^T
  inst SIGN @ 0< IF [CHAR] - ^T C! ^T 1+ A>> ^T THEN
  base inst PI >STR |CLASS DUP >R ^T SWAP MOVE R> ^T + A>> ^T
  [CHAR] . ^T C! ^T 1+ A>> ^T
  base inst PF >STR |CLASS DUP >R ^T SWAP MOVE R> ^T + A>> ^T
  ^T inst TEXT - inst /TEXT !
  inst TEXT inst /TEXT @
;

: PNUMU+ { inst1 inst2 -- }
  inst1 PF VALUE @ inst1 PI VALUE @
  inst2 PF VALUE @ inst2 PI VALUE @
  D+
  DUP 0< ABORT" Overflow"
  inst2 PI VALUE ! inst2 PF VALUE !
;

: PNUMU- { inst1 inst2 -- }
  inst1 PF VALUE @ inst1 PI VALUE @
  inst2 PF VALUE @ inst2 PI VALUE @
  D-
  DUP 0< ABORT" Overflow"
  inst2 PI VALUE ! inst2 PF VALUE !
;

: PNUM>  { inst1 inst2 -- }
  inst1 PI VALUE @ inst2 PI VALUE @ >
;

: DIFF { inst1 inst2 -- }
  inst1 inst2 PNUM> IF
    inst1 inst2 PNUMU-
  ELSE
    MYSIZE ALLOCATE THROW >R
    inst1 R@ MYSIZE MOVE
    inst2 R@ PNUMU-
    R@ inst2 MYSIZE MOVE
    R> FREE THROW
  THEN
;

: PNUM+ { inst1 inst2 -- }
  inst1 SIGN @ inst2 SIGN @ = IF
    inst1 inst2 PNUMU+
  ELSE
    inst1 inst2 PNUM>
    IF
      inst1 SIGN @
    ELSE
      inst2 SIGN @
    THEN
    inst1 inst2 DIFF
    inst2 SIGN !
  THEN
;

: PNUM- { inst1 inst2 -- }
  inst2 SIGN @ NEGATE inst2 SIGN !
  inst1 inst2 PNUM+
;

: PNUM* { inst1 inst2 \ a b c d -- }
  inst1 DUP PI VALUE @ A>> a PF VALUE @ A>> b
  inst2 DUP PI VALUE @ A>> c PF VALUE @ A>> d
  a c UM* ABORT" Overflow" DUP 0< ABORT" Overflow" 0 SWAP ( ac00:2 )
  b c UM* ( ac00:2 bc:2 )
  a d UM* ( ac00:2 bc:2 ad:2 )
  D+ DUP 0< ABORT" Overflow" ( ac00:2 [bc+ad]:2 )
  D+ DUP 0< ABORT" Overflow" ( [ac00+[bc+ad]]:2 )
  b d UM* NIP 0 ( ac00+[bc+ad]:2 00.bd )
  D+ DUP 0< ABORT" Overflow" ( [ac00+[bc+ad]+0.bd]:2 )
  inst2 PI VALUE ! inst2 PF VALUE !
  inst1 SIGN @ inst2 SIGN @ * inst2 SIGN !
;

: (PNUM/) { inst1 inst2 -- }
  inst1 PF VALUE @ inst1 PI VALUE @
  inst2 PF VALUE @ inst2 PI VALUE @
  2OVER 2OVER
  DForw0bit
  ROT ROT
  DForw0bit
  MIN
  DUP >R
  DLSHIFT
  2SWAP
  R> DLSHIFT
  2SWAP \ A B  -> A/B
  \ ------------------
\  NIP
\  ROT DROP
\  U/
\  inst2 PI VALUE !
\  0 inst2 PF VALUE !
\  inst1 SIGN @ inst2 SIGN @ * inst2 SIGN !
  \ ------------------
  NIP ROT DROP 2DUP
  U/
  inst2 PI VALUE !
  DUP ROT ROT UMOD
  0 SWAP ROT UM/MOD NIP
  inst2 PF VALUE !
  inst1 SIGN @ inst2 SIGN @ * inst2 SIGN !
;
: PNUM/
  ['] (PNUM/) CATCH ABORT" Error at divide"
;

: SHOW { inst -- }
  CR
  ." BASE=" inst P @ . CR
  ." /TEXT=" inst /TEXT @ . CR
  ." TEXT=" inst TEXT inst /TEXT @ TYPE CR
  ." SIGN=" inst SIGN @ . CR
  ." INT part:" CR
  inst PI SHOW
  ." FRAC part:" CR
  inst PF SHOW
  ." K=" inst PF K @ U. CR
;
;CLASS
