\ original (c) A.Cherezov  ( SPF314\EXT\MUTEX.F)

\ 06.Apr.2001 Ruv
\  * выделил мутексы в отдельную либу (синхронизация в Synchr.f)
\  * имена: CreateMut ReleaseMut DeleteMut
\  * Wait и Release* не возвращают ior. При ошибке вызывают THROW внутри.

WINAPI: CreateMutexA        KERNEL32.DLL
WINAPI: ReleaseMutex        KERNEL32.DLL

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

: CreateMut ( addr u flag -- handle ior )
\ создает объект взаимного исключения
\ addr u - имя
\ flag=TRUE, если создаваемый объект нужно сразу занять
  NIP  1 AND  0 CreateMutexA DUP ERR
;

: ReleaseMut ( handle -- )
\ освобождает объект
  ReleaseMutex ERR THROW
;

: DeleteMut ( handle -- ior )
  CloseHandle ERR
;
