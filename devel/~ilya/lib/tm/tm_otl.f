\ FileName: tm_otl.f
\ Библиотека для работы по RS232 (сервисный разъём) с УТМ Телеканал-М/М2
\ Абдрахимов И.А
\
\ v 1.4 02.02.2005г.
\ ! Изменены слова tmRead, tmWrite. В этих словах реализовано ожидание сигналов CTS,DSR
\ + В слова tmRead, tmWrite добавлены векторное слово vtmModemStatus
\ v 1.5 от 22.11.2005г.
\ ! закомментировано PurgeRcv в слове tmWrite
[UNDEFINED] ZMOVE [IF]
S" ~yz/lib/common.f" INCLUDED
[THEN]
[UNDEFINED] init->> [IF] 
S" ~yz/lib/data.f" INCLUDED
[THEN]

S" ~ilya\lib\tm\tm_com.f" INCLUDED
VECT vtmP
VECT vtmRUN
VECT vtmError
VECT vtmTRS
VECT vtmTrmRedy
VECT vtmSTRIN
VECT vFLPROG
VECT vtmModemStatus
VECT ESC-OTVET

: _vtmP DROP ;

' _vtmP TO vtmP
' NOOP TO vtmRUN
' NOOP TO vtmError
' NOOP TO vtmTRS
' NOOP TO vtmTrmRedy
' NOOP TO vtmSTRIN
' NOOP TO vFLPROG
' NOOP TO vtmModemStatus

5 CONSTANT ReadRep	\ Кол-во повторных попыток чтения при неудаче
VARIABLE _TEMP

: Wait_CTS { \ n --}
	0 TO n
	BEGIN
	SIG ModemStatus   CR ." modem=" SIG @  .H CR ." n=" n .
	\ vtmModemStatus
	 SIG @ 0x10 AND n 1+ DUP TO n 1000 = OR
	 
	UNTIL

;
: tmWrite  ( n -- )
	TO cbs 
\	CR ." == WRITE =="
\ PurgeRcv
	 SETDTR com-handle EscapeCommFunction DROP 
	COM-WRITE \ -OVER 
	 CLRDTR com-handle EscapeCommFunction DROP
	\ EV_DSR EV_CTS OR SETCOMMMASK
	\ WAITCOMMEVENT
;

: tmWrite_Buf { adr n \ n1 -- }
	esc-buf >R adr TO esc-buf
	 n 512 /MOD 
	0 ?DO
	512 tmWrite
	esc-buf 512 + TO esc-buf
	n1 512 + TO n1 512 vtmP
	LOOP
	DUP vtmP
	tmWrite
	\ 0 IF
	\ n 0 ?DO
	\ 1 tmWrite
	\ esc-buf 1+ TO esc-buf
	
	\ LOOP
	\ THEN
	R> TO esc-buf
;

: tmRead ( n -- )
	
	\ SETRTS com-handle EscapeCommFunction DROP
	\ rcv-buf SWAP Com-Read
	\ EV_RXCHAR EV_DSR OR SETCOMMMASK CR ." Wait !!!"
	\ CR ." == READ =="
	
	\ WAITCOMMEVENT CR ." com_event=" com_event @ .H CR
	\ PurgeRcv
	
	COM-READ \ -OVER 
	
	\ CLRRTS com-handle EscapeCommFunction DROP
;
0 [IF]
: _tmRead { n  --} 
rcv-buf 10 ERASE
ReadRep
BEGIN
n _tmRead
1- DUP 0=
cbr n = OR
UNTIL
DROP
;
[THEN]
: tmG >R \ { adr n -- }	
	27 esc-buf C!
	[CHAR] G esc-buf 1+ C!
	\ adr 
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
	R@ esc-buf  W!
	 50 PAUSE
	\ WAITCOMMEVENT
	\ EV_CTS EV_DSR OR 
	2 tmWrite
	\ PurgeRcv
	R> tmRead
	
;

: tmP  ( adr1 adr n -- )
\ Где adr1 - адрес в УТМ
\ adr - укзатель на буфер с данными
\ n- кол-во байт передаваемой информации
{ adr n -- }	
	27 esc-buf C!
	[CHAR] P esc-buf 1+ C!
	\ adr 
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
	n esc-buf  W!
	\ SIG ModemStatus SIG @ .H
	 50 PAUSE
	
	 WAITCOMMEVENT
	
	2 tmWrite 
	50 PAUSE
	esc-buf >R adr TO esc-buf
	0 IF
	n 0 DO
	1 tmWrite
	esc-buf 1+ TO esc-buf
	I vtmP
	LOOP
	THEN
	n tmWrite
	R> TO esc-buf
	\ PurgeRcv
