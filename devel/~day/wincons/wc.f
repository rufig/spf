
\ Просто подключите этот модуль и все - работайте на здоровье :)


USER-VALUE CURRENT-VOC
USER-VALUE SOURCE-CONST
USER-VALUE SOURCE-LEN

VARIABLE ChainOfConst

: compare ( n-const -- u 0 | -1 | 1 )
     CELLS
     CURRENT-VOC + 2 CELLS + @
     CURRENT-VOC + DUP CELL+ COUNT
     SOURCE-CONST SOURCE-LEN COMPARE
     DUP IF NIP ELSE DROP @ 0 THEN
;

: _SEARCH-CONST ( lo hi -- u -1 | 0 )
  2DUP = IF
    DROP compare 0=
    EXIT
  THEN
  2DUP + 2/
  DUP compare DUP 0= IF DROP NIP NIP NIP TRUE EXIT THEN
  0< IF ROT DROP 1+ SWAP ELSE NIP THEN RECURSE 
;

: SEARCH-CONST ( addr u -- u -1 | 0 )
    TO SOURCE-LEN
    TO SOURCE-CONST
    ChainOfConst
    BEGIN @ ?DUP
    WHILE
      DUP CELL+ @ TO CURRENT-VOC
      CURRENT-VOC CELL+ @ 1- 0 SWAP
      _SEARCH-CONST IF NIP -1 EXIT THEN
    REPEAT
    0
;

: NOTFOUND ( addr u -- )
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF                    
    NIP NIP 2R> SEARCH-CONST
    IF NIP [COMPILE] LITERAL
    ELSE
       THROW
    THEN
  ELSE 2R> 2DROP
  THEN
;

: ADD-CONST-VOC ( addr u -- )
    ." Including " 2DUP TYPE +LibraryDirName [CHAR] . EMIT BL EMIT
    R/O OPEN-FILE THROW >R
    R@ FILE-SIZE THROW DROP \ size
    DUP ALLOCATE THROW DUP ROT \ addr addr size
    R@ READ-FILE THROW DROP
    R> CLOSE-FILE THROW
    HERE
    ChainOfConst @ ,
    SWAP DUP CELL+ @ ." It contains " . ."  constants" CR ,
    ChainOfConst !
;

: REMOVE-ALL-CONSTANTS
    ChainOfConst
    BEGIN @ ?DUP
    WHILE
      DUP CELL+ @ FREE THROW
    REPEAT
;


S" ~day\wincons\windows.const" ADD-CONST-VOC
