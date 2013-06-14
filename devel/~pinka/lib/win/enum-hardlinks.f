\ Enum all hardlinks. Require Windows Vista at least.
\ 2013-06 ruv

REQUIRE RBUF        ~pinka/spf/rbuf.f
REQUIRE ANSI>UTF16  ~pinka/lib/win/utf16.f

WINAPI: FindFirstFileNameW      kernel32.dll
WINAPI: FindNextFileNameW       kernel32.dll

[UNDEFINED] FindClose [IF]
WINAPI: FindClose               kernel32.dll
[THEN]

0x26 CONSTANT ERROR_HANDLE_EOF  \ 38
0xEA CONSTANT ERROR_MORE_DATA   \ 234

[UNDEFINED] MAX_PATH  [IF]
260 CONSTANT MAX_PATH [THEN]

: (TREAT-HARDLINK) ( h xt a-buf -- h )
  DUP CELL- @ ( count-wchars ) DUP 2* SWAP RBUF UTF16>ANSI
    DUP IF 1- THEN \ remove null character
  2SWAP SWAP >R EXECUTE R>
;
: (BUF-PAIR) ( a-buf -- a-buf a-n-buf ) DUP CELL- MAX_PATH OVER !  ;


: FOR-FILENAME-HARDLINKS ( c-addr u xt -- ) \ xt ( i*x addr u -- j*x )
  -ROT
  1+ DUP 2* RBUF ANSI>UTF16 DROP \ convert including zero at the end
  MAX_PATH 2* CELL+ RBUF DROP CELL+ (BUF-PAIR) OVER >R ( xt a-txt  a-buf a-n-buf )
  2SWAP SWAP R> 2>R 0 SWAP ( a-buf a-n-buf flags a-filename ) ( R: xt a-buf )
  FindFirstFileNameW
  DUP -1 = IF GetLastError THROW THEN ( h )
  2R@ (TREAT-HARDLINK)
  BEGIN ( h )
    DUP R@ ( h h a-buf ) 
    (BUF-PAIR) ROT ( h a-buf a-n-buf h )
    FindNextFileNameW
  WHILE ( h )
    2R@ (TREAT-HARDLINK)
  REPEAT ( h )
  GetLastError DUP ERROR_HANDLE_EOF = IF DROP 0 THEN SWAP
  FindClose ERR SWAP THROW THROW
  RDROP RDROP
;

\ see also: ~ac/lib/win/file/FINDFILE.F
