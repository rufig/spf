WINAPI: FreeLibrary    KERNEL32.DLL
: FreeLibrary1 FreeLibrary ;
0x00000008 CONSTANT LOAD_WITH_ALTERED_SEARCH_PATH
WINAPI: LoadLibraryExA KERNEL32.DLL

WARNING DUP @ SWAP 0!
: FreeLibrary
  >R
  BEGIN
\    ." FL "
    R@ FreeLibrary 0=
  UNTIL
  RDROP 1
;
WARNING !

: LoadInitLibrary ( addr u -- h 0  | ior )
  2DUP 2>R
  DROP LOAD_WITH_ALTERED_SEARCH_PATH 0 ROT LoadLibraryExA DUP 0=
\  DROP LoadLibraryA DUP 0=
  IF DROP 2R> 2DROP GetLastError EXIT THEN
  WINAPLINK @
  BEGIN
    DUP
  WHILE
    DUP 8 - @ ASCIIZ> 2R@ COMPARE 0=
        IF
           OVER >R DUP 4 - @ R> GetProcAddress DUP 0=
           IF DROP 2DROP 2R> 2DROP GetLastError EXIT THEN
\           DUP ..
           OVER 12 - !
        THEN
    @
  REPEAT
  2R> 2DROP
;
