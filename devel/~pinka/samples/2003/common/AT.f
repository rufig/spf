\ 01.Nov.2003 Sat 16:23

: [AT]
  ?COMP  ' >BODY LIT, POSTPONE !
; IMMEDIATE

: AT
  STATE @ 0=  
  IF      ' >BODY !   
  ELSE    POSTPONE [AT]
  THEN
; IMMEDIATE

\EOF
\ for example:

: MyDef1
  CREATE 
    1 ,
  DOES>
    @ . \ ...
;

MyDef1 q1
q1   2 AT q1   q1
