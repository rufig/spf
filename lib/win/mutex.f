WINAPI: CreateMutexA        KERNEL32.DLL
WINAPI: ReleaseMutex        KERNEL32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL

( CreateMutex
  LPSECURITY_ATTRIBUTES lpMutexAttributes,
                        // pointer to security attributes 
  BOOL bInitialOwner,	// flag for initial ownership 
  LPCTSTR lpName 	// pointer to mutex-object name  
)
( BOOL ReleaseMutex
  HANDLE hMutex 	// handle of mutex object  
)
( DWORD WaitForSingleObject
  HANDLE hHandle,	// handle of object to wait for 
  DWORD dwMilliseconds 	// time-out interval in milliseconds  
)
HEX
  0 CONSTANT WAIT_OBJECT_0
 -1 CONSTANT WAIT_FAILED
102 CONSTANT WAIT_TIMEOUT
 80 CONSTANT WAIT_ABANDONED
DECIMAL

: CREATE-MUTEX ( addr u flag -- handle ior )
\ создает объект взаимного исключения
\ addr u - имя
\ flag=TRUE, если создаваемый объект нужно сразу занять
  NIP 0 CreateMutexA DUP
  0= IF GetLastError ELSE 0 THEN
;
: RELEASE-MUTEX ( handle -- ior )
\ освобождает объект
  ReleaseMutex 0= IF GetLastError ELSE 0 THEN
;
: WAIT ( time handle -- flag ior )
\ возвращает истину, если объект освобожден другим потоком
\ (либо он освободился сам собой при завершении др.потока)
\ и после этого занят текущим
  WaitForSingleObject DUP WAIT_FAILED =
  IF GetLastError ELSE DUP WAIT_OBJECT_0 = SWAP WAIT_ABANDONED = OR 0 THEN
;

(
: TEST
  S" MUTEX-TEST" FALSE CREATE-MUTEX THROW
  BEGIN
   -1 OVER WAIT THROW
   IF DUP . DUP RELEASE-MUTEX THROW THEN
  AGAIN
  CLOSE-FILE THROW
;
)