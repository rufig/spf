\
\ File Name: tm_stend.f
\ Ðàáîòà ÷åðåç COM ñî ñòåíäîì MS-1
\ Àáäðàõèìîâ È.À.
\ v 0.1	îò 28.12.2004ã.
\
\

[UNDEFINED] tmG [IF]
S" ~ilya/lib/tm/tm_otl.f" INCLUDED
[THEN]

[UNDEFINED] init->> [IF] 
S" ~yz/lib/data.f" INCLUDED
[THEN]


\    ÔÎÐÌAÒ ÊÎÌAÍÄÛ:     ESC, IDCOM, PAR_E, PAR_D, PAR_A, CR
\
\    ESC    -  ÌAÐÊÅÐ ÍA×AËA "ÈÑÊÅÉÏ" ÏÎÑËÅÄÎÂAÒÅËÜÍÎÑÒÈ (ÁAÉÒ 27)
\    IDCOM  -  ËÈÒÅÐA - ÈÄÅÍÒÈÔÈÊAÒÎÐ ÊÎÌÌAÍÄÛ
\    PAR_E  -  ÏAÐAÌÅÒÐ ÏÅÐÅÄAÂAÅÌÛÉ ÍA ÈÑÏÎËÍÅÍÈÅ Â ÐÅÃÈÑÒÐÅ E
\    PAR_D  -                                                 D
\    PAR_A  -                                                 A
\    CR     -  ÌAÐÊÅÐ ÊÎÍÖA "ÈÑÊÅÉÏ" ÏÎÑËÅÄÎÂAÒÅËÜÍÎÑÒÈ (ÁAÉÒ 13)

: ESC-OTVET
rcv-buf 1+ C@ 
		CASE
			[CHAR] j OF CR S" Ñëèøêîì áîëüøîé áëîê !!!" DROP .ansiz ENDOF
			[CHAR] d OF CR S" Øèíà íå çàõâà÷åíà !" DROP .ansiz ENDOF
			[CHAR] B OF CR S" Øèíà çàõâà÷åíà !" DROP .ansiz ENDOF
			[CHAR] E OF CR S" Íà÷èíàþ ïðè¸ì !" DROP .ansiz ENDOF
			[CHAR] M OF CR S" Õîðîøåå CRC !" DROP .ansiz ENDOF
			[CHAR] m OF CR S" Ïëîõîå CRC !" DROP .ansiz ENDOF
			[CHAR] p OF CR S" Íå óäàëîñü çàïðîãðàììèðîâàòü Flash !" DROP .ansiz ENDOF
			[CHAR] P OF CR S" Flash óñïåøíî çàïðîãðàììèðîâàíà !" DROP .ansiz ENDOF
		ENDCASE	
;

: FLPROG ( a de fbu fsz-- ) { fbu1 fsz1 -- }
\ Ïðîøèâàåì Flash
\ de - ðàçìåð ôàéëà
\ a - CRC
\ EV_DSR
EV_CTS SETCOMMMASK
esc-buf init->>
27 C>> [CHAR] F C>> W>> C>> 13 C>>
CR esc-buf 10 DUMP CR
6 tmWrite
WAITCOMMEVENT com_event @  CR ." ev=" .
6 tmRead
CR rcv-buf 20 DUMP
ESC-OTVET
\ EV_CTS 
EV_DSR SETCOMMMASK
WAITCOMMEVENT
com_event @ 	CASE
			EV_DSR OF ." DSR !!!" CR ENDOF
			EV_CTS OF ." CTS !!!" CR ENDOF
	ENDCASE
	com_event @  CR ." ev=" .
	\ 5200 PAUSE	
6 tmRead
ESC-OTVET
 esc-buf >R \ TO n
 fbu1 TO esc-buf
\ EV_CTS SETCOMMMASK
\ WAITCOMMEVENT com_event @  CR ." ev=" .
\ EV_CTS SETCOMMMASK
CR ." Before Write OK !!!" 
 fsz1 0 DO 
 1 tmWrite
 esc-buf 1+ TO esc-buf
 LOOP
\ fbu1 fsz1 com-handle WRITE-FILE ." err=" .S CR THROW 
CR ." Write OK !!!" 
 R> TO esc-buf
EV_DSR SETCOMMMASK
WAITCOMMEVENT
6 tmRead
ESC-OTVET

EV_DSR SETCOMMMASK
WAITCOMMEVENT

EV_DSR SETCOMMMASK
WAITCOMMEVENT
6 tmRead
ESC-OTVET
;