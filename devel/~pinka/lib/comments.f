
\ еще один многострочный коментарий  :-)
: (*  ( -- )
  BEGIN
      BL WORD COUNT  DUP   0=
      IF  NIP  REFILL   0= ABORT" No access"
      ELSE  S" *)" COMPARE 0=  THEN
  UNTIL
; IMMEDIATE

