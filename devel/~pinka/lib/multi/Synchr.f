\ 22.10.99г. Ruv - WaitAny, WaitAll, Wait
\ 01.04.2001 выделил  в отдельную либу  в связи с наличием semaphore.f.
\  * Wait и Release* не возвращают ior. При ошибке вызывают THROW внутри.
\    (просмотр исходников показал, что эти ошибки не обрабатывается 
\    иначе, чем DROP или THROW почти всегда).

REQUIRE [UNDEFINED] lib\include\tools.f

[UNDEFINED] WaitForSingleObject                  [IF]
  WINAPI:  WaitForSingleObject     KERNEL32.DLL  [THEN]
[UNDEFINED] WaitForMultipleObjects               [IF]
  WINAPI:  WaitForMultipleObjects  KERNEL32.DLL  [THEN]

( DWORD WaitForSingleObject
  HANDLE hHandle,   // handle of object to wait for
  DWORD dwMilliseconds  // time-out interval in milliseconds
)

\ WaitForMultipleObjects ( time flag a-array number --  WAIT_FAILD | WAIT_OBJECT_0+n | WAIT_ABANDONED+n | WAIT_TIMEOUT )
(
  DWORD WaitForMultipleObjects
    DWORD  cObjects,            // number of handles in handle array
    CONST HANDLE *  lphObjects, // address of object-handle array
    BOOL  fWaitAll,             // wait flag
    DWORD  dwTimeout            // time-out interval in milliseconds
)

[UNDEFINED] WAIT_TIMEOUT [IF]
HEX
  0 CONSTANT WAIT_OBJECT_0
 -1 CONSTANT WAIT_FAILED
102 CONSTANT WAIT_TIMEOUT
 80 CONSTANT WAIT_ABANDONED
DECIMAL                  [THEN]

\
\ : WaitArAny  ( time  a-array n -- flag ior )
\   0 ( flag-WaitAll  - any object)   ROT ROT
\   WaitForMultipleObjects
\   DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
\       WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
\   TRUE 0              THEN THEN
\ ;
\ : WaitArAll  ( time  a-array n -- flag ior )
\   -1 ( flag-WaitAll  - all objects) ROT ROT
\   WaitForMultipleObjects
\   DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) ELSE
\       WAIT_TIMEOUT =  IF   FALSE  0      ( false 0      ) ELSE
\   TRUE 0              THEN THEN
\ ;
\ ===

\ неудобно было возится с дополнительными массивами.
\ Такая, как ниже, стековая нотация кажется удобней.

: WaitAny  (  h1 h2 ... hn  n time -- false|number_from_top )
  SWAP >R 0    ( S: h1 h2 ... hn time 0 ) \ flag-WaitAll=0  - any object
  SP@ 8 +  R@  ( S: h1 h2 ... hn  time 0  a-array n )
  WaitForMultipleObjects  ( S: ... wait_flag )
  R> 2>R  SP@ R> CELLS + SP!  R>  ( wait_flag ) \ убираем список хэндлов
  DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) THROW ELSE
  DUP WAIT_TIMEOUT =  IF   DROP FALSE    ( false        ) ELSE
  WAIT_OBJECT_0 - 1+  THEN THEN
;

: WaitAll  ( h1 h2 ... hn  n time  -- flag )
  SWAP >R -1   ( S: h1 h2 ... hn time -1 ) \ flag-WaitAll = -1  -all objects
  SP@ 8 +  R@  ( S: h1 h2 ... hn  time -1 a-array n )
  WaitForMultipleObjects  ( S: ... wait_flag )
  R> 2>R  SP@ R> CELLS + SP!  R>  ( wait_flag ) \ убираем список хэндлов
  DUP WAIT_FAILED  =  IF   GetLastError  ( true  err_no ) THROW ELSE
      WAIT_TIMEOUT =  IF   FALSE         ( false        ) ELSE
  TRUE                THEN THEN
;

\ и Wait  можно  в том же стиле сделать.

: Wait ( handle time -- flag )
\ возвращает истину, если объект освобожден другим потоком
\ (либо он освободился сам собой при завершении др.потока)
\ и после этого занят текущим
  SWAP WaitForSingleObject DUP WAIT_FAILED =
  IF GetLastError THROW ELSE DUP WAIT_OBJECT_0 = SWAP WAIT_ABANDONED = OR THEN
;


 ( Test
REQUIRE CreateMut ~pinka\lib\Multi\Mutex.f
0 0 TRUE CreateMut THROW VALUE m1
0 0 TRUE CreateMut THROW VALUE m2
: z
  DROP 
  ." Stack: " .S CR
  BEGIN
    m1 m2 2 -1 WaitAll .
    ." Stack: " .S CR
    1000 PAUSE
  AGAIN
;
' z TASK: z
-11 z START .

m1 ReleaseMut
m2 ReleaseMut
)
