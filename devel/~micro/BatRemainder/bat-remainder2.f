S" bat-remainder.f" INCLUDED

0 VALUE ScriptBaseDEPTH

: ?S ( i*x n -- i*x f )
\ n аргументов должно быть
\ f=TRUE если не так
    ScriptBaseDEPTH +
    DEPTH 1- <>
;

MODULE: Interface

: GP
	3 ?S ABORT" Wrong date"
	GP ;

: event:
	3 ?S ABORT" Wrong date"
	event: ;

: Agent
	0 ?S ABORT" No need parameters"
	Agent ;

: \ POSTPONE \ ;

;MODULE

:NONAME
	GET-ORDER
	ONLY Interface
	DEPTH TO ScriptBaseDEPTH
	S" events" INCLUDED
	DEPTH ScriptBaseDEPTH <> ABORT" Command missed"
	SET-ORDER
	S" event-coming-soon.txt" R/W CREATE-FILE THROW TO H-STDOUT
	.dl
	H-STDOUT CLOSE-FILE THROW
	ForAgentToo IF
    	S" event-coming-soon-agent.txt" R/W CREATE-FILE THROW TO H-STDOUT
    	ShowStrs
    	.dl
    	H-STDOUT CLOSE-FILE THROW
	THEN
	BYE
; MAINX !
TRUE TO ?GUI

\ S" Compiled specially for Sinius" S",

S" bat-remainder.exe" SAVE
BYE
