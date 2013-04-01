WINAPI: SetStdHandle kernel32.dll ( hHandle nStdHandle -- bool )

: SET-STDIN-SYS ( h -- )
  -10 \ STD_INPUT_HANDLE
  SetStdHandle ERR THROW
;
: SET-STDOUT-SYS ( h -- )
  -11 \ STD_OUTPUT_HANDLE
  SetStdHandle ERR THROW
;
: SET-STDERR-SYS ( h -- )
  -12 \ STD_ERROR_HANDLE
  SetStdHandle ERR THROW
;
