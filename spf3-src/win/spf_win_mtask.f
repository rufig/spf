( Многозадачность.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)
: START ( x task -- tid )
  \ запустить поток task (созданный с помощью TASK:) с параметром x
  \ возвращает tid - хэндл потока, или 0 в случае неудачи
  0 >R RP@
  0 2SWAP 0 0 CreateThread
  RDROP
;
: SUSPEND ( tid -- )
  \ усыпить поток
  SuspendThread DROP
;
: RESUME ( tid -- )
  \ разбудить поток
  ResumeThread DROP
;
: STOP ( tid -- )
  \ остановить поток (удалить)
  -1 SWAP TerminateThread DROP
;
: PAUSE ( ms -- )
  \ приостановить поток на ms миллисекунд (1000=1сек)
  \ вызывается самим потоком
  Sleep DROP
;