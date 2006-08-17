REQUIRE >MEM ~micro/lib/stack/mem.f
REQUIRE NEXT-WORD ~micro/lib/parser/word.f

: P: ( +len params -- )
\ Создаёт массив xt.
\ Дополнительно резервируется +len CELLS.
\ params - число входных параметров каждому слову.
\ BYTE -- PARAMS
\ BYTE -- MAXLEN
\ BYTE -- LEN
  CREATE
  C,
  HERE 0 W,
  BEGIN
    NEXT-WORD ?DUP
  WHILE
    2DUP S" ;" COMPARE
  WHILE
    SFIND IF
      ,
      DUP DUP C@ 1+ SWAP C!
    ELSE
      2DROP
      1 ABORT" Not found"
    THEN
  REPEAT
  2DROP
  THEN
  DUP C@ OVER 1+ C!
  SWAP
  DUP
  0 ?DO
    0 ,
  LOOP
  OVER C@ + SWAP C!
  DOES>
  DUP >R
  C@
  >MEM
  R> \ ^PPP BODY
  DUP 2+ C@ 0 DO      \ ^PPP BODY
    >R                \ ^PPP R: BODY
    DUP >R            \ ^PPP R: BODY ^PPP
    MEM@              \ PPP R: BODY ^PPP
    R>                \ PPP ^PPP R: BODY
    R@ 3 +            \ PPP ^PPP BODY.LIST R: BODY
    R>                \ PPP ^PPP BODY.LIST BODY
    I CELLS           \ PPP ^PPP BODY.LIST BODY I_CELLS
    SWAP              \ PPP ^PPP BODY.LIST I_CELLS BODY
    >R                \ PPP ^PPP BODY.LIST I_CELLS R: BODY
    +                 \ PPP ^PPP ^xt R: BODY
    @                 \ PPP ^PPP xt R: BODY
    SWAP >R           \ PPP xt R: BODY ^PPP
    EXECUTE           \ RRR <>0 | 0 R: BODY ^PPP
    IF
      R> MEMDROP
      RDROP
      UNLOOP -1 EXIT
    THEN
    R> R>
  LOOP
  2DROP
  0
;

: PADD ( xt v -- )
  >BODY
  1+ DUP 1+ C@ 1+ \ ^MAXLEN LEN+1
  OVER C@ \ ^MAXLEN LEN+1 MAXLEN
  > ABORT" Overflow"
  1+ DUP 1+ OVER C@ CELLS + ROT SWAP !
  DUP C@ 1+ SWAP C!
;

: PSHOW
  >BODY DUP 3 + SWAP 2+ C@ 0 DO
    DUP @ WordByAddr TYPE SPACE
    4 +
  LOOP
  DROP
;

: PREMOVE
  >BODY 2+ DUP C@
  1 = ABORT" Last - can't remove"
  DUP C@ 1- SWAP C!
;

: PREPLACE ( no-xt what-xt v -- )
  >BODY 3 + ROT CELLS + !
;
