: [h] HEX      ; IMMEDIATE
: [b] 2 BASE ! ; IMMEDIATE
: [d] DECIMAL  ; IMMEDIATE
 
\ комментарий
: \*
   BEGIN
     BEGIN
       NextWord DUP
     WHILE
       S" *\" COMPARE 0= IF EXIT THEN
     REPEAT
     2DROP
     REFILL 0=
   UNTIL
;

: NEXT-WORD NextWord ;
: GET-CHAR GetChar  ;

: [ELSE]
    1
    BEGIN
      NEXT-WORD DUP
      IF  
         2DUP S" [IF]"   COMPARE 0= IF 2DROP 1+                 ELSE 
         2DUP S" [ELSE]" COMPARE 0= IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [THEN]" COMPARE 0= IF       1-                 THEN
                                    THEN  THEN   
      ELSE 2DROP REFILL  AND
      THEN DUP 0=
    UNTIL  DROP ;  IMMEDIATE

: [IF] 0= IF [COMPILE] [ELSE] THEN ;  IMMEDIATE

: [THEN] ;  IMMEDIATE

\ Очень понятное и простое слово
: #define
  CREATE
     0 PARSE EVALUATE ,
  DOES> @
; 
