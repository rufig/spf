WINAPI: GetUserNameA         ADVAPI32.DLL

: whoami ( -- addr u )
  256 >R RP@
  256 ALLOCATE THROW >R
  R@ GetUserNameA 0= IF R> RDROP 0 THEN
  R> R> 1-
;
