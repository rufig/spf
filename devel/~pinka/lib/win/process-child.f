REQUIRE [UNDEFINED]             lib/include/tools.f
REQUIRE DUP-HANDLE-INHERITED    ~ac/lib/win/process/pipes.f
REQUIRE CREATE-PIPE-ANON        ~pinka/lib/win/pipes.f

\ partial from ~ac/lib/win/process/
\    process.f
\    child_app.f

[UNDEFINED] /STARTUPINFO [IF]

WINAPI: CreateProcessA KERNEL32.DLL
WINAPI: GetExitCodeProcess KERNEL32.DLL

0
4 -- cb
4 -- lpReserved
4 -- lpDesktop
4 -- lpTitle
4 -- dwX
4 -- dwY
4 -- dwXSize
4 -- dwYSize
4 -- dwXCountChars
4 -- dwYCountChars
4 -- dwFillAttribute
4 -- dwFlags
2 -- wShowWindow
2 -- cbReserved2
4 -- lpReserved2
4 -- hStdInput
4 -- hStdOutput
4 -- hStdError
CONSTANT /STARTUPINFO

0x00000100 CONSTANT STARTF_USESTDHANDLES
         1 CONSTANT STARTF_USESHOWWINDOW

[THEN]

0x00000010 CONSTANT CREATE_NEW_CONSOLE
0x08000000 CONSTANT CREATE_NO_WINDOW
0x00000004 CONSTANT CREATE_SUSPENDED
0x00000400 CONSTANT CREATE_UNICODE_ENVIRONMENT
0x00000008 CONSTANT DETACHED_PROCESS 

[UNDEFINED] /PROCESS_INFORMATION [IF]

0 \ PROCESS_INFORMATION
4 -- hProcess
4 -- hThread
4 -- dwProcessId
4 -- dwThreadId
CONSTANT /PROCESS_INFORMATION

[THEN]

[UNDEFINED] HERITABLE-HANDLE [IF]
: HERITABLE-HANDLE ( h1 -- h2 ) 
  DUP DUP-HANDLE-INHERITED THROW SWAP CLOSE-FILE THROW
; 
[THEN]

: PROCESS-EXITCODE ( h-process -- code ior )
  0 >R RP@ SWAP GetExitCodeProcess ERR R> SWAP
;
