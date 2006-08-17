VARIABLE header
TRUE header !

: Recv ( addr u -- f )
  S" Received:" SEARCH NIP NIP
;

: From ( addr u -- f )
  S" From:" SEARCH NIP NIP
;

: '' ( addr u -- f )
  NIP
  0=
;

: Flags ( addr u -- n ) \ n:(header;Recv;From;'')
  2>R
  header @                8 AND
  2R@ Recv                4 AND OR
  2R@ From                2 AND OR
  2R> ''                  1 AND OR
;

: Out ( addr u -- )
  TYPE CR
;

: Err ( addr u -- )
  TYPE CR ABORT
;

: Pass ( addr u -- )
  2DROP
;

: HandleString ( addr u -- )
  2DUP
  Flags CASE
    0 OF Out ENDOF
    1 OF Out ENDOF
    2 OF Out ENDOF
    3 OF Err ENDOF
    4 OF Pass TRUE header ! ENDOF
    5 OF Err ENDOF
    6 OF Err ENDOF
    7 OF Err ENDOF
    8 OF Pass ENDOF
    9 OF Pass FALSE header ! ENDOF
   10 OF CR ." /^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__/^^\__" CR
         Out CR ENDOF
   11 OF Err ENDOF
   12 OF Pass ENDOF
   13 OF Err ENDOF
   14 OF Err ENDOF
   15 OF Err ENDOF
  ENDCASE
;


: ClearMail
  BEGIN
    REFILL
  WHILE
    SOURCE HandleString
  REPEAT
;

: ClearMailFile ( file-to-a file-to-u )
  H-STDOUT >R
  R/W CREATE-FILE-SHARED THROW TO H-STDOUT

  ['] ClearMail CATCH
  ?DUP IF
    ." Error detected"
    THROW
  THEN

  H-STDOUT CLOSE-FILE THROW
  R> TO H-STDOUT
;
