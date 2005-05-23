\ 02.Jul.2002 ruv
\ Output redirection, output control
\ ”правление  выходным потоком.

\ 12.Jul.2002 for Eproxy

\ 25.Jan.2005 Tue 12:43
\ from cvs\eserv\trafc\src\lib\ext\mouth.f 

\ 11.May.2005
\ mouth -> tank

: SAVE-TANK ( -- i*x i )
  H-STDOUT 1
;
: RESTORE-TANK ( i*x i -- )
  1 <> ABORT" Abort restore tank. "
  TO H-STDOUT
;
: TANK-ID! ( hfile -- )
  TO H-STDOUT
; 
: STD-TANK ( -- )
  -11 GetStdHandle TO H-STDOUT
  ( implementation is environmental dependencies )
;
: SPEAK-FILE-WITH ( i*x hfile xt -- j*x ior )
\ execute xt within hfile for stdout
  SAVE-TANK N>R
  SWAP TANK-ID!
  CATCH
  NR> RESTORE-TANK
;

: APPEND-FILE ( a-file u-file -- h )
\ open file for append, or create file
  2DUP FILE-EXIST 0= IF
    W/O CREATE-FILE-SHARED THROW  EXIT
  THEN
  W/O OPEN-FILE-SHARED THROW >R
  R@ FILE-SIZE       ?DUP IF R> CLOSE-FILE DROP THROW THEN
  R@ REPOSITION-FILE ?DUP IF R> CLOSE-FILE DROP THROW THEN
  R>
;
: APPEND-FILE-CATCH ( a-file u-file -- h ior )
  ['] APPEND-FILE CATCH DUP IF NIP NIP 0 SWAP THEN
;
: SPEAK-WITH ( i*x a u xt -- j*x )
  >R APPEND-FILE R> OVER >R
  SPEAK-FILE-WITH ( ior )
  R> CLOSE-FILE SWAP THROW THROW
;
