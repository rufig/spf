\ $Id$
\ Константы времени компиляции

\ Ветка от ~day/wincons/wc.f v1.5

\ REQUIRE +LibraryDirName  src/win/spf_win_module.f
REQUIRE TryOpenFile      lib/ext/util.f

MODULE: WINCONST

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

EXPORT

: SEARCH-CONST ( addr u -- u -1 | 0 )
  TO SOURCE-LEN
  TO SOURCE-CONST
  ChainOfConst
  BEGIN @ ?DUP
  WHILE
    DUP CELL+ @ TO CURRENT-VOC
    0 CURRENT-VOC 2 CELLS + @ 1-
    DUP 0 < ABORT" The file is corrupted or contains zero constants"
    _SEARCH-CONST IF NIP -1 EXIT THEN
  REPEAT
  0
;

WARNING @ FALSE WARNING !
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
WARNING !

: ADD-CONST-VOC ( addr u -- )
  R/O TryOpenFile 0= IF >R
    R@ FILE-SIZE THROW DROP \ size
    DUP ALLOCATE THROW DUP ROT \ addr addr size
    R@ READ-FILE THROW 0 = ABORT" Read zero bytes from const file"
    R> CLOSE-FILE THROW
    HERE
    ChainOfConst @ ,  SWAP ,  ChainOfConst !
  ELSE
    -1 ABORT" Missing file with constants"
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

\ сохранённый образ не будет пытаться использовать константы
\ которые были подгружены в родительском сеансе
\ ~ruvim 21.09.2007
..: AT-PROCESS-STARTING ChainOfConst 0! ;..

;MODULE
