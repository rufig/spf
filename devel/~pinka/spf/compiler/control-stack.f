\ 2006, 2007

REQUIRE Require     ~pinka/lib/ext/requ.f
REQUIRE [UNDEFINED] lib/include/tools.f
REQUIRE NDROP       ~pinka/lib/ext/common.f

[UNDEFINED] CELL-! [IF]
: CELL-! -1 CELLS SWAP +! ; [THEN]

[UNDEFINED] CELL+! [IF]
: CELL+!  1 CELLS SWAP +! ; [THEN]


MODULE: ControlStackSupport

256 CELLS CONSTANT /Z

USER ZP
USER Z0
USER Z9

: close ( -- )
  Z0 @ 0= IF EXIT THEN
  Z0 @ FREE THROW
  Z0 0! ZP 0!
;
: open ( -- )
  close
  /Z ALLOCATE THROW DUP Z9 !
  /Z + DUP Z0 ! ZP !
;

S" ~pinka/samples/2006/model/zstack.immutable.f" INCLUDED

EXPORT

: CSCLEAR ( -- ) Z0 @ IF Z0 @ ZP! EXIT THEN open ;

: ?CSP ( -- )
  Z0 @ 0= IF open EXIT THEN
  ZP@ Z0 @ U> ABORT" Control stack undeflow"
  ZP@ Z9 @ U< ABORT" Control stack overflow"
;

( 
`Z@ `CS@  aka
`>Z `gtCS aka
`>Z `>CS  aka 
`Z> `CSgt aka
`Z> `CS>  aka 
)
: CS@   Z@ ;
: >CS   >Z ;
: CS>   Z> ;
: CSDROP ZDROP ;

: gtCS  >Z ;
: CSgt  Z> ;

\ : .CS .Z ;
;MODULE