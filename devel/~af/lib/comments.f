\ еще один многострочный коментарий  :-) (~ruvim)
: (*  ( -- )
  BEGIN
    NextWord DUP 0=
    IF  NIP  REFILL   0= IF DROP TRUE THEN
    ELSE  S" *)" COMPARE 0=  THEN
  UNTIL
; IMMEDIATE
