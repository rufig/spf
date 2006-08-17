: NEXT-WORD ( -- addr u | 0 )
  BEGIN
    NextWord DUP 0=
  WHILE
    2DROP
    REFILL 0= IF 0 EXIT THEN
  REPEAT
;

: SkipSrcToWord ( addr u -- )
	BEGIN
		NEXT-WORD DUP 0= ABORT" Unexpected end of file"
		2OVER COMPARE 0=
	UNTIL
	2DROP
;
