REQUIRE STR@ ~ac/lib/str5.f
REQUIRE 2VALUE ~ygrek/lib/2value.f
REQUIRE /GIVE ~ygrek/lib/parse.f

: FILE! ( text-au file-au -- )
   R/W CREATE-FILE THROW >R
   R@ WRITE-FILE THROW
   R> CLOSE-FILE THROW ;

0 VALUE str

: DESCRIPTION 
    str STR@ DUP 8 - /GIVE 2SWAP S" .docbook" COMPARE 
    IF CR ." Expected .docbook extension" 2DROP S" " EXIT THEN
    " {s}.more" STR@ FILE ;

: DESCRIBE ( a u -- )
   " {s}" TO str
   str STR@ EVAL-FILE
   str STR@ FILE! ;
