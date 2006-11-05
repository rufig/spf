REQUIRE [IF] lib/include/tools.f
REQUIRE /STRING lib/include/string.f 
REQUIRE .TIME ~nn/lib/time.f

S" SPForthProject" ENVIRONMENT?
[IF]
    S" debug" COMPARE 0=  VALUE DEBUG?
[ELSE]
    TRUE VALUE DEBUG?
[THEN]
DEBUG? [IF] .( Make for debugging) [ELSE] .( Make release) [THEN] CR

DEBUG?
[IF]
    : DBG( [CHAR] ) POSTPONE .TIME WORD COUNT >R PAD R@ CMOVE PAD R> EVALUATE ; IMMEDIATE
[ELSE]
    : DBG( [CHAR] ) WORD DROP ; IMMEDIATE
[THEN]

