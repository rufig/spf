
( syntax: NEEDS ~day\lib\clipboard.f )

WORDLIST CONSTANT WL-MODULES

: MODULEHASH ( addr u -- addr1 u1 )
    0 HASH GET-CURRENT
    BASE @ >R HEX
    <# #S #>
    R> BASE !
;

: ADD-MODULE ( addr u )
    MODULEHASH
    GET-CURRENT WL-MODULES SET-CURRENT
    >R CREATED
    R> SET-CURRENT
;

: NEEDS
    PARSE-NAME 2DUP MODULEHASH WL-MODULES SEARCH-WORDLIST
    IF
         DROP 2DROP
    ELSE
         2DUP 
         2DUP + 0 SWAP C!
         ADD-MODULE
         INCLUDED
    THEN
;

: NEEDED ( "word" "module" -- )
    PARSE-NAME SFIND
    IF
       DROP PARSE-NAME 
       2DUP + 0 SWAP C!
       ADD-MODULE
    ELSE 2DROP NEEDS
    THEN
;
