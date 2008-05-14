\ ¬озвращает позицию курсора в консоли

REQUIRE STRUCT:	lib/ext/struct.f

STRUCT: COORD
2 -- X
2 -- Y
;STRUCT
STRUCT: SMALL_RECT
2 -- Left
2 -- Top
2 -- Right
2 -- Bottom
;STRUCT
STRUCT: CONSOLE_SCREEN_BUFFER_INFO
     COORD::/SIZE -- dwSize
     COORD::/SIZE -- dwCursorPosition
                2 -- wAttributes
SMALL_RECT::/SIZE -- srWindow
     COORD::/SIZE -- dwMaximumWindowSize
;STRUCT

CREATE buf CONSOLE_SCREEN_BUFFER_INFO::/SIZE ALLOT
WINAPI: GetConsoleScreenBufferInfo kernel32.dll

: getxy ( -- x y )
  buf H-STDOUT GetConsoleScreenBufferInfo DROP
  buf CONSOLE_SCREEN_BUFFER_INFO::dwCursorPosition
  DUP COORD::X W@
  SWAP COORD::Y W@
;
