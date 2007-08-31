\ Nov.2006, Jan.2007

: BIND-NODE ( node list -- ) \  | link | (pointer to node is this addr) ... |
  2DUP @ ( node list node node-o )
  SWAP CELL- ! !
;
: UNBIND-NODE ( list -- node )
  DUP @ DUP 0= IF NIP EXIT THEN  ( list node )
  TUCK CELL- @ SWAP !
;
: CDR-BY-VALUE ( x node1 -- x node2|0 )
  BEGIN DUP WHILE 2DUP @ <> WHILE CELL- @ REPEAT THEN
;
: FIND-NODE ( x list -- node true | false )
  @ CDR-BY-VALUE NIP DUP IF TRUE THEN
;
: FIND-LIST ( x list -- sub-list true | false )
  SWAP >R DUP @  BEGIN DUP WHILE ( list node )
  DUP @ R@ = IF DROP RDROP TRUE EXIT THEN NIP CELL- DUP @ REPEAT RDROP NIP ( false )
;
: FOREACH-LIST-NODE ( xt list -- )  \ xt ( node -- )
  @ BEGIN DUP WHILE 2DUP 2>R SWAP EXECUTE 2R> CELL- @ REPEAT 2DROP
;
: FOREACH-LIST-VALUE ( xt list -- )  \ xt ( node -- )
  @ BEGIN DUP WHILE 2DUP 2>R @ SWAP EXECUTE 2R> CELL- @ REPEAT 2DROP
;

\ : CDR ( node1 -- node|0 ) CELL- @ ;
\ : CAR @ ;

: BIND-NODE-TAIL ( node list -- )
  DUP @ 0= IF ! EXIT THEN
  0 ['] NIP ROT FOREACH-LIST-NODE ( node tail-node )
  CELL- !
;
