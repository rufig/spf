\ 10.Dec.2006
\ used by fix-refill.f

MODULE: CORE_OF_ACCEPT

: readout ( a u1 -- a u2 ior )
  H-STDIN READOUT-FILE
;
' readout S" next-line.proto.f" Included

5 1024 *  C/L CELL+  UMAX  VALUE /BUF

: TURN-BUF ( -- )
  /BUF DUP ALLOCATE THROW SWAP ASSUME
;

TURN-BUF

EXPORT

: READOUT-STDIN ( a u -- a u1 )
  READOUT
;
: NEXT-LINE-STDIN ( -- a u true | false )
  NEXT-LINE
;
: ACCEPT2 ( c-addr +n1 -- n2 ) \ 94
  NEXT-LINE IF SEATED- NIP EXIT THEN
  ( c-addr +n1 ) -1002 THROW
;

..: AT-PROCESS-STARTING TURN-BUF ['] ACCEPT2 TO ACCEPT ;..

' ACCEPT2 TO ACCEPT

;MODULE