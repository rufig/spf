\ SetHandler - ���������� ���������� Ctrl+C, Ctrl+Break, Close & Shutdown
\ ��� ����������� ����������.
\ ��� ��������� ����� �������� ����� ����������� AtShutdown
\ Win9x,ME �� �������� ������ ��� Shutdown :(

WINAPI: SetConsoleCtrlHandler KERNEL32.DLL

VECT AtShutdown ' BYE TO AtShutdown

:NONAME AtShutdown TRUE ; WNDPROC: ShutdownHandler

: SetHandler
  TRUE ['] ShutdownHandler SetConsoleCtrlHandler DROP
;

