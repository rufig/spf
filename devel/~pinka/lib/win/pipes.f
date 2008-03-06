\ 04.2007

REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE CreatePipe ~ac/lib/win/process/pipes.f 

[UNDEFINED] PeekNamedPipe [IF]
WINAPI: PeekNamedPipe kernel32.dll
[THEN]

: CREATE-PIPE-ANON ( -- h-read h-write ior )
  0 SP@ >R 0 SP@ R> ( 0 0 'w 'r )
  0 0 2SWAP  CreatePipe ERR
;
: PIPE-TO-READ ( pipe-r -- u )
  >R 0 SP@ >R
  0  \ lpBytesLeftThisMessage
  R> \ lpTotalBytesAvail
  0  \ lpBytesRead
  0  \ nBufferSize
  0  \ lpBuffer
  R> \ hNamedPipe
  PeekNamedPipe ERR THROW
;

: READ-FILE-EXACT ( addr u h -- ior )
  >R BEGIN DUP WHILE
    2DUP R@ READ-FILE ?DUP IF NIP NIP NIP RDROP EXIT THEN ( a1 u1 u2 )
    DUP 0= IF DROP 2DROP RDROP -1002 EXIT THEN \ 109 is not throwable in spf4
    TUCK - -ROT + SWAP
  REPEAT ( a1 0 )
  NIP RDROP
;
