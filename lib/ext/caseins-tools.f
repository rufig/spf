REQUIRE CEQUAL-U lib/ext/uppercase.f

: [else]   \ 94 TOOLS EXT
    1
    BEGIN
      PARSE-NAME DUP
      IF
         2DUP S" [if]"   CEQUAL-U  IF 2DROP 1+                 ELSE 
         2DUP S" [else]" CEQUAL-U  IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [then]" CEQUAL-U  IF       1-                 THEN
                                    THEN  THEN
      ELSE 2DROP REFILL  AND \   SOURCE TYPE
      THEN DUP 0=
    UNTIL  DROP 
;  IMMEDIATE

: [if] \ 94 TOOLS EXT
  0= IF POSTPONE [else] THEN
; IMMEDIATE
