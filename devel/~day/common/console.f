\ Console operations
WINAPI: SetConsoleCursorPosition KERNEL32.DLL
WINAPI: SetConsoleTextAttribute  KERNEL32.DLL
WINAPI: FillConsoleOutputCharacterA KERNEL32.DLL
WINAPI: GetLargestConsoleWindowSize KERNEL32.DLL
WINAPI: SetConsoleCursorInfo     KERNEL32.DLL
WINAPI: GetConsoleCursorInfo     KERNEL32.DLL

: ?WinError
  0= IF GetLastError THROW THEN
;
: AT-XY ( X Y -- )
  16 LSHIFT OR H-STDOUT SetConsoleCursorPosition DROP
;

: TEXT-ATTR ( fg bg -- )
  16 * + H-STDOUT SetConsoleTextAttribute ?WinError
; \ 

: MAX-XY ( -- x y )
   H-STDOUT GetLargestConsoleWindowSize
   DUP 16 RSHIFT SWAP 0xFFFF AND SWAP
;

: CLS
   0 >R RP@ 0 MAX-XY * BL H-STDOUT FillConsoleOutputCharacterA R> 2DROP
;

CREATE CONSOLE_CURSOR_INFO 8 ALLOT

\ Взято у ~micro
: HIDE-CURSOR
\ Спрятать курсор
  CONSOLE_CURSOR_INFO H-STDOUT GetConsoleCursorInfo DROP
  0 CONSOLE_CURSOR_INFO 4 + !
  CONSOLE_CURSOR_INFO H-STDOUT SetConsoleCursorInfo DROP
;
