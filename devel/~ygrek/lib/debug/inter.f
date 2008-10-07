\ $Id$
\ 
\ INTER - local QUIT - switches to interpreter in the context of the caller
\ RETNI breaks interpreter loop and returns from currently active INTER (if any)
\ Alternatively input "End of stream" (Ctrl-Z on Windows, Ctrl-D on Linux) to return back
\ 
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
  CR ." INTER" OK
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

REQUIRE .S lib/include/tools.f
: t ." I will put 123 on the stack" 123 INTER ." Stack : " .S ;
t