;

: tmP_byte  ( adr1 adr n -- )
\ Где adr1 - адрес в УТМ
\ adr - укзатель на буфер с данными
\ n- кол-во байт передаваемой информации
{ adr n -- }	
	27 esc-buf C!
	[CHAR] P esc-buf 1+ C!
	\ adr 
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
	n esc-buf  W!
	\ SIG ModemStatus SIG @ .H
	 50 PAUSE
	
	 WAITCOMMEVENT
	
	2 tmWrite 
	50 PAUSE
	esc-buf >R adr TO esc-buf
	n 0 DO
	1 tmWrite
	esc-buf 1+ TO esc-buf
	I vtmP
	LOOP
	R> TO esc-buf
	\ PurgeRcv
;

\ Получить сетевой номер УТМ
: tmL 
	27 esc-buf C!  
	[CHAR] L esc-buf 1+ C!
	0 esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite 
	\ 100 PAUSE
	\ PurgeRcv
	\ WAITCOMMEVENT
	6 tmRead 
	\ 6 COM-READ 
;

\ Выдать из УТМ данные (1 байт)
\ по адресу adr
: tmI ( adr -- )
	27 esc-buf C!
	[CHAR] I esc-buf 1+ C!
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
	\ PurgeRcv
	0 rcv-buf !
	WAITCOMMEVENT
	1 tmRead
;

\ Вывести в УТМ 1-ин байт 
\ где adr - адрес в УТМ
\ n - значение (байт)
: tmO SWAP 
	\ rcv-buf rcvBufSize ERASE
	27 esc-buf C!
	[CHAR] O esc-buf 1+ C!
\	adr
	esc-buf 2 + W!
\	n 
	esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;

\ 
\ ВЫДAТЬ ДAННЫЕ ИЗ ПОРТA 
: tmY ( adr -- )
	27 esc-buf C!
	[CHAR] Y esc-buf 1+ C!
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
	\ PurgeRcv
	1 tmRead
;

\ 
\  ПОМЕСТИТЬ ДAННЫЕ В ПОРТ
: tmX ( adr n -- )
	SWAP
	27 esc-buf C!
	[CHAR] X esc-buf 1+ C!
	esc-buf 2 + W!
	esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;

\ Запросить данные данные по таблицам
\
: tmT 
	
	27 esc-buf C!
	[CHAR] T esc-buf 1+ C!
	0 esc-buf 2 + W!
	\ n 
	esc-buf 4 + C!
	13 esc-buf 5 + C!
	
	\ SETDTR com-handle EscapeCommFunction
	\ BEGIN
	\ SIG com-handle GetCommModemStatus DROP
	\ SIG @ MS_CTS_ON AND
	\ UNTIL 
	
	6 tmWrite
	\ CLRDTR com-handle EscapeCommFunction
	\ SETRTS com-handle EscapeCommFunction
	\ 100 PAUSE  
	\ BEGIN
	\ sc DUP . 1+ TO sc 
	\ SIG com-handle GetCommModemStatus DROP
	\ SIG @ MS_DSR_ON AND SIG @ .
	\ UNTIL
	\
	\ PurgeRcv
	\ WAITCOMMEVENT
	WAITCOMMEVENT
	4 tmRead
	\ LPCOMSTAT SIGerr com-handle ClearCommError ." ERR=" .S IF  ELSE -1 THROW THEN
	\ LPCOMSTAT cbInQue @ CR ." in=" . 
	\ LPCOMSTAT @ CR  ." fCtsHold=" .
	\ SIG com-handle GetCommMask DROP
	\ SIG @ CR ." mask=" .
	\ SPACE ." RcvErr=" SIGerr @ .
	\ CLRRTS com-handle EscapeCommFunction
	
;

\ ПОВТОР ПОСЛЕДНЕЙ ПЕРЕДАННОЙ ESC ПОСЛЕДОВАТЕЛЬНОСТИ

: tmREPCOM
	27 esc-buf C!
	[CHAR] E esc-buf 1+ C!
	0 esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;

\ Ощибка "Команда не распознаётся"
: tmError
vtmError
;

\ Принять от УТМ текстовую строку
: tmTRS
\ EV_DSR SETCOMMMASK
\ WAITCOMMEVENT
 rcv-buf 2 + W@ 
