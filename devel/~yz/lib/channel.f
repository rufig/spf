\ Широковещательные каналы
\ Ю. Жиловец, 14.06.2004

REQUIRE " ~yz/lib/common.f
REQUIRE { lib/ext/locals.f
REQUIRE <( ~yz/lib/format.f

WINAPI: CreateFileMappingA  KERNEL32.DLL
WINAPI: MapViewOfFile	    KERNEL32.DLL
WINAPI: CreateEventA        KERNEL32.DLL
WINAPI: CreateMutexA        KERNEL32.DLL
WINAPI: UnmapViewOfFile     KERNEL32.DLL
WINAPI: PulseEvent          KERNEL32.DLL
WINAPI: WaitForSingleObject KERNEL32.DLL
WINAPI: ReleaseMutex        KERNEL32.DLL

MODULE: channel

101 == channel-size
0 VALUE ?global-prefix

0
CELL -- :chFilemapping
CELL -- :chAddress
CELL -- :chLock
CELL -- :chEvent
9    -- :chName
== #channel

WINAPI: GetVersionExA KERNEL32.DLL

: isXP? { \ [ 148 ] vers -- ? }
  148 vers !  vers GetVersionExA DROP
  vers 4 CELLS@ 2 ( W: ver_platform_win32_nt) = IF
    vers 1 CELLS@ 5 < NOT  vers 2 CELLS@ 1 < NOT AND
  ELSE 
    FALSE
  THEN
;

: object-name ( ch zsuffix -- )
  >R >R <( ?global-prefix R> :chName R> " ~Z~Z_~Z" )>
;

WINAPI: InitializeSecurityDescriptor ADVAPI32.DLL
WINAPI: SetSecurityDescriptorDacl    ADVAPI32.DLL

: fill-channel { ch \ [ 20 CELLS ] sd [ 3 CELLS ] sa -- ch/0 }
  \ Готовим дескриптор безопасности, разрешающий общий доступ
  1 ( SECURITY_DESCRIPTOR_REVISION ) sd InitializeSecurityDescriptor DROP
  FALSE 0 TRUE sd SetSecurityDescriptorDacl DROP
  3 CELLS sa !
  sd sa 1 CELLS!
  FALSE sa 2 CELLS!
  \ Создаем общие объекты
  ch " event" object-name FALSE ( non-signal)
  TRUE ( manual reset) sa CreateEventA
  DUP 0= IF EXIT THEN ch :chEvent !
  ch " lock" object-name FALSE ( not own) sa CreateMutexA 
  DUP 0= IF EXIT THEN ch :chLock !
  ch " filemap" object-name channel-size 0 4 ( W: page_readwrite) sa -1 CreateFileMappingA
  DUP 0= IF EXIT THEN ch :chFilemapping !
  channel-size 0 0 0xF001F ( W: file_map_all_access) 
  ch :chFilemapping @ MapViewOfFile
  DUP 0= IF EXIT THEN ch :chAddress !
  ch :chAddress @ 0!
  ch
;

: [[[ ( mutex -- ) -1 SWAP WaitForSingleObject DROP ;
: ]]] ( mutex -- ) ReleaseMutex DROP ;

EXPORT

: init-channels ( --)
  isXP? IF " Global\\" ELSE "" THEN TO ?global-prefix
;

: create-channel ( zname -- ch/0)
  #channel GETMEM >R
  R@ :chName ZMOVE
  R@ fill-channel R> 
  SWAP 0= IF FREEMEM 0 THEN
;

: delete-channel ( ch -- )
  >R
  R@ :chAddress @     UnmapViewOfFile DROP
  R@ :chFilemapping @ CloseHandle     DROP
  R@ :chEvent @       CloseHandle     DROP
  R@ :chLock  @       CloseHandle     DROP
  R> FREEMEM 
;

: write-channel { a # ch -- }
  # 100 MIN TO #
  ch :chLock @ [[[
  # ch :chAddress @ C!
  a ch :chAddress @ 1+ # CMOVE
  ch :chLock @ ]]]
  ch :chEvent @ PulseEvent DROP
;

: read-channel { a ch -- a # }
  -1 ch :chEvent @ WaitForSingleObject DROP
  ch :chLock @ [[[
  ch :chAddress @ DUP C@ >R 1+ a R@ CMOVE
  a R>
  ch :chLock @ ]]]
;

;MODULE

\EOF

0 VALUE ch
12345
init-channels
" xmenu" create-channel TO ch
S" Hello" ch write-channel
ch delete-channel
s. BYE
