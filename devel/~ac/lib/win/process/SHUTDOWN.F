\ SetHandler - установить обработчик Ctrl+C, Ctrl+Break, Close & Shutdown
\ для консольного приложения.
\ При получении таких сигналов будет выполняться AtShutdown
\ Win9x,ME не посылает сигнал при Shutdown :(

WINAPI: SetConsoleCtrlHandler KERNEL32.DLL

VECT AtShutdown ' BYE TO AtShutdown

:NONAME AtShutdown TRUE ; WNDPROC: ShutdownHandler

: SetHandler
  TRUE ['] ShutdownHandler SetConsoleCtrlHandler DROP
;

