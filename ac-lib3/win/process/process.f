WINAPI: CreateProcessA KERNEL32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL

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
0 VALUE SW_HIDE
1 CONSTANT STARTF_USESHOWWINDOW

: StartApp ( S" application.exe" -- flag )
  OVER + 0 SWAP C! >R
  5 CELLS ALLOCATE ?DUP IF R> DROP NIP EXIT THEN
  DUP \ process information
  DUP 4 CELLS ERASE
  /STARTUPINFO ALLOCATE ?DUP IF R> DROP NIP NIP EXIT THEN 
  DUP ROT ROT \ startup info
  DUP /STARTUPINFO ERASE
  /STARTUPINFO OVER cb !
  STARTF_USESHOWWINDOW OVER dwFlags !
  SW_HIDE OVER wShowWindow !

  0    \ current dir
  0    \ environment
  0    \ creation flags
  FALSE \ inherit handles
  0 0  \ process & thread security
  R>   \ command line
  0    \ application
  CreateProcessA DUP
  ROT >R ROT >R
  DROP
  R@ @ CLOSE-FILE DROP R@ CELL+ @ CLOSE-FILE DROP
  R> FREE DROP R> FREE DROP
;
: StartAppWait ( S" application.exe" -- flag )
  OVER + 0 SWAP C! >R
  5 CELLS ALLOCATE ?DUP IF R> DROP NIP EXIT THEN
  DUP \ process information
  DUP 4 CELLS ERASE
  /STARTUPINFO ALLOCATE ?DUP IF R> DROP NIP NIP EXIT THEN 
  DUP ROT ROT \ startup info
  DUP /STARTUPINFO ERASE
  /STARTUPINFO OVER cb !
  STARTF_USESHOWWINDOW OVER dwFlags !
  SW_HIDE OVER wShowWindow !

  0    \ current dir
  0    \ environment
  0    \ creation flags
  FALSE \ inherit handles
  0 0  \ process & thread security
  R>   \ command line
  0    \ application
  CreateProcessA DUP
  ROT >R ROT >R
  IF -1 R@ @ WaitForSingleObject DROP THEN
  R@ @ CLOSE-FILE DROP R@ CELL+ @ CLOSE-FILE DROP
  R> FREE DROP R> FREE DROP
;
: Visible
  1 TO SW_HIDE
;
