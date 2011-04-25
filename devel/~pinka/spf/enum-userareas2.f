REQUIRE ENUM-HEAPS-FORTH  ~pinka/spf/enum-heaps-forth.f

: (ENUM-USERAREAS) ( xt heap -- xt ) \ xt ( addr -- )
  HEAP-USERAREA DUP 0= IF DROP EXIT THEN
  SWAP DUP >R EXECUTE R>
;
: ENUM-USERAREAS ( xt -- ) \ xt ( addr -- )
  ['] (ENUM-USERAREAS) ENUM-HEAPS-FORTH
  ( xt ) DROP
;

\EOF

  ' . ENUM-USERAREAS
