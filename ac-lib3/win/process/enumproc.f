REQUIRE {            ~ac/lib/locals.f

WINAPI: CreateToolhelp32Snapshot KERNEL32.DLL
WINAPI: Process32First           KERNEL32.DLL
WINAPI: Process32Next            KERNEL32.DLL

 1 CONSTANT TH32CS_SNAPHEAPLIST
 2 CONSTANT TH32CS_SNAPPROCESS
 4 CONSTANT TH32CS_SNAPTHREAD
 8 CONSTANT TH32CS_SNAPMODULE
15 CONSTANT TH32CS_SNAPALL

0
CELL -- P32.dwSize
CELL -- P32.cntUsage
CELL -- P32.th32ProcessID
CELL -- P32.th32DefaultHeapID
CELL -- P32.th32ModuleID
CELL -- P32.cntThreads
CELL -- P32.th32ParentProcessID
CELL -- P32.pcPriClassBase
CELL -- P32.dwFlags
260  -- P32.szExeFile \ [MAX_PATH]; 
CONSTANT /PROCESSENTRY32

: ForEachProcess { xt \ h mem -- }
  0 TH32CS_SNAPPROCESS CreateToolhelp32Snapshot
  DUP INVALID_HANDLE_VALUE = IF DROP GetLastError THROW THEN
  -> h
  /PROCESSENTRY32 ALLOCATE THROW -> mem
  /PROCESSENTRY32 mem P32.dwSize !
  mem h Process32First 1 =
  IF
    BEGIN
      mem xt EXECUTE
      mem h Process32Next 1 <>
    UNTIL
  THEN
  mem FREE THROW
  h CLOSE-FILE THROW
;
: Process.
  DUP P32.th32ProcessID @ .
  P32.szExeFile ASCIIZ> TYPE CR
;
\ ' Process. ForEachProcess
