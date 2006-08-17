WINAPI: CreateProcessA KERNEL32.DLL
\ WINAPI: WaitForSingleObject KERNEL32.DLL
\ WINAPI: GetCursorPos USER32.DLL
\ WINAPI: SetCursorPos USER32.DLL
\ WINAPI: GetTickCount KERNEL32.DLL
\ WINAPI: Beep KERNEL32.DLL


0
4 -- cb
4 -- lpReserved
4 -- lpDesktop
4 -- lpTitle
4 -- dwX
4 -- dwY
4 -- dwXSize
4 -- dwYSize
4 -- dwXCountChars
4 -- dwYCountChars
4 -- dwFillAttribute
4 -- dwFlags
2 -- wShowWindow
2 -- cbReserved2
4 -- lpReserved2
4 -- hStdInput
4 -- hStdOutput
4 -- hStdError
CONSTANT /STARTUPINFO

HEX 00000100 CONSTANT STARTF_USESTDHANDLES DECIMAL
CREATE STARTUPINFO /STARTUPINFO ALLOT STARTUPINFO /STARTUPINFO ERASE

/STARTUPINFO STARTUPINFO cb !
STARTF_USESTDHANDLES STARTUPINFO dwFlags !
H-STDIN STARTUPINFO hStdInput !
H-STDOUT STARTUPINFO hStdOutput !
H-STDERR STARTUPINFO hStdError !

: STR>HEAP ( addr u -- addr1 )
  2DUP DUP ALLOCATE THROW DUP >R
  SWAP
  MOVE
  R@ + 0 SWAP C!
  DROP
  R>
;

: ExecWait ( S" application.exe parameters" -- flag )
  STR>HEAP >R
  HERE \ process information
  STARTUPINFO \ startup info
  0    \ current dir
  0    \ environment
  16   \ creation flags
  FALSE \ inherit handles
  0 0 \ process & thread security
  R@  \ command line
  0   \ application
  CreateProcessA DUP
  IF ." Waiting..." CR -1 HERE @ WaitForSingleObject DROP THEN
  R> FREE THROW
;

