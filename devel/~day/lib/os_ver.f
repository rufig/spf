\ Определение текущей OS где запущены
\ Пока только кандидат на включение...

~day\wincons\wc.f

WINAPI: GetVersionExA                 KERNEL32.DLL

0
CELL -- dwOSVersionInfoSize
CELL -- dwMajorVersion
CELL -- dwMinorVersion
CELL -- dwBuildNumber
CELL -- dwPlatformId
 128 -- szCSDVersion
CONSTANT /OSVERSIONINFO


0 CONSTANT OS_WIN95
1 CONSTANT OS_WIN98
2 CONSTANT OS_WINNT

: OSVER ( -- n )
   /OSVERSIONINFO ALLOCATE THROW DUP >R
   /OSVERSIONINFO R@ !
   GetVersionExA DROP
   R@ dwPlatformId @ DUP VER_PLATFORM_WIN32_NT =
   IF OS_WINNT SWAP THEN
   VER_PLATFORM_WIN32_WINDOWS =
   IF
     R@ dwMinorVersion @ 0 > R@ dwMajorVersion @ 4 = AND
     R@ dwMajorVersion @ 4 > OR IF OS_WIN98 ELSE OS_WIN95 THEN
   THEN
   R> FREE THROW
;

\ OSVER