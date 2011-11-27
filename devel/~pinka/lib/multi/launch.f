
: (LAUNCHER) ( xt -- ) CATCH ERROR ;  ' (LAUNCHER) TASK CONSTANT LAUNCHER

: LAUNCH ( xt -- ) (  xt [ -- ]  ) 
  LAUNCHER START  CloseHandle ERR THROW
; 

: LAUNCHED ( xt -- h ) \ xt ( -- )
  LAUNCHER START
;
