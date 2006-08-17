REQUIRE InVoc{ ~ac/lib/transl/vocab.f

: >> ALSO ; IMMEDIATE
: << PREVIOUS ; IMMEDIATE

: InVoc{>
  >IN @
  NextWord SFIND ABORT" Can't IMMEDIATE already creted vocabulary"
  2DROP
  >IN !
  InVoc{ IMMEDIATE
;

