( Andrey Cherezov 05.Apr.2000 )
\ Version tracking for SPF projects

: LOAD-VERSION ( -- n )
  S" VERSION.SPF" ['] INCLUDED CATCH IF 2DROP 1 THEN
;
: SAVE-VERSION ( n -- )
  H-STDOUT >R
  S" VERSION.SPF" R/W CREATE-FILE THROW TO H-STDOUT
  . CR
  H-STDOUT CLOSE-FILE THROW
  R> TO H-STDOUT
;
