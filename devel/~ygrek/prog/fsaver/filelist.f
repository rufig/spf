REQUIRE WildCMP-U ~pinka/lib/mask.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE write-list ~ygrek/lib/list/all.f
REQUIRE SGENRAND ~ygrek/lib/neilbawd/mersenne.f

MODULE: filelist

0 VALUE list-size
() VALUE list

: all-files% ( a u -- )
    100 ITERATE-FILES NIP ( a u flag )
      IF ( directory) 2DROP EXIT THEN
      2DUP S" *.f" WildCMP-U 0= IF >STR %s ELSE 2DROP THEN ;

WINAPI: GetTickCount kernel32.dll

EXPORT

: randomName list-size GENRANDMAX list nth car STR@ ; 

: names-init { a u -- }
   GetTickCount SGENRAND
   %[ a u all-files% ]% TO list
   list empty? 
   IF
    %[ a u " Tweak settings. Bad path : {s}" %s ]% TO list 
    1 TO list-size
   ELSE
    list length TO list-size
   THEN ;

;MODULE
