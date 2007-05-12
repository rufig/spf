
( syntax: NEEDS ~day\lib\clipboard.f )

REQUIRE CHAR-UPPERCASE ~ac\lib\string\uppercase.f

WORDLIST CONSTANT WL-MODULES

: UNIFY-SLASH ( c -- c1 )
   DUP [CHAR] / = IF DROP [CHAR] \ THEN
;

: C-HASH ( addr u -- u2 )
   2166136261 ROT ROT
   OVER + SWAP 
   ?DO
      16777619 * I C@ CHAR-UPPERCASE UNIFY-SLASH XOR
   LOOP
;

: MODULEHASH ( addr u -- addr1 u1 )
    C-HASH GET-CURRENT
    BASE @ >R HEX
    <# #S #>
    R> BASE !
;

: ADD-MODULE ( addr u )
    MODULEHASH 2DUP WL-MODULES SEARCH-WORDLIST
    IF 
      DROP 2DROP
    ELSE
      GET-CURRENT WL-MODULES SET-CURRENT
      >R CREATED
      R> SET-CURRENT
    THEN
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

: NEEDED: ( "word" "module" -- )
    PARSE-NAME SFIND
    IF
       DROP PARSE-NAME 
       2DUP + 0 SWAP C!
       ADD-MODULE
    ELSE 2DROP NEEDS
    THEN
;

: REQUIRE NEEDED: ;
    
S" ~day\lib\includemodule.f" ADD-MODULE