\ DUP

tmRead 
\ ." Nado=" . ." Prinyato=" cbr . 
\ rcv-buf SWAP CR DUMP
\ rcv-buf SWAP  TYPE
 vtmTRS

\ rcv-buf cbr TYPE

\ rcv-buf cbr + DUP >R 2- C@ 0xD = R> 1- C@ 0xA = AND IF CR ." CRLT" CR ELSE CR ." CR" CR rcv-buf cbr DUMP THEN
;

\ Принять от компьютера 6 байт: CBEDLH
: tmSTRIN 
vtmSTRIN 
DUP C@ esc-buf C!
DUP 1+ C@ esc-buf 1+ C!
DUP 2 + C@ esc-buf 2 + C!
DUP 3 + C@ esc-buf 3 + C!
DUP 4 + C@ esc-buf 4 + C!
5 + C@ esc-buf 5 + C!
\ esc-buf 10 DUMP
6 tmWrite
;

: tmTrmRedy
vtmTrmRedy
esc-buf C!
\ SIG ModemStatus SIG @ MS_CTS_ON	= IF CR ." CTS OK !" THEN
1 tmWrite
;

: tmRead_2 { \ n -- }
rcv-buf init->>
rcv-buf TO n
_TEMP TO rcv-buf
BEGIN
1 tmRead
CR ." Stack=" .S ." end !" CR 
DUP \ cbr AND 
WHILE
_TEMP C@ C>>
1-
REPEAT
DROP
n TO rcv-buf
;

: tmTerminalCikl 
\ CR ."  Cickl !!!"
\ CLS
	\ EV_RXCHAR EV_DSR OR SETCOMMMASK
	BEGIN
	 \ WAITCOMMEVENT
	\ WAITCOMMEVENT
	\ 6 tmRead_1 \ 
\	 rcv-buf 6 ERASE
\ EV_RXCHAR 
\ EV_DSR SETCOMMMASK
\ WAITCOMMEVENT

	6 tmRead
	\ 6 tmRead \ cbr CR ." cbr=" . \ 
	\ 1 10 AT-XY  rcv-buf cbr DUMP
	rcv-buf 1+ C@ DUP >R
	CASE
		[CHAR] E OF ( tmError) ENDOF
		[CHAR] ? OF tmTrmRedy ENDOF
		[CHAR] Q OF tmSTRIN  ENDOF
		[CHAR] s OF tmTRS  ENDOF
		[CHAR] S OF tmTRS  ENDOF
		[CHAR] q OF  ENDOF
	\ tmREPCOM \ 
	0 esc-buf C!
	1 tmWrite
	SetCommBreak 100 PAUSE ClearCommBreak
	
	ENDCASE
	R> [CHAR] q =
	 \ 5 PAUSE
	UNTIL
;
\ Стартовать программу по DE
: tmRUN	( adr -- )
	27 esc-buf C!
	[CHAR] R esc-buf 1+ C!
	esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
\	EV_DSR SETCOMMMASK
\	WAITCOMMEVENT
\	6 tmRead
\ rcv-buf 1+ C@ [CHAR] q = IF vtmRUN THEN
\	tmTerminalCikl
;

\ ВОЗВРАТ В ПРОГРАММУ ВЫСШЕГО УРОВНЯ
: tmRETURN
	27 esc-buf C!
	[CHAR] U esc-buf 1+ C!
	0 esc-buf 2 + W!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;

: tmR
	27 esc-buf C!
	4 esc-buf 1+ C!
	0 esc-buf 2 + C!
	[CHAR] R esc-buf 3 + C!
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	SETDTR com-handle EscapeCommFunction DROP
	COM-WRITE
	CLRDTR com-handle EscapeCommFunction DROP
	PurgeRcv
	6 1000 * COM-READ 
;
\ Подготовка ТУ
\ Где: adr - сетевой адрес (номер 1...255) КП на котором производится ТУ
\ tip - команда ( 1 - включить, 2 - отключить )
\ n - номер ТУ
\ Результат: при ior=FALSE, cod - ответа по подготовке ТУ, при ior=FALSE - не удалось принять данные
: tmTUp { adr tip n -- }	( adr tip n -- cod ior=FALSE / ior=TRUE )
	rcv-buf rcvBufSize ERASE
	27 esc-buf C!
	[CHAR] p esc-buf 1+ C!
	n esc-buf 2 + C!
	tip esc-buf 3 + C!
	adr esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 TO cbs
	SETDTR com-handle EscapeCommFunction DROP
	COM-WRITE
	CLRDTR com-handle EscapeCommFunction DROP
