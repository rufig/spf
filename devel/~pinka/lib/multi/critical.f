\ 18.Jan.2004  ~ruv
\ $Id$

WINAPI: InitializeCriticalSection  KERNEL32.DLL
WINAPI: EnterCriticalSection       KERNEL32.DLL
WINAPI: LeaveCriticalSection       KERNEL32.DLL
WINAPI: DeleteCriticalSection      KERNEL32.DLL

\ CS == Critical Section

CREATE CS-LIST 0 ,

: CREATE-CS ( "name" -- )  \  name ( -- cs )
\ Создать критическую секцию с именем name
  CREATE 
  HERE
  6 CELLS ALLOT
  DUP  InitializeCriticalSection DROP
  CS-LIST @ ,
  CS-LIST !
;

: ActivateCSs ( -- )
  CS-LIST @     BEGIN
  DUP           WHILE
  DUP  InitializeCriticalSection DROP
  6 CELLS + @   REPEAT DROP
;
: DeactivateCSs ( -- )
  CS-LIST @     BEGIN
  DUP           WHILE
  DUP  DeleteCriticalSection DROP
  6 CELLS + @   REPEAT DROP
;
..: AT-PROCESS-STARTING   ActivateCSs    ;..
..: AT-PROCESS-FINISHING  DeactivateCSs  ;..

: ENTER-CS ( cs -- )
\ Войти (завладеть) в критическую секцию cs 
\ Пока какой-либо поток владеет критической секцией, 
\  остальные будут ждать внутри ENTER-CS
    EnterCriticalSection DROP
;
: LEAVE-CS ( cs -- )
\ Покинуть (освободить) критическую секцию cs
    LeaveCriticalSection DROP
;
