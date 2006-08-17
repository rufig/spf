: IsLineComment ( addr u -- f )
\ return true if string began with "//"
	2 < IF
		DROP
		FALSE
	ELSE
		W@ [ CHAR / DUP 8 LSHIFT + ] LITERAL =
	THEN ;

MODULE: h-language

: #define
	CREATE
	0 PARSE
	DEPTH >R
	EVALUATE
	DEPTH R> - DUP -1 = IF
		DROP
		,
	ELSE
		-2 <> ABORT" More then one value to #define"
		1 ,
	THEN
DOES>
	@ ;

: \*
   BEGIN
     BEGIN
       NextWord DUP
     WHILE
       S" *\" COMPARE 0= IF EXIT THEN
     REPEAT
     2DROP
     REFILL 0=
   UNTIL
;

: #else
	1
	BEGIN
		NextWord DUP
		IF  
			2DUP S" #ifdef" COMPARE 0= >R
			2DUP S" #ifndef" COMPARE 0= R> OR
			IF
				2DROP 1+
			ELSE
				2DUP S" #else" COMPARE
				0= IF
					2DROP 1-
					DUP IF
						1+
					THEN
				ELSE 
					S" #endif" COMPARE
					0= IF
						1-
					THEN
				THEN
			THEN
		ELSE
			2DROP REFILL  AND
		THEN
	DUP 0= UNTIL
	DROP ;

: #ifdef
	NextWord SFIND 0=
	IF
		2DROP [COMPILE] #else
	ELSE
		DROP
	THEN ;
: #ifndef
	NextWord SFIND
	IF
		DROP [COMPILE] #else
	ELSE
		2DROP
	THEN ;

: #endif ;

: NOTFOUND ( addr u -- )
	2DUP 2>R ['] NOTFOUND CATCH ?DUP
	IF
  		NIP NIP
  		2R> IsLineComment IF
			DROP
  			0 PARSE 2DROP
		ELSE
			THROW
		THEN
	ELSE
		2R> 2DROP
	THEN
;

;MODULE

: LOAD-H ( addr u -- )
	2>R
	GET-ORDER
	ONLY h-language
	DEPTH
	2R>
	ROT >R
	INCLUDED
	DEPTH R> - ABORT" Stack error while loading .h"
	SET-ORDER ;
