: (WINAPI:) >IN @ >R
    BL WORD FIND NIP 
    0= IF R> >IN ! WINAPI: 
       ELSE RDROP BL WORD DROP THEN
;
WARNING @ WARNING 0!
: WINAPI:
    ['] (WINAPI:) CATCH ?DUP
    IF
        SOURCE TYPE ."  - entry not found" CR
    THEN
;
WARNING !