WINAPI: RasConnectionNotificationA RASAPI32.DLL
WINAPI: CreateEventA               KERNEL32.DLL
WINAPI: WaitForSingleObject        KERNEL32.DLL

: WAIT_DISCONNECT ( - u)
\ Ждем дисконнекта линии
\ Если возвратили 0 то значит event нормально произошел
   RASCN_Disconnection
   0 0 0 0 CreateEventA DUP >R
   INVALID_HANDLE_VALUE
   RasConnectionNotificationA ABORT" Something wrong..."
   INFINITE R@ WaitForSingleObject
   R> CloseHandle DROP
;