\ используемые функции есть на WinXP/2003, на остальных эмулируются

WINAPI: GetCurrentProcess KERNEL32.DLL
REQUIRE DLOPEN    ~ac/lib/ns/dlopen.f 
REQUIRE ReduceMem ~ac/lib/memory/less_mem.f

VARIABLE _CreateMemoryResourceNotification
VARIABLE _QueryMemoryResourceNotification

: CreateMemoryResourceNotification ( flag -- handle )
  _CreateMemoryResourceNotification @
  ?DUP IF API-CALL THEN
;
: QueryMemoryResourceNotification ( var handle -- flag )
  _QueryMemoryResourceNotification @
  ?DUP IF API-CALL ELSE SWAP ! 1 THEN
;
VARIABLE LowMemory
VARIABLE LowMemoryH
VARIABLE HighMemory
VARIABLE HighMemoryH

: LowMemory? ( -- flag )
  LowMemory LowMemoryH @ QueryMemoryResourceNotification ( ERR) DROP
  LowMemory @ 0 <>
;
: HighMemory? ( -- flag )
  HighMemory HighMemoryH @ QueryMemoryResourceNotification ( ERR) DROP
  HighMemory @ 0 <>
;
: InitMemoryNotification ( -- )
  S" KERNEL32.DLL" DLOPEN ?DUP
  IF >R
     S" CreateMemoryResourceNotification" R@ DLSYM _CreateMemoryResourceNotification !
     S" QueryMemoryResourceNotification" R> DLSYM _QueryMemoryResourceNotification !
  THEN
  0 CreateMemoryResourceNotification LowMemoryH !
  1 CreateMemoryResourceNotification HighMemoryH !
;
: WaitHighMemory,Log
\  200000000 ALLOCATE THROW 200000000 5 FILL
  HighMemoryH @ 0= IF InitMemoryNotification THEN
  BEGIN
    HighMemory? 0=
  WHILE
    ." LowMemory..." 2000 PAUSE
    ReduceMem
  REPEAT
;
\ InitMemoryNotification HighMemory? . LowMemory? .
\ WaitHighMemory,Log
