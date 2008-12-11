REQUIRE WildCMP-U ~pinka/lib/mask.f
REQUIRE ITERATE-FILES ~profit/lib/iterate-files.f
REQUIRE list-make ~ygrek/lib/list/make.f
REQUIRE SGENRAND ~ygrek/lib/neilbawd/mersenne.f
REQUIRE ms@ lib/include/facil.f

MODULE: filelist

0 VALUE list-size
list::nil VALUE l

: all-files% ( a u -- )
    100 ITERATE-FILES NIP ( a u flag )
      IF ( directory) 2DROP EXIT THEN
      2DUP S" *.f" WildCMP-U 0= IF >STR % ELSE 2DROP THEN ;

EXPORT

: randomName list-size GENRANDMAX l list::nth list::car STR@ ; 

: names-init { a u -- }
   ms@ SGENRAND
   %[ a u all-files% ]% TO l
   list list::empty?
   IF
    %[ a u " Tweak settings. Bad path : {s}" % ]% TO l
    1 TO list-size
   ELSE
    l list::length TO list-size
   THEN ;

;MODULE
