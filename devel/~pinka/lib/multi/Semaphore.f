\ 10.Feb.2001
\ semaphores
\ Wait и Release* не возвращают ior. При ошибке вызывают THROW внутри.

WINAPI: CreateSemaphoreA KERNEL32.DLL
WINAPI: ReleaseSemaphore KERNEL32.DLL

\ CreateSemaphore
( S:  az-name|0 MaximumCount InitialCount lpSemaphoreAttributes|0  -- HANDLE )
( az-name can contain any character except the backslash [\] path-separator character. 
  Name comparison is case sensitive. 
  event, mutex, semaphore, and file-mapping objects share the same name space. 
)

\ ReleaseSemaphore
( S: lplPreviousCount|0  cReleaseCount   hSemaphore -- BOOL )
( lplPreviousCount - Points to a 32-bit variable to receive 
the previous count for the semaphore.
  cReleaseCount - Specifies the amount by which the semaphore 
object's current count is to be increased.
  If the function succeeds, the return value is TRUE /=1/
  If the function fails, the return value is FALSE /=0/ 
)

: CreateSem ( addr u MaxCount InitCount -- handle ior )
\ создает семафор. Если InitCount=0, то созданный семфор занят.
\ порядок Max Init - как в DO...LOOP ;)
\ addr u - имя (или 0 0)
  ROT DROP \ убираю длину
  0 \ default security descriptor,  the resulting handle is not inheritable.
  CreateSemaphoreA  DUP  ERR
;

: ReleaseSem ( n handle -- )
\ счетчик увеличивается на n
  0 ROT ROT
  ReleaseSemaphore ERR THROW
;

: DeleteSem ( handle -- ior )
  CloseHandle ERR
;
