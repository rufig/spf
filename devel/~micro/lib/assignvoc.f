: AssignVocDoes
	ALSO DUP @ EXECUTE
	CELL+ @ STATE @ IF
		COMPILE,
	ELSE
		EXECUTE
	THEN
	NextWord SFIND ?DUP IF
		STATE @ = IF
			COMPILE,
		ELSE
			EXECUTE
		THEN
	ELSE
		1 ABORT" not found"
	THEN
	PREVIOUS
;

: WordVoc
	CREATE SMUDGE
	' , ['] NOOP ,
	SMUDGE IMMEDIATE
DOES> AssignVocDoes ;

: AssignVoc
	CREATE SMUDGE
	' ' , ,
	SMUDGE IMMEDIATE
DOES> AssignVocDoes ;

\EOF

WordVoc voc:: voc
AssignVoc obj:: obj voc

CR :NONAME 111 voc:: method ; EXECUTE
CR 222 voc:: method
CR :NONAME 333 TO obj obj:: method ; EXECUTE
CR :NONAME obj:: method ; EXECUTE
CR obj:: method
CR 444 TO obj obj:: method
CR obj:: method
CR :NONAME obj:: method ; EXECUTE

: o:: POSTPONE obj:: ; IMMEDIATE
: v:: POSTPONE voc:: ; IMMEDIATE

CR :NONAME 555 v:: method ; EXECUTE
CR 666 v:: method
CR :NONAME 777 TO obj o:: method ; EXECUTE
CR :NONAME o:: method ; EXECUTE
CR o:: method
CR 888 TO obj o:: method
CR o:: method
CR :NONAME o:: method ; EXECUTE
