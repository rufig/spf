\ 2006, 2007
\ $Id$

REQUIRE lexicon.basics-aligned ~pinka/lib/ext/basics.f

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

S" ~pinka/samples/2004/test/zstack/zstack.immutable.f" INCLUDED

EXPORT

: CSCLEAR ( -- ) Z0 @ IF Z0 @ ZP! EXIT THEN open ;

: ?CSP ( -- )
  Z0 @ 0= IF open EXIT THEN
  ZP@ Z0 @ U> ABORT" Control stack undeflow"
  ZP@ Z9 @ U< IF -52 THROW THEN \ Control stack overflow
;

..: AT-THREAD-STARTING ?CSP ;.. ?CSP

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
\ no control for overflow (!)

: 2>CS SWAP >CS >CS ;
: 2CS> CS> CS> SWAP ;

\ : .CS .Z ;
;MODULE