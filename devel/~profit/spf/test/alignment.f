REQUIRE TESTCASES ~ygrek/lib/testcase.f

\ Проверка на выровненность структур данных,
\ порождаемых словами:
\ CREATE , VARIABLE , VALUE , USER , USER-VALUE

TESTCASES data cell alignment
WARNING @  WARNING 0!

0
ALIGN DUP ALLOT
(( CREATE c
c            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( VARIABLE t
t            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( 0 VALUE v
' v >BODY    ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER u
u            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER-VALUE uv
' uv >BODY @ ALIGN-BYTES @ MOD -> 0 ))

DROP

1
ALIGN DUP ALLOT
(( CREATE c
c            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( VARIABLE t
t            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( 0 VALUE v
' v >BODY    ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER u
u            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER-VALUE uv
' uv >BODY @ ALIGN-BYTES @ MOD -> 0 ))

DROP

2
ALIGN DUP ALLOT
(( CREATE c
c            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( VARIABLE t
t            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( 0 VALUE v
' v >BODY    ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER u
u            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER-VALUE uv
' uv >BODY @ ALIGN-BYTES @ MOD -> 0 ))

DROP

3
ALIGN DUP ALLOT
(( CREATE c
c            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( VARIABLE t
t            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( 0 VALUE v
' v >BODY    ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER u
u            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER-VALUE uv
' uv >BODY @ ALIGN-BYTES @ MOD -> 0 ))

DROP

5
ALIGN DUP ALLOT
(( CREATE c
c            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( VARIABLE t
t            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( 0 VALUE v
' v >BODY    ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER u
u            ALIGN-BYTES @ MOD -> 0 ))

ALIGN DUP ALLOT
(( USER-VALUE uv
' uv >BODY @ ALIGN-BYTES @ MOD -> 0 ))

DROP

\ шесть достаточно?..

WARNING !
END-TESTCASES