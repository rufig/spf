\ $Id$
\ 
\ INTER - localized QUIT
\ RETNI breaks interpreter loop and returns from currently active INTER (if any)
\ alternatively use Ctrl-Z to break
\ Useful for semi-interactive debugging

: INTER-MAIN ( -- )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT
;

USER-VALUE QUIT-INTER

: INTER ( -- )
  FALSE TO QUIT-INTER
  BEGIN
    QUIT-INTER FALSE = 
  WHILE 
    H-STDIN H-STDLOG H-STDOUT H-STDERR >R >R >R >R
    CONSOLE-HANDLES
    SOURCE-ID >R
    SOURCE-ID-XT >R
    0 TO SOURCE-ID
    0 TO SOURCE-ID-XT
    [COMPILE] [
    ['] INTER-MAIN CATCH QUIT-INTER 0= IF DUP 0= TO QUIT-INTER THEN
    ['] ERROR CATCH DROP
    R> TO SOURCE-ID-XT
    R> TO SOURCE-ID
    R> R> R> R> TO H-STDERR TO H-STDOUT TO H-STDLOG TO H-STDIN
  \  R0 @ RP!
  \  S0 @ SP!
  \  стеки не сбрасываем - мы у кого-то внутри
  REPEAT
;

: RETNI TRUE TO QUIT-INTER ABORT ;

\EOF

: t 123 . 4 5 INTER ." qwert" CR . . CR ;
t
