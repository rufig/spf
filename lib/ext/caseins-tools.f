REQUIRE COMPARE-U   ~ac/lib/string/compare-u.f 

: [else]   \ 94 TOOLS EXT
    1
    BEGIN
      PARSE-NAME DUP
      IF  
         2DUP S" [if]"   COMPARE-U 0= IF 2DROP 1+                 ELSE 
         2DUP S" [else]" COMPARE-U 0= IF 2DROP 1- DUP  IF 1+ THEN ELSE 
              S" [then]" COMPARE-U 0= IF       1-                 THEN
                                    THEN  THEN   
      ELSE 2DROP REFILL  AND \   SOURCE TYPE
      THEN DUP 0=
    UNTIL  DROP 
;  IMMEDIATE

: [if] \ 94 TOOLS EXT
  0= IF POSTPONE [else] THEN
; IMMEDIATE
