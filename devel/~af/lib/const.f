\ $Id$
\ Work in spf3, spf4
\ Windows константы
\ af - исправил REMOVE-ALL-CONSTANTS, NOTFOUND вынес из модуля,
\ заменил MODULE: на VOCABULARY (для spf3-совместимости)


REQUIRE +LibraryDirName  src\win\spf_win_module.f
REQUIRE TryOpenFile      lib\ext\util.f

VOCABULARY WINCONST
GET-CURRENT ALSO WINCONST DEFINITIONS

USER-VALUE CURRENT-VOC
USER-VALUE SOURCE-CONST
USER-VALUE SOURCE-LEN
VARIABLE ChainOfConst

: compare_const ( n-const -- u 0 | -1 | 1 )
  CELLS
  CURRENT-VOC + 2 CELLS + @
  CURRENT-VOC + DUP CELL+ COUNT
  SOURCE-CONST SOURCE-LEN COMPARE
  DUP IF NIP ELSE DROP @ 0 THEN
;

: _SEARCH-CONST ( lo hi -- u -1 | 0 )
  2DUP = IF
    DROP compare_const 0=
    EXIT
  THEN
  2DUP + 2/
  DUP compare_const DUP 0= IF DROP NIP NIP NIP TRUE EXIT THEN
  0< IF ROT DROP 1+ SWAP ELSE NIP THEN RECURSE 
;

: SEARCH-CONST ( addr u -- u -1 | 0 )
  TO SOURCE-LEN
  TO SOURCE-CONST
  ChainOfConst
  BEGIN @ ?DUP
  WHILE
    DUP CELL+ @ TO CURRENT-VOC
    0 CURRENT-VOC CELL+ @ 1-
    _SEARCH-CONST IF NIP -1 EXIT THEN
  REPEAT
  0
;

: ADD-CONST-VOC ( addr u -- )
  R/O TryOpenFile 0= IF >R
    R@ FILE-SIZE THROW DROP \ size
    DUP ALLOCATE THROW DUP ROT \ addr addr size
    R@ READ-FILE THROW DROP
    R> CLOSE-FILE THROW
    HERE
    ChainOfConst @ ,  SWAP ,  ChainOfConst !
  THEN
;

: REMOVE-ALL-CONSTANTS
  ChainOfConst
  BEGIN @ ?DUP
  WHILE
    DUP CELL+ @ FREE THROW
  REPEAT
  ChainOfConst 0!
;

SET-CURRENT

FALSE WARNING !
: NOTFOUND ( addr u -- )
  2DUP 2>R ['] NOTFOUND CATCH ?DUP
  IF                    
    NIP NIP 2R> SEARCH-CONST
    IF NIP [COMPILE] LITERAL
    ELSE
      THROW
    THEN
  ELSE RDROP RDROP
  THEN
;
TRUE WARNING !

S" lib\win\winconst\windows.const" WINCONST ADD-CONST-VOC

PREVIOUS
