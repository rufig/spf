\ $Id$
\ 
\ Работа с потоками
\ Ю. Жиловец, 20.05.2007

: START ( x task -- tid )
  \ запустить поток task (созданный с помощью TASK:) с параметром x
  \ возвращает tid - хэндл потока, или 0 в случае неудачи
  0 >R RP@ 0 2SWAP SWAP 4 <( )) pthread_create
  IF RDROP 0 ELSE R> THEN
;
: SUSPEND ( tid -- )
  \ усыпить поток
  \ Реализация только для Линукс!
  1 <( 19 ( SIGSTOP) )) pthread_kill DROP
;
: RESUME ( tid -- )
  \ разбудить поток
  \ Реализация только для Линукс!
  1 <( 18 ( SIGCONT) )) pthread_kill DROP
;
: STOP ( tid -- )
  \ остановить поток (удалить)
  1 <( )) pthread_cancel DROP
;
: PAUSE ( ms -- )
  \ приостановить поток на ms миллисекунд (1000=1сек)
  \ вызывается самим потоком
  1000 /MOD SWAP 1000000 * >R >R
  (( RP@ 0 )) nanosleep DROP RDROP RDROP
;

: TERMINATE ( -- )
  \ остановить текущий поток (удалить)
  (( -1 )) pthread_exit DROP
;
