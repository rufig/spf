
\ 26.09.99г. 01:41:17

\ перенаправление ввода/вывода.  работает до первой ошибки :-)
\ т.к. потом хэндлы восстаналиваются...

\ 05.04.2001 * подравлено для SPF4  ( used: FILE>RSTREAM )

REQUIRE  [IF]        lib\include\tools.f
REQUIRE  TOEND-FILE  ~pinka\lib\FileExt.f

0 VALUE  prev_H-STDOUT

: <<    ( a u -- )  \ перенаправление вывода

    H-STDOUT TO prev_H-STDOUT

    2DUP W/O OPEN-FILE-SHARED
    IF DROP
      W/O CREATE-FILE-SHARED THROW
    ELSE >R 2DROP R>   DUP TOEND-FILE  THROW THEN
    TO H-STDOUT
\    H-STDOUT TO H-STDERR
;
: restore-out
    H-STDOUT prev_H-STDOUT <> IF
      H-STDOUT CLOSE-FILE THROW
      prev_H-STDOUT TO H-STDOUT
    THEN
;


: <<out ( a u -- )
    W/O CREATE-FILE-SHARED THROW  TO H-STDOUT
;

: <<err ( a u -- )
    W/O CREATE-FILE-SHARED THROW  TO H-STDERR
;

VERSION DUP 400000 < SWAP 400007 > OR [IF]

: >>    ( a u -- )  \ перенаправления ввода
    R/O OPEN-FILE-SHARED THROW
    DUP TO   H-STDIN
    TO SOURCE-ID
;                 [ELSE]
: >>    ( a u -- )  \ перенаправления ввода
    R/O OPEN-FILE-SHARED THROW
    FILE>RSTREAM
    DUP TO   H-STDIN
    TO SOURCE-ID
;                 [THEN]

\ : close-redirect ( -- )
\    CONSOLE-HANDLES
\ ;
