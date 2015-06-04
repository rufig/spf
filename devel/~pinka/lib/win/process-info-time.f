\ 2015-06-04

REQUIRE 2NIP  ~pinka/lib/ext/basics.f

WINAPI: GetProcessTimes         kernel32.dll
WINAPI: GetCurrentProcess       kernel32.dll

\ BOOL WINAPI GetProcessTimes
(
  _In_  HANDLE     hProcess,
  _Out_ LPFILETIME lpCreationTime,
  _Out_ LPFILETIME lpExitTime,
  _Out_ LPFILETIME lpKernelTime,
  _Out_ LPFILETIME lpUserTime
)

: (PROCESS-FILETIME) ( h -- i*x ior )
  >R 0. 0. 0. 0. SP@ DUP 8 + DUP 8 + DUP 8 +
  R> GetProcessTimes ERR
;
: PROCESS-FILETIME-C ( h -- ftime-lo ftime-hi ior )
  (PROCESS-FILETIME) >R 2DROP 2DROP 2DROP SWAP R>
;
: PROCESS-FILETIME-USER ( h -- ftime-lo ftime-hi ior )
  (PROCESS-FILETIME) >R 2NIP 2NIP 2NIP SWAP R>
;
: PROCESS-FILETIME-KERNEL ( h -- ftime-lo ftime-hi ior )
  (PROCESS-FILETIME) >R 2DROP 2NIP 2NIP SWAP R>
;


\EOF

\ m.b.:

USER-VALUE _H-PROCESS

: H-PROCESS ( -- h )
  _H-PROCESS DUP IF EXIT THEN
  DROP GetCurrentProcess DUP TO _H-PROCESS
;

: RUNNING-FILETIME-USER ( -- ftime-lo ftime-hi )
  H-PROCESS PROCESS-FILETIME-USER THROW
;
: RUNNING-FILETIME-KERNEL ( -- ftime-lo ftime-hi )
  H-PROCESS PROCESS-FILETIME-KERNEL THROW
;

REQUIRE M*/ lib/include/double.f

: EXECUTE-ELAPSED-MS ( i*x xt -- jx ms )
  RUNNING-FILETIME-USER 2>R
  EXECUTE
  RUNNING-FILETIME-USER 2R> D- 
  DUP IF 1 10000 M*/ DROP ELSE DROP 10000 U/ THEN
;
