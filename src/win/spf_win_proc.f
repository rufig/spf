\ $Id$

( »спользуемые €дром функции Windows.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  –евизи€ - сент€брь 1999
)

WINAPI: GetStdHandle                  KERNEL32.DLL
WINAPI: GetLastError                  KERNEL32.DLL
WINAPI: CloseHandle                   KERNEL32.DLL
WINAPI: SetFilePointer                KERNEL32.DLL
WINAPI: GetFileSize                   KERNEL32.DLL
WINAPI: ReadFile                      KERNEL32.DLL
WINAPI: WriteFile                     KERNEL32.DLL
WINAPI: SetEndOfFile                  KERNEL32.DLL
WINAPI: ExitProcess                   KERNEL32.DLL
WINAPI: ExitThread                    KERNEL32.DLL     
WINAPI: GetNumberOfConsoleInputEvents KERNEL32.DLL
WINAPI: GetProcAddress                KERNEL32.DLL
WINAPI: GetProcessHeap                KERNEL32.DLL
WINAPI: HeapCreate                    KERNEL32.DLL
WINAPI: HeapDestroy                   KERNEL32.DLL
WINAPI: HeapAlloc                     KERNEL32.DLL
WINAPI: HeapFree                      KERNEL32.DLL
WINAPI: HeapReAlloc                   KERNEL32.DLL
WINAPI: CreateThread                  KERNEL32.DLL
WINAPI: SuspendThread                 KERNEL32.DLL
WINAPI: ResumeThread                  KERNEL32.DLL
WINAPI: TerminateThread               KERNEL32.DLL
WINAPI: Sleep                         KERNEL32.DLL
WINAPI: FlushFileBuffers              KERNEL32.DLL

1 CHAR-SIZE = [IF]

WINAPI: GetFileAttributesA            KERNEL32.DLL
WINAPI: CreateFileA                   KERNEL32.DLL
WINAPI: DeleteFileA                   KERNEL32.DLL
WINAPI: ReadConsoleInputA             KERNEL32.DLL
WINAPI: GetCommandLineA               KERNEL32.DLL
WINAPI: LoadLibraryA                  KERNEL32.DLL
WINAPI: CharToOemBuffA                USER32.DLL
WINAPI: OemToCharBuffA                USER32.DLL
WINAPI: GetModuleFileNameA            KERNEL32.DLL
WINAPI: GetEnvironmentVariableA       KERNEL32.DLL

[ELSE] \ 2 

WINAPI: GetFileAttributesW            KERNEL32.DLL
WINAPI: CreateFileW                   KERNEL32.DLL
WINAPI: DeleteFileW                   KERNEL32.DLL
WINAPI: ReadConsoleInputW             KERNEL32.DLL
WINAPI: GetCommandLineW               KERNEL32.DLL
WINAPI: LoadLibraryW                  KERNEL32.DLL
WINAPI: CharToOemBuffW                USER32.DLL
WINAPI: OemToCharBuffW                USER32.DLL
WINAPI: GetModuleFileNameW            KERNEL32.DLL
WINAPI: GetEnvironmentVariableW       KERNEL32.DLL

: GetFileAttributesA GetFileAttributesW ;
: CreateFileA CreateFileW ;
: DeleteFileA DeleteFileW ;
: ReadConsoleInputA ReadConsoleInputW ;
: GetCommandLineA GetCommandLineW ;
: LoadLibraryA LoadLibraryW ;
: CharToOemBuffA CharToOemBuffW ;
: OemToCharBuffA OemToCharBuffW ;
: GetModuleFileNameA GetModuleFileNameW ;
: GetEnvironmentVariableA GetEnvironmentVariableW ;

[THEN]