60 0	DO
			PurgeRcv 6 COM-READ
			cbr 6 = 	IF
							rcv-buf 1+ C@ [CHAR] t =	\ Если получен ответ от процессов ТУ
							IF
								LEAVE			
							THEN
						THEN
		\ 100 PAUSE
		LOOP
	rcv-buf 4 + C@				\ То выдать код ответа по операции ТУ
	DUP IF FALSE	ELSE DROP TRUE THEN						\ Флаг чтения данных
	;

\ Выполнение ТУ
\ Где: adr - сетевой адрес (номер 1...255) КП на котором производится ТУ
\ tip - команда ( 1 - включить, 2 - отключить )
\ n - номер ТУ
\ Результат: при ior=FALSE, cod - ответа по выполнению ТУ, при ior=FALSE - не удалось принять данные
: tmTUe { adr tip n -- }
	rcv-buf rcvBufSize ERASE
	27 esc-buf C!
	[CHAR] e esc-buf 1+ C!
	n esc-buf 2 + C!
	tip esc-buf 3 + C!
	adr esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 TO cbs
	SETDTR com-handle EscapeCommFunction DROP
	COM-WRITE
	CLRDTR com-handle EscapeCommFunction DROP
60 0	DO
			PurgeRcv 6 COM-READ
			cbr 6 = 	IF
							rcv-buf 1+ C@ [CHAR] t =	\ Если получен ответ от процессов ТУ
							IF
								LEAVE
							THEN
						THEN
	\ 100 PAUSE
LOOP
	rcv-buf 4 + C@				\ То выдать код ответа по операции ТУ
	DUP IF FALSE	ELSE DROP TRUE THEN						\ Флаг чтения данных
;

\ Отмена выполнения ТУ
\ Где: adr - сетевой адрес (номер 1...255) КП на котором производится ТУ
\ tip - команда ( 1 - включить, 2 - отключить )
\ n - номер ТУ
\ Результат: при ior=FALSE, cod - ответа по выполнению ТУ, при ior=FALSE - не удалось принять данные
: tmTUc { adr tip n -- }
	rcv-buf rcvBufSize ERASE
	27 esc-buf C!
	[CHAR] c esc-buf 1+ C!
	n esc-buf 2 + C!
	tip esc-buf 3 + C!
	adr esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 TO cbs
	SETDTR com-handle EscapeCommFunction DROP
	COM-WRITE
	CLRDTR com-handle EscapeCommFunction DROP
60 0	DO
			PurgeRcv 6 COM-READ 
			cbr 6 = 	IF
							rcv-buf 1+ C@ [CHAR] t =	\ Если получен ответ от процессов ТУ
							IF
								LEAVE			
							THEN
						THEN
		\ 100 PAUSE
		LOOP
	rcv-buf 4 + C@				\ То выдать код ответа по операции ТУ
	DUP IF FALSE	ELSE DROP TRUE THEN						\ Флаг чтения данных
	;
	
\ Свойства
0
1 -- NumChanOut
1 -- NumChanReg
1 -- ValueProp
1 -- ValueApert
CELL -- ValueTime
CONSTANT /PROPSIZE




\    ФОРМAТ КОМAНДЫ:     ESC, IDCOM, PAR_E, PAR_D, PAR_A, CR
\
\    ESC    -  МAРКЕР НAЧAЛA "ИСКЕЙП" ПОСЛЕДОВAТЕЛЬНОСТИ (БAЙТ 27)
\    IDCOM  -  ЛИТЕРA - ИДЕНТИФИКAТОР КОММAНДЫ
\    PAR_E  -  ПAРAМЕТР ПЕРЕДAВAЕМЫЙ НA ИСПОЛНЕНИЕ В РЕГИСТРЕ E
\    PAR_D  -                                                 D
\    PAR_A  -                                                 A
\    CR     -  МAРКЕР КОНЦA "ИСКЕЙП" ПОСЛЕДОВAТЕЛЬНОСТИ (БAЙТ 13)

