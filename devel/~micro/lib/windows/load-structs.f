REQUIRE STRUCT: lib\ext\struct.f

: CreatePropertyName ( addr u c -- )
	<#
		HOLD
		HOLDS
		S" CREATE " HOLDS
	0. #> EVALUATE ;

: CreatePropertyName-! ( addr u -- )
	[CHAR] ! CreatePropertyName ;

: CreatePropertyName-@ ( addr u -- )
	[CHAR] @ CreatePropertyName ;

: CreateField ( n addr u -- )
	BL CreatePropertyName IMMEDIATE ,
DOES>
	STATE @ IF
		@ POSTPONE LITERAL
		POSTPONE +
	ELSE
		@ +
	THEN ;

: CreateProperty ( xt n addr u c -- )
	CreatePropertyName IMMEDIATE , ,
DOES> ( i*x base body )
	STATE @ IF
		SWAP OVER @ POSTPONE LITERAL
		POSTPONE + ( i*x body base+n )
		SWAP CELL+ @ ( i*x base+n xt )
		COMPILE,
	ELSE
		SWAP OVER @ + ( i*x body base+n )
		SWAP CELL+ @ ( i*x base+n xt )
		EXECUTE
	THEN ;

: propfield: ( n xt-! xt-@ "name" )
	ROT NextWord ( xt-! xt-@ n addr u )
	0 2OVER 2OVER ( xt-! xt-@ n addr u 0 n addr u 0 )
	2>R 2>R ( xt-! xt-@ n addr u 0 R: n addr u 0 )
	2OVER 2OVER 2>R 2>R ( xt-! xt-@ n addr u 0 R: n addr u 0 n addr u 0 )
	DROP CreateField
	2R> 2R> DROP ( xt-! xt-@ n addr u R: n addr u 0 )
	[CHAR] @ CreateProperty
	2R> 2R> DROP ( xt-! n addr u )
	[CHAR] ! CreateProperty
;

: Carr@ ( i base -- value )
	+ C@ ;
: Warr@ ( i base -- value )
	SWAP 2* + W@ ;
: arr@ ( i base -- value )
	SWAP 4 * + @ ;
: 2arr@ ( i base -- value )
	SWAP 8 * + 2@ ;

: Carr! ( value i base -- )
	+ C! ;
: Warr! ( value i base -- ) 
	SWAP 2* + W! ;
: arr! ( value i base -- )
	SWAP 4 * + ! ;
: 2arr! ( value i base -- )
	SWAP 8 * + 2! ;

S" ~micro/lib/windows/lh1.f" INCLUDED
400 1024 * TO HIGH-SIZE
S" ~micro/lib/windows/structs.f" LH-INCLUDED

ALSO WINSTRUCTS

\EOF

CREATE r RECT::/SIZE ALLOT
: .r {{ RECT r left@ . r top@ . r right@ . r bottom@ . }} ;
: >r {{ RECT r bottom! r right! r top! r left! }} ;
12 34 56 78 >r
.r
S" w.exe" SAVE
