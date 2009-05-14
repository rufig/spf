\ 05.2009

WINAPI: GetCurrentDirectoryA KERNEL32.DLL
WINAPI: SetCurrentDirectoryA KERNEL32.DLL

\ SetCurrentDirectory ( az -- 0 | 1 )       \ 1=succeeds
\ GetCurrentDirectory ( buf-a buf-u -- n )  \ 0=unsucceeds

: CurrentDir ( -- a u ) \ in PAD
  PAD DUP 1024 GetCurrentDirectoryA
;

: SetCurrentDir ( a u -- )
  DROP SetCurrentDirectoryA ERR THROW
;
