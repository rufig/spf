REQUIRE CLASS: ~micro/lib/oop/oop23.f
REQUIRE { ~1001/lib/args.f

CLASS: STRING
CELL -- LEN
CELL -- ADDR
CELL -- ROOM

: SHOW { inst -- }
  ." inst=" inst . inst WordByAddr TYPE CR
  ." LEN=" inst LEN @ . ." ADDR=" inst ADDR @ . ." ROOM=" inst ROOM @ . CR
  inst ADDR @ IF
    ." TEXT:"
    inst ADDR @ inst LEN @ TYPE CR
  ELSE
    ." TEXT is null" CR
  THEN
  inst ADDR @ inst ROOM @ DUMP
;

: NEW ( -- inst )
  MYSIZE ALLOCATE THROW
  DUP MYSIZE ERASE
;

: FREEMEM { inst -- }
  inst ADDR @ FREE THROW
  inst ADDR 0!
  inst ROOM 0!
;

: DESTROY ( inst -- )
  DUP FREEMEM
  FREE THROW
;

: MALLOC { s inst -- }
  s ALLOCATE THROW
  inst ADDR !
  s inst ROOM !
;

: GETMEM { s inst -- }
  s inst ROOM @ > IF
    inst ADDR @ ?DUP IF FREE THROW
    THEN
    s inst MALLOC
  THEN
;

: <S { addr u inst -- }
  u inst LEN !
  u 1+ inst GETMEM
  addr inst ADDR @ u MOVE
  0 inst ADDR @ u + C!
;

: ASCIIZLEN ( addr -- len )
  DUP
  BEGIN
    DUP C@
  WHILE
    1+
  REPEAT
  SWAP -
;

: <Z { addr inst -- }
  addr DUP ASCIIZLEN inst <S
;

: >S ( inst -- addr u )
  DUP ADDR @ SWAP LEN @
;

: >Z ( inst -- addr )
  ADDR @
;

: UPPERCASE { inst -- }
  inst ADDR @
  inst LEN @ 0 ?DO
    DUP C@
    DUP 96 > IF
      32 -
    THEN
    OVER C!
    1+
  LOOP
  DROP
;

: +CHAR { ch inst \ new -- }
  inst LEN @ 2+ ALLOCATE THROW A>> new
  inst ADDR @ new inst LEN @ MOVE
  inst ADDR @ FREE THROW
  inst LEN @ 1+ DUP inst LEN ! 1+ inst ROOM !
  new inst ADDR !
  ch new inst LEN @ + 1- C!
  0 new inst LEN @ + C!
;
;CLASS
