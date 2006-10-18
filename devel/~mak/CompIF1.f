
VECT V_UPPER

' 2DROP TO V_UPPER

: [ELSE]
    1
    BEGIN
      PARSE-NAME 2DUP V_UPPER DUP
      IF  
         2DUP 3 UMIN  S" [IF"  \ все слова с префиксом "[IF"
                        COMPARE 0= IF 2DROP 1+                 ELSE 
         2DUP S" [ELSE]" COMPARE 0= IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [THEN]" COMPARE 0= IF       1-                 THEN
                                    THEN  THEN   
      ELSE 2DROP REFILL  AND \   SOURCE TYPE
      THEN DUP 0=
    UNTIL  DROP ;  IMMEDIATE

: [IF] 0= IF [COMPILE] [ELSE] THEN ;  IMMEDIATE

: [THEN] ;  IMMEDIATE

C" \S" FIND NIP 0=
[IF]
: \S            \ comment to end of file
     SOURCE-ID FILE-SIZE DROP
     SOURCE-ID REPOSITION-FILE DROP
     [COMPILE] \ ; IMMEDIATE
[THEN]