: ESC-OTVETcon
rcv-buf 1+ C@ 
		CASE
			[CHAR] j OF CR S" Слишком большой блок !!!" DROP .ansiz ENDOF
			[CHAR] d OF CR S" Шина не захвачена !" DROP .ansiz ENDOF
			[CHAR] B OF CR S" Шина захвачена !" DROP .ansiz ENDOF
			[CHAR] E OF CR S" Начинаю приём !" DROP .ansiz ENDOF
			[CHAR] M OF CR S" Хорошее CRC !" DROP .ansiz ENDOF
			[CHAR] m OF CR S" Плохое CRC !" DROP .ansiz ENDOF
			[CHAR] p OF CR S" Не удалось запрограммировать Flash !" DROP .ansiz ENDOF
			[CHAR] P OF CR S" Flash успешно запрограммирована !" DROP .ansiz ENDOF
		ENDCASE	
;
' ESC-OTVETcon TO ESC-OTVET
: FLPROG ( a de fbu fsz-- ) { fbu1 fsz1 -- }
\ Прошиваем Flash
\ de - размер файла
\ a - CRC
\ EV_DSR

esc-buf init->>
27 C>> [CHAR] F C>> W>> C>> 13 C>>
\ CR esc-buf 10 DUMP CR
6 tmWrite
WAITCOMMEVENT \ com_event @  CR ." ev=" .
6 tmRead
\ CR rcv-buf 20 DUMP
ESC-OTVET
\ EV_CTS 

WAITCOMMEVENT
\ com_event @ 	CASE
\			EV_DSR OF ." DSR !!!" CR ENDOF
\			EV_CTS OF ." CTS !!!" CR ENDOF
\	ENDCASE
\	com_event @  CR ." ev=" .
	\ 5200 PAUSE	
6 tmRead
ESC-OTVET
 esc-buf >R \ TO n
 fbu1 TO esc-buf
\ EV_CTS SETCOMMMASK
\ WAITCOMMEVENT com_event @  CR ." ev=" .
\ EV_CTS SETCOMMMASK
 fsz1 0 DO 
 1 tmWrite
 I vFLPROG
 esc-buf 1+ TO esc-buf
 LOOP
\ fbu1 fsz1 com-handle WRITE-FILE ." err=" .S CR THROW 
 R> TO esc-buf

\ WAITCOMMEVENT
WAITCOMMEVENT
6 tmRead
ESC-OTVET


\ WAITCOMMEVENT

EV_RXCHAR SETCOMMMASK
\ 5000 PAUSE
BEGIN
WAITCOMMEVENT
\ PurgeRcv
\ 6 tmRead
\ WAITCOMMEVENT
6 tmRead
cbr
UNTIL
ESC-OTVET
EV_RXCHAR EV_DSR OR EV_CTS OR SETCOMMMASK
;

\ Слова для программирования процессора
: Blok_prg ( crc adr -- )
	27 esc-buf C!
	[CHAR] F esc-buf 1+ C!
	\ adr 
	esc-buf 2 + W!
	\ crc8 
	esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;

: Blok_prg_Stop 
	27 esc-buf C!
	[CHAR] f esc-buf 1+ C!
	\ adr 
	0 esc-buf 2 + W!
	\ crc8 
	0 esc-buf 4 + C!
	13 esc-buf 5 + C!
	6 tmWrite
;


:  tmGetConfig
esc-buf init->>
27 C>> [CHAR] R C>> [CHAR] R C>> 0 W>> 13 C>>
6 tmWrite
10 tmRead
;

: tmGetHIP
esc-buf init->>
27 C>> 12 C>> 0x1F C>> 0 C>> 0x4D C>> 13 C>>
6 tmWrite
;


\ Работа с HIP-ами

: CHIPZap { hip par -- }
esc-buf init->>
27 C>> hip 4 + C>> par C>> 0 C>> 0 C>> 13 C>>
6 tmWrite
2 tmRead
;

\ принять  из HIP массив
: InHIPDim { hip par l -- }
esc-buf init->>
27 C>> hip 0x18 + C>> par C>> 0 C>> l C>> 13 C>>
6 tmWrite
par 2* tmRead

;
\ Передать безответную ESC последовательность
: CHIPOut { lit hip b -- }
esc-buf init->>
27 C>> hip C>> b W>> lit C>> 13 C>>
\ esc-buf CR 10 DUMP
6 tmWrite
;
\


\EOF
: tmGet
 BEGIN
 fltmGet -state@  IF	
	

	sz rcvBufSize <
	IF
		st sz tmG
		cbr n2zs ctlKolByteRcv set-text
	THEN
	5000 PAUSE
	THEN
 AGAIN
 ;
 
 
 
