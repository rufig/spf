REQUIRE SCREATE ~nn/lib/sheader.f
REQUIRE get-string ~nn/lib/getstr.f
: PROP
    BL SKIP [CHAR] = PARSE SCREATE
    get-string DUP , HERE OVER ALLOT
    SWAP MOVE 0 C,
    DOES> DUP CELL+ SWAP @ ;


\EOF
PROP this-is-prop1="long property"
PROP this-is-prop2=short_property
PROP this-is-prop3='property in apostrophs'
: test
    this-is-prop1 TYPE CR
    this-is-prop2 TYPE CR
    this-is-prop3 TYPE CR
;
test
