\ Стек строк в виде посл-сти символов, где элементы разделяются нулём

REQUIRE /TEST ~profit/lib/testing.f
REQUIRE ZPLACE ~nn/lib/az.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE { lib/ext/locals.f
REQUIRE (: ~yz/lib/inline.f

CREATE str-stack 0 , 1000 ALLOT
str-stack VALUE str-top


: S@ ( -- addr u ) str-top ASCIIZ> ;
: SUNDROP ( -- ) S@ + 1+ TO str-top ;
: >S ( addr u -- ) SUNDROP  str-top ZPLACE ;
: SEMPTY ( -- ) str-top str-stack - 3 < ;
: SDROP ( -- ) str-top 1- BEGIN 1- DUP C@ 0= UNTIL 1+ TO str-top ;
: S> ( -- addr u ) S@ SDROP ;

: S-TYPE str-stack 1+
BEGIN DUP str-top > 0= WHILE
ASCIIZ> 2DUP TYPE SPACE + 1+
REPEAT DROP ;



: IS-THERE ( addr u -- f )
str-top >R
BEGIN
SEMPTY 0= WHILE
2DUP S> COMPARE-U 0= IF R> TO str-top 2DROP TRUE EXIT THEN
REPEAT
2DROP FALSE  R> TO str-top
;

/TEST
CR S-TYPE
S" first" >S
S" second" >S
S" third" >S
S@ TYPE CR
S" thisecondr" IS-THERE .
S" second" IS-THERE .
CR S-TYPE