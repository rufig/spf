\ original (c) A.Cherezov  ( SPF314\EXT\MUTEX.F)
\ Ruv 22.10.99г. - добавил WaitAny, WaitAll

WINAPI: CreateMutexA        KERNEL32.DLL
WINAPI: ReleaseMutex        KERNEL32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL

( CreateMutex
  LPSECURITY_ATTRIBUTES lpMutexAttributes,
                        // pointer to security attributes
  BOOL bInitialOwner,   // flag for initial ownership
  LPCTSTR lpName    // pointer to mutex-object name
)
( BOOL ReleaseMutex
  HANDLE hMutex     // handle of mutex object
)
( DWORD WaitForSingleObject
  HANDLE hHandle,   // handle of object to wait for
  DWORD dwMilliseconds  // time-out interval in milliseconds
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
  NIP 1 AND 0 CreateMutexA DUP
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


\ Ruv 22.10.99г. 21:24:22

WINAPI:  WaitForMultipleObjects    KERNEL32.DLL

\ WaitForMultipleObjects ( time flag a-array number --  WAIT_FAILD | WAIT_OBJECT_0+n | WAIT_ABANDONED+n | WAIT_TIMEOUT )
(
  DWORD WaitForMultipleObjects
    DWORD  cObjects,            // number of handles in handle array
    CONST HANDLE *  lphObjects, // address of object-handle array
    BOOL  fWaitAll,             // wait flag
    DWORD  dwTimeout            // time-out interval in milliseconds
)

\
\ : WaitAny  ( time  a-array n -- flag ior )
\   0 ( flag-WaitAll  - any object)   ROT ROT
\   WaitForMultipleObjects
\   DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
\       WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
\   TRUE 0              THEN THEN
\ ;
\ : WaitAll  ( time  a-array n -- flag ior )
\   -1 ( flag-WaitAll  - all objects) ROT ROT
\   WaitForMultipleObjects
\   DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
\       WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
\   TRUE 0              THEN THEN
\ ;
\ ===


\ неудобно было возится с дополнительными массивами.
\ Такая, как ниже, стековая нотация кажется удобней.

: WaitAny  (  h1 h2 ... hn  n time -- flag ior )
  SWAP >R 0    ( S: h1 h2 ... hn time 0 ) \ flag-WaitAll=0  - any object
  SP@ 8 +  R@  ( S: h1 h2 ... hn  time 0  a-array n )
  WaitForMultipleObjects  ( S: ... wait_flag )
  R> 2>R  SP@ R> CELLS + SP!  R>  ( wait_flag ) \ убираем список хэндлов
  DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
      WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
  TRUE 0              THEN THEN
;

: WaitAll  ( h1 h2 ... hn  n time  -- flag ior )
  SWAP >R -1   ( S: h1 h2 ... hn time -1 ) \ flag-WaitAll = -1  -all objects
  SP@ 8 +  R@  ( S: h1 h2 ... hn  time -1 a-array n )
  WaitForMultipleObjects  ( S: ... wait_flag )
  R> 2>R  SP@ R> CELLS + SP!  R>  ( wait_flag ) \ убираем список хэндлов
  DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
      WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
  TRUE 0              THEN THEN
;


\ и Wait  можно  в том же стиле сделать.

: Wait ( handle time -- flag ior )
\ возвращает истину, если объект освобожден другим потоком
\ (либо он освободился сам собой при завершении др.потока)
\ и после этого занят текущим
  SWAP WaitForSingleObject DUP WAIT_FAILED =
  IF GetLastError ELSE DUP WAIT_OBJECT_0 = SWAP WAIT_ABANDONED = OR 0 THEN
;