WINAPI: CreateEventA      KERNEL32.DLL
WINAPI: SetEvent          KERNEL32.DLL
WINAPI: WaitForSingleObject  KERNEL32.DLL

: CREATE-AUTOEVENT ( -- handle ior )
\ create an event object
  0 0 0 0 CreateEventA DUP
  0= IF GetLastError ELSE 0 THEN
;
: SET-EVENT ( handle -- ior )
\ setting event object
  SetEvent 0= IF GetLastError ELSE 0 THEN
;

: WAIT ( handle ms -- flag ior )
\ returns TRUE flag, if the object have been setting
\ from another thread, or if it sets himself after the
\ external thread stopped.
\
  SWAP WaitForSingleObject DUP WAIT_FAILED =
          IF  GetLastError
          ELSE DUP WAIT_OBJECT_0 = SWAP WAIT_ABANDONED = OR 0 THEN
;
