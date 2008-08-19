\ Wild Cards matching
REQUIRE UPPER ~nn/lib/upper.f

: UCHAR- ( c1 c2 --) UPPER-CHAR SWAP UPPER-CHAR SWAP - ;
: CHAR= UCHAR- 0= ;

: GET-CHAR ( a1 u1 -- a2 u2 c)
    DUP IF 1- SWAP COUNT ROT SWAP
        ELSE 0 THEN
;
: GET-CHAR2 ( a1 u1 a2 u2 -- a3 u3 a2 u2 c)
    2SWAP GET-CHAR >R 2SWAP R> ;


: ?EXIT0 ( a1 u1 a2 u2 ? --)  IF 2DROP 2DROP RDROP FALSE THEN ;
: ?EXIT1 ( a1 u1 a2 u2 ? --)  IF 2DROP 2DROP RDROP TRUE  THEN ;

: WC-COMPARE ( a1 u1 a2-pat u2-pat -- ?)
    BEGIN  GET-CHAR ?DUP WHILE
       DUP [CHAR] ? = IF DROP GET-CHAR2 DROP ELSE
       DUP [CHAR] * = IF DROP
                         DUP 0= ?EXIT1
                         BEGIN
                            2OVER 2OVER RECURSE 0=
                         WHILE
                            GET-CHAR2 0= ?EXIT0
                         REPEAT
                         TRUE ?EXIT1
       ELSE
          >R GET-CHAR2 R> CHAR= 0= ?EXIT0
       THEN THEN
    REPEAT
    2DROP NIP 0=
;

: -TEXT ( a1 u1 a2 --n)
    SWAP OVER + SWAP
    ?DO COUNT I C@ UCHAR-
        ?DUP IF NIP UNLOOP EXIT THEN
    LOOP
    DROP 0
;

: ICOMPARE ( a1 u1 a2 u2 --n)
    ROT 2DUP SWAP - >R MIN SWAP -TEXT
    R> OVER 0= IF SWAP THEN DROP
;

\ ' ICOMPARE ' COMPARE JMP

: ISEARCH ( a1 u1 a2 u2 - a3 u3 ?)
    ?DUP 0=          IF DROP  TRUE  EXIT THEN
    2OVER 2SWAP
    BEGIN 2OVER NIP OVER < 0= WHILE
      2OVER 2OVER ROT DROP SWAP -TEXT 0=
      IF 2DROP 2SWAP 2DROP TRUE EXIT THEN
      GET-CHAR2 DROP
    REPEAT
    2DROP 2DROP FALSE
;

: WC-MATCH ( a1 u1 a2 u2 --?)
    253 MIN DUP CELL+ ALLOCATE THROW >R
    [CHAR] * R@ C!
    SWAP OVER R@ 1+ SWAP CMOVE
    [CHAR] * OVER R@ + 1+ C!
    R@ SWAP 2+    \ 2DUP TYPE
    WC-COMPARE              \ SPACE DUP . CR
    R> FREE DROP
;


