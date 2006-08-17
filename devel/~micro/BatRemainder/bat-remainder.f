S" ~micro\calendar\monthtable.f" INCLUDED
S" ~micro\lib\propis.f" INCLUDED

WINAPI: GetSystemTimeAsFileTime kernel32.dll
WINAPI: FileTimeToLocalFileTime kernel32.dll

: ftime-to-local ( ftime. -- ftime-local. )
	SWAP SP@ >R 0 0 SP@ R> FileTimeToLocalFileTime DROP
	SWAP 2SWAP 2DROP ;

: date-diff-as-ftime ( d m y -- ftime. )
	DMY>ftime
	0 0 SP@ GetSystemTimeAsFileTime DROP SWAP
	ftime-to-local
	DNEGATE	D+ ;

: days-left ( d m y -- days )
	date-diff-as-ftime
	2DUP 0. D< >R
	DABS 1000000000 UM/MOD NIP 864 /
	R> IF
		NEGATE
	ELSE
		1+
	THEN ;

VARIABLE min-left-days
0x7FFFFFFF min-left-days !
CREATE desc1A 80 ALLOT
VARIABLE desc1U
CREATE desc2A 80 ALLOT
VARIABLE desc2U
0 desc1U !

: SetEvent ( days-left desc1-a desc1-u desc2-a desc2-u -- )
	DUP desc2U !
	desc2A SWAP MOVE
	DUP desc1U !
	desc1A SWAP MOVE
	min-left-days ! ;

: ?update-min-left-days ( days-left desc1-a desc1-u desc2-a desc2-u -- )
	2>R 2>R
	DUP 0< IF
		DROP
		RDROP RDROP
		RDROP RDROP
	ELSE
		DUP min-left-days @ < IF
			2R> 2R> SetEvent
		ELSE
			DROP
			RDROP RDROP
			RDROP RDROP
		THEN
	THEN ;

: event: ( d m y "decs-¤®"|"desc-бҐЈ®¤­п"\n -- )
	days-left [CHAR] | PARSE 0 PARSE ?update-min-left-days
;

: GP ( d m y "ѓЏ-зҐЈ®"\n -- )
	days-left 0 PARSE
	<#
		HOLDS
		S" Гран-При " HOLDS
	0. #>
	2DUP ?update-min-left-days
;

ALSO Propis

: .dl
	desc1U @ 0= IF EXIT THEN
	min-left-days @ 1 > IF
		." До "
		desc1A desc1U @ TYPE
		SPACE
		min-left-days @
		DUP number-of
			S" осталось" nSTR
			S" остался" nSTR
			S" осталось" nSTR
			DROP
		TYPE
		SPACE
		DUP S>D male <# #trans 0. #> OEM>ANSI TYPE SPACE
		number-of
			S" дней" nSTR
			S" день" nSTR
			S" дня" nSTR
			DROP
		TYPE
	ELSE
		min-left-days @ IF
			." Завтра "
		ELSE
			." Сегодня "
		THEN
		desc2A desc2U @ TYPE
	THEN
;

PREVIOUS

FALSE VALUE ForAgentToo

VARIABLE AgentSignatureStart
VARIABLE AgentSignatureTail
0 AgentSignatureTail !

CREATE AgentSignatureA
CREATE AgentSignatureU
CREATE AgentSignatureMaxU

: StoreStr ( addr u )
	AgentSignatureTail @ ?DUP
	IF
		HERE SWAP !
	THEN
	HERE AgentSignatureTail !
	0 ,
	S",     \ "
;

: ShowStrs
	AgentSignatureStart @ ?DUP IF
		BEGIN
			DUP CELL+ COUNT TYPE CR
			@ DUP 0=
		UNTIL
		DROP
	THEN
;

: Agent
	TRUE TO ForAgentToo
	HERE AgentSignatureStart !
	BEGIN
		REFILL
	WHILE
		SOURCE StoreStr
	REPEAT
	\EOF
;

\EOF

:NONAME
	S" event-coming-soon.txt" R/W CREATE-FILE THROW TO H-STDOUT
	S" events" INCLUDED
	.dl
	H-STDOUT CLOSE-FILE THROW
	BYE
; MAINX !
TRUE TO ?GUI

\ S" Compiled specially for Sinius" S",

S" bat-remainder.exe" SAVE
BYE
