     -10 CONSTANT STD_INPUT_HANDLE
     -11 CONSTANT STD_OUTPUT_HANDLE
     -12 CONSTANT STD_ERROR_HANDLE

00000002 CONSTANT DUPLICATE_SAME_ACCESS

WINAPI: CreatePipe        KERNEL32.DLL
WINAPI: DuplicateHandle   KERNEL32.DLL
WINAPI: GetCurrentProcess KERNEL32.DLL
WINAPI: SetStdHandle      KERNEL32.DLL
WINAPI: CreateProcessA    KERNEL32.DLL

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
