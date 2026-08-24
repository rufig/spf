: (VOCS) ( n1 wid -- n2 )
  VOC-NAME. SPACE 1+
;
: VOCS ( -- )
  0 ['] (VOCS) ENUM-VOCS-FORTH
  CR ." Vocs: " . CR
;


: (FOR-VOC-CHILD-FORTH) ( any1 xt1[ any1 wid1 -- any2 ] x.parent[wid|0] wid1 -- any1|any2 xt1 x.parent )
  2DUP PAR@ <> IF DROP EXIT THEN
  SWAP >R SWAP DUP >R EXECUTE R> R>
;
: FOR-VOC-CHILD-FORTH ( any1 wid.parent|0 xt[ any1|any2 wid -- any2 ] -- any1|any2 )
  SWAP ['] (FOR-VOC-CHILD-FORTH) ENUM-VOCS-FORTH 2DROP
;


: (VOCS-TREE) ( n.indent wid.parent|0 -- n.indent )
  [ HERE ( xt.itself ) ]
  OVER SPACES DUP VOC-NAME. CR  ( n wid )
  OVER 2 + SWAP ( n n2 wid )
  [ ( xt.itself ) LIT, ] FOR-VOC-CHILD-FORTH DROP   \ TODO: use `GERM` once it is defined
;

: VOCS-TREE ( -- )
  2 0 ['] (VOCS-TREE) FOR-VOC-CHILD-FORTH DROP
;

\ среди словарей на одном уровне вложенности вначале выводятся созданные позже
\ see:
\   forthml VOCS-TREE BYE
