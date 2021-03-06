REQUIRE ZPLACE ~nn/lib/az.f
REQUIRE MODULE: ~nn/lib/spf4/spf_modules.f

MODULE: TEMP-MEMORY

32 VALUE #BUFFERS
USER BUFFERS
USER CUR-BUFFER
: ?INIT
    BUFFERS @ 0=
    IF #BUFFERS CELLS ALLOCATE THROW BUFFERS !
        CUR-BUFFER 0!
    THEN
;
EXPORT
: TEMP-ALLOC ( u -- a)
    ?INIT
    BUFFERS @ CUR-BUFFER @ CELLS + DUP @ ?DUP IF FREE DROP THEN
    SWAP ALLOCATE THROW DUP ROT !
    CUR-BUFFER @ 1+ #BUFFERS MOD CUR-BUFFER !
;

: S>ZTEMP ( a u - a1)
    DUP 1+ TEMP-ALLOC ( a u a1)
    DUP >R ZPLACE R>
;
: S>TEMP ( a u - a1 u)
    DUP >R S>ZTEMP R>
;
;MODULE

REQUIRE \EOF ~nn/lib/eof.f
\EOF
\ test
: test
    20 2 DO I DUP . 3 0 DO DUP * LOOP S>D <# #S #> S>TEMP 2DUP . . TYPE CR LOOP
    CR CR
    [ ALSO TEMP-MEMORY ]
    BUFFERS @ #BUFFERS CELLS OVER + SWAP ?DO I @ ASCIIZ> TYPE CR CELL +LOOP
    [ PREVIOUS ]
;

test
BYE