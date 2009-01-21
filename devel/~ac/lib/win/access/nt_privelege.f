( Управление привилегиями в WinNT/2000 А.Ч. 24.Mar.2000 )

WINAPI: GetCurrentProcess     KERNEL32.DLL
WINAPI: LookupPrivilegeValueA ADVAPI32.DLL
WINAPI: AdjustTokenPrivileges ADVAPI32.DLL
WINAPI: OpenProcessToken      ADVAPI32.DLL

255 CONSTANT TOKEN_ALL_ACCESS
  2 CONSTANT SE_PRIVILEGE_ENABLED

USER TOKEN
USER LUID 4 USER-ALLOT
USER-CREATE TP 4 CELLS USER-ALLOT \ 1 , 0 , 0 , ( <-luid ) 0 , ( <-attr)

: GetProcessToken ( -- token ior )
  TOKEN TOKEN_ALL_ACCESS GetCurrentProcess OpenProcessToken
  IF TOKEN @ FALSE ELSE 0 GetLastError THEN
;

: SetPrivilege ( flag addr u token -- ior )
\    HANDLE hToken,          // access token handle
\    LPCTSTR lpszPrivilege,  // name of privilege to enable/disable
\    BOOL bEnablePrivilege   // to enable or disable privilege

  >R DROP
  LUID SWAP 0 LookupPrivilegeValueA 0= IF DROP GetLastError EXIT THEN
  LUID 2@ TP CELL+ 2!
  1 TP ! 
  ( flag ) IF SE_PRIVILEGE_ENABLED ELSE 0 THEN TP 3 CELLS + !

  0 0 0 TP 0 R> AdjustTokenPrivileges ERR
;

\ TRUE S" SeShutdownPrivilege" GetProcessToken THROW SetPrivilege THROW
