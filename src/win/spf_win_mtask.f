\ $Id$

( Многозадачность.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)
: START ( x task -- th )
  \ запустить поток task (созданный с помощью TASK:) с параметром x
  \ возвращает th - хэндл потока, или 0 в случае неудачи
  0 >R RP@
  0 2SWAP 0 0 CreateThread
  RDROP
;
: SUSPEND ( th -- )
  \ усыпить поток
  SuspendThread DROP
;
: RESUME ( th -- )
  \ разбудить поток
  ResumeThread DROP
;
: STOP ( th -- )
  \ остановить поток (удалить)
  -1 SWAP TerminateThread DROP
;
: PAUSE ( ms -- )
  \ приостановить текущий поток на ms миллисекунд (1000=1сек)
  Sleep DROP
;
: TERMINATE ( -- )
  \ остановить текущий поток (удалить)
  DESTROY-HEAP
  -1 ExitThread
;
: THREAD-ID ( -- n ) 
  \ идентификатор потока
  36 FS@ 
;
