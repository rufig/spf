\ Лог с выводом в Critical Section (быстрая альтернатива Mutex)
\ TYPE будет логгировать НЕ через CriticalSection

WINAPI: InitializeCriticalSection  KERNEL32.DLL
WINAPI: EnterCriticalSection       KERNEL32.DLL
WINAPI: LeaveCriticalSection       KERNEL32.DLL
WINAPI: DeleteCriticalSection      KERNEL32.DLL

CREATE _logcs 6 CELLS ALLOT

: InitLogCS
    _logcs InitializeCriticalSection DROP
;

..: AT-PROCESS-STARTING
      InitLogCS
;..

: TO-LOG ( addr u -- )
   _logcs EnterCriticalSection DROP
   TO-LOG
   _logcs LeaveCriticalSection DROP
;

InitLogCS
