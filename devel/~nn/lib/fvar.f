\ File variables
REQUIRE FILE ~nn/lib/subst1.f
REQUIRE get-string ~nn/lib/getstr.f
REQUIRE S+ ~nn/lib/az.f
REQUIRE FWRITE ~nn/lib/file.f

VARIABLE fVAR-PATH HERE 1+ C" var\" ", 0 C,  fVAR-PATH ! \ "
USER ufVAR-PATH
: FileVarPath! S>ZALLOC fVAR-PATH ! ;
: uFileVarPath! S>ZALLOC ufVAR-PATH ! ;

: fVAR-PATH@ ufVAR-PATH @ ?DUP 0= IF fVAR-PATH @ THEN ASCIIZ> ;
: fVAR-FILENAME ( a -- a1 u1) @ COUNT fVAR-PATH@ 2SWAP S+ ;
:NONAME \ _TOfVAR-CODE
    R> CFL CELL+ - fVAR-FILENAME OVER >R FWRITE
    R> FREE DROP ;

: fVAR
  CREATE LATEST-NAME NAME>CSTRING ,
  LITERAL ( _TOfVAR-CODE) COMPILE,
  DOES>
    fVAR-FILENAME OVER >R 2DUP EXIST?
    IF
        FILE
    ELSE
        2DROP S" "
    THEN
    R> FREE DROP
   ;

\EOF 
fVAR test1
fVAR test2
fVAR test3

S" hello1" TO test1
S" hello2" TO test2
S" hello3" TO test3
test1 TYPE CR
test2 TYPE CR
