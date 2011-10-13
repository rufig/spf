: (VOCS) ( n1 wid -- n2 )
  VOC-NAME. SPACE 1+
;
: VOCS ( -- )
  0 ['] (VOCS) ENUM-VOCS-FORTH
  CR ." Vocs: " . CR
;


: (FOR-VOC-CHILD-FORTH) ( xt wid wid2 -- xt wid  )
  2DUP PAR@ <> IF DROP EXIT THEN
  SWAP >R SWAP DUP >R EXECUTE R> R>
;
: FOR-VOC-CHILD-FORTH ( wid|0 xt -- )  \ xt ( i*x wid2 -- j*x )
  SWAP ['] (FOR-VOC-CHILD-FORTH) ENUM-VOCS-FORTH 2DROP
;


: (VOCS-TREE) ( n wid -- n )
  [ HERE ( GERM ) ]
  OVER SPACES DUP VOC-NAME. CR  ( n wid )
  OVER 2 + SWAP ( n n2 wid )
  [ ( xt ) LIT, ] FOR-VOC-CHILD-FORTH DROP
;

: VOCS-TREE ( -- )
  2 0 ['] (VOCS-TREE) FOR-VOC-CHILD-FORTH DROP
;

\ среди словарей на одном уровне вложенности вначале выводятся созданные позже
\ see:
\   forthml VOCS-TREE BYE
