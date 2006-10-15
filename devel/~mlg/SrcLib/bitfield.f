REQUIRE DEFER ~mlg/SrcLib/compat.f

\ bitfield.fth
\ Accessing (reading from and writing to) bit fields in a cell
\ (c) M.L.Gassanenko
\ If you find a bug, please, report to mlg@forth.org (Michael Gassanenko)
\ Note: this package is not an ANS program
\ Работа с битовыми полями
\ (c) М.Л.Гасаненко 

\ ===========================================================================
\ These words work with exactly as many bits as you specify.
\ These words are written for portability and reusability.
\ Comma in number literals is just ignored in my Forth.
\ On Intel processors -2 = $ffff,fffe and my code uses it.

\ The two most important words are:
\ 	x.mask:= ( x bits mask -- y )	- write to specified bits
\	x.mask	 ( x mask -- bits )	- read specified bits

\ Example (in HEX):
\ 1234578 F0F00F x.mask .
\ 248  ok
\ 1234578 ABC F0F00F x.mask:= .
\ 1a3b57c  ok

\ --- Level 1: shifts and rotations -----------------------------------------
\ >ROR>  ( x -- y ) rotate bits right
\ >SHR>  ( x -- y ) shift bits right
\ <SHL<  ( x -- y ) shift bits left
\ D<SHL< ( x -- yl yh ) shift bits left
\ <ROL<  ( x -- y ) rotate bits left

\ --- Level 2: auxiliary words ----------------------------------------------
\ x+m0 ( x mask -- x' elem ) replace non-zero bits in mask by bits from x
\ 			     producing elem; x' contains remaining bits
\ x+m ( x mask -- elem ) replace non-zero bits in mask by bits from x 
\ 			 producing elem
\ x/m0 ( x' y mask -- x ) extract the bits from y masked by mask;
\ 			  append them to x'


\ --- Level 3: reading from and writing to bit fields -----------------------
\ x.mask:= ( x field mask -- y ) replace bits specified by mask in x by field,
\                                producing y
\ x.mask ( x mask -- field ) field consists of bits taken from x,
\ 			     as specified by mask

\ ===========================================================================
: >ROR> ( x -- x' )     \ rotate bits right
	DUP 2/ SWAP  1 AND	IF
	$8000,0000 OR		ELSE
	$7FFF,FFFF AND		THEN
;
: >SHR> ( x -- x' )     \ shift bits right
	2/ $7FFF,FFFF AND
;
: <SHL<  ( x -- y )	2* $FFFF,FFFF AND ;
: D<SHL< ( x -- yl yh ) DUP <SHL< SWAP $8000,0000 AND 0<> 1 AND ;
: <ROL<  ( x -- y )	D<SHL< OR ;

\ replace non-zero bits in mask by bits from x producing elem;
\ x' contains remaining bits
: x+m0 ( x mask -- x' elem )
	DUP						IF
	32 0					DO
	DUP 1 AND			IF
	 OVER 1 AND 0=		IF
	  -2 AND		THEN
	 SWAP >SHR> SWAP		THEN
	>ROR>					LOOP	THEN
;
: x+m ( x mask -- elem )
	x+m0  OVER				IF
	 CR SWAP U. U.
	 1 ABORT" more bits than in the mask"   ELSE
	 NIP					THEN
;

: x.mask:= ( x field mask -- x.mask:=field )
	TUCK x+m >R INVERT AND R> OR
;

\ extract the bits from opc-elem masked by mask; append them to x'
: x/m0 ( x' opc-elem mask -- x )
      DUP							IF
	32 0						DO
	  D<SHL<				IF
	    -ROT ( m x o )
	    D<SHL< ROT <SHL< OR SWAP ROT	ELSE
	    SWAP <SHL< SWAP			THEN	LOOP	ELSE
	-ROT							THEN
      2DROP
;
: x.mask ( x mask -- x' )
  0 -ROT x/m0
;

