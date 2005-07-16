WINAPI: CreateIoCompletionPort     KERNEL32.DLL
WINAPI: GetQueuedCompletionStatus  KERNEL32.DLL
WINAPI: PostQueuedCompletionStatus KERNEL32.DLL

: CREATE-CP ( max-threads -- h ior )
  0 0 INVALID_HANDLE_VALUE CreateIoCompletionPort
  DUP ERR
;
USER ucpOver
USER ucpKey
USER ucpBytes

258 CONSTANT WAIT_TIMEOUT

: GET-CP ( time h -- flag ior )
  \ Возвращает ior=0, если нет ошибок. При этом flag=true, если был 
  \ таймаут ожидания (не было событий за time ms)
  \ При любых ошибках ior<>0, а flag не определен.

  >R ucpOver ucpKey ucpBytes R> GetQueuedCompletionStatus
  0= IF \ таймаут или ошибка
        GetLastError DUP WAIT_TIMEOUT =
        IF DROP TRUE 0 ELSE 0 SWAP THEN
     ELSE 0 0 THEN
;
: POST-CP ( over key bytes h -- ior )
  \ В тестах ior всегда =0, даже попытки переполнения очереди
  \ (не вычитывание через WAIT-CP) не увенчались "успехом" :)
  \ см. TEST1
  \ Потоку можно передать 3 параметра, названия over key bytes
  \ ни к чему не обязывают, если речь не о файлах.

  PostQueuedCompletionStatus ERR
;
\EOF

\ Интересный тест, показывающий, что очередь запросов имеет
\ приличную вместительность (1000 - не проблема). И элементы
\ выбираются в том же порядке, в котором помещаются.

: TEST1
  10 CREATE-CP THROW >R

  1000 BEGIN
    DUP 2 3 R@ POST-CP ." post:" .
  1- DUP 0= UNTIL DROP

  BEGIN
    5000 R@ GET-CP THROW 0=
  WHILE
    ucpOver @ .
  REPEAT ." timeout" 
  R> CLOSE-FILE THROW
;

WINAPI: GetCurrentThreadId KERNEL32.DLL

:NONAME ( cp -- ior )
  >R
  BEGIN
    BEGIN
      -1 R@ GET-CP THROW
    WHILE
\      CR GetCurrentThreadId . ." idle..."
    REPEAT
    CR GetCurrentThreadId . ." :" ucpOver @ .
  AGAIN
  RDROP
; TASK: CP-READER

: TEST2
  10 CREATE-CP THROW
  10 0 DO
    DUP CP-READER START CLOSE-FILE THROW 100 PAUSE
  LOOP
  >R
  1000 BEGIN
    DUP 2 3 R@ POST-CP THROW
    1 PAUSE
  1- DUP 0= UNTIL DROP
  RDROP
;
