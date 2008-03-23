: )) ( ->bl; -- )
  BL PARSE symbol-lookup 
  STATE @ IF
   ()))-adr COMPILE,
   TC-LIT,
   (__ret2) @ IF
     symbol-call2-adr COMPILE,
   ELSE
     symbol-call-adr COMPILE,
   THEN
   (__ret2) 0!
\  ELSE
\    ())) 1- SWAP symbol-call
  THEN
; IMMEDIATE

: (()) ( ->bl; -- )
  BL PARSE symbol-lookup 
  STATE @ IF
   0 TC-LIT, TC-LIT,
   (__ret2) @ IF
      symbol-call2-adr COMPILE,
    ELSE
      symbol-call-adr COMPILE,
    THEN
    (__ret2) 0!
\  ELSE
\    ())) 1- SWAP symbol-call
  THEN
; IMMEDIATE

: __ret2 ( -- ) TRUE (__ret2) ! ; IMMEDIATE
