\ Вспомогательные слова для работы с УТМ
[UNDEFINED] TIME&DATE [IF]
S" lib\include\facil.f" INCLUDED
[THEN]
[UNDEFINED] { [IF]
S" lib\ext\locals.f" INCLUDED
[THEN]
MODULE: TMLIB
USER crc
CREATE MON-LENGTH1 31 C, 28 C, 31 C, 30 C, 31 C, 30 C,
CREATE MON-LENGTH2 31 C, 31 C, 30 C, 31 C, 30 C, 31 C,

EXPORT
\ Считаем CRC (8 бит)
\ где: 	adr - адрес начала буфера с данными
\			n - количество байт для подсчёта
\			c - код CRC
: CRC ( adr n -- c )
crc 0!
OVER + SWAP 
 ?DO I C@ crc +! ( @ + crc C!)  LOOP crc C@ ;

\ Переводим число n (байт) из двоично-десятичного представления в десятичное
: HEX>DEC ( n -- n )
DUP 0xF AND >R
4 RSHIFT
10 * R> +
;

: DEC>HEX ( n -- n ) 10 /MOD 4 LSHIFT OR ;

10 CONSTANT mSEK
100 CONSTANT SEK
SEK 60 * CONSTANT MINU
MINU 60 * CONSTANT CHAS
CHAS 24 * CONSTANT DEN
DEN 30 * CONSTANT MES

   \ 0xBE14EF6F CONSTANT T1	\ 12:04 (16:04) 29.10.04
 0xBFA27044 CONSTANT T1	\ 16:35 (13:35) 01.11.04
  \ 0xAE17DB6E CONSTANT T1
0x7FFFFFFF CONSTANT TMASK
0x80000000 CONSTANT TTRUEMASK

0 VALUE tMes
0 VALUE tDen
0 VALUE tChas
0 VALUE tMin
0 VALUE tSek
0 VALUE tmSek
0 VALUE tTrue	\ Часы идут
TRUE VALUE GMT		\ Если 1, то час +3
TRUE VALUE tekDate	\ Расчёт по текущему времени TRUE - да, FALSE - нет

: ?Високосный
  4 MOD 0=
;

: (CTS>TIME) { n \ x  -- }
0 TO tMes
DUP TTRUEMASK AND IF TRUE TO tTrue ELSE FALSE TO tTrue THEN \ Проверяем флаг достоверности
TMASK AND 
TO x 
x DEN / tTrue IF 1+ THEN TO tDen
x CHAS / x DEN / 24 * - GMT  tTrue AND IF 3 + ELSE  THEN TO tChas
x MINU / x CHAS / 60 * - TO tMin
x SEK / x MINU / 60 * - TO tSek
x x SEK / 100 * - TO tmSek

BEGIN
	\ tDen  DUP CR ." ==" . n C@  DUP . \ 2DUP > >R 2DUP  = R> OR CR ." fl=" .S CR
	tTrue IF tMes 1+ TO tMes THEN
	n C@ tDen  < 
WHILE	
tDen n C@
- TO tDen 	
	
	n 1+ TO n
REPEAT
;

\ Пересчитываем время (4 байта) выраженное в десятках милисекунд
\ в числовые значения
: CTS>TIME
tekDate IF SYSTEMTIME GetLocalTime DROP THEN	\ 

	SYSTEMTIME wYear W@ ?Високосный  IF  29 ELSE 28 THEN MON-LENGTH1 1+ C!
	SYSTEMTIME wMonth W@ 6 >
IF
MON-LENGTH2 (CTS>TIME)
	tTrue IF tMes 6 + TO tMes THEN
ELSE
MON-LENGTH1 (CTS>TIME)
THEN
;

: (TIME>CTS) { n -- }
1- 0 SWAP 0 ?DO n I + C@	+ LOOP
DEN * 
SYSTEMTIME wDay W@  1- DEN * +
SYSTEMTIME wHour W@ GMT IF 3 - THEN CHAS * +
SYSTEMTIME wMinute W@ MINU * +
SYSTEMTIME wSecond W@ SEK * +
SYSTEMTIME wMilliseconds W@ 10 / +
TTRUEMASK OR
;

\ Формируем время выраженное в десятках милисекунд
\ в 4-ех байтное значение
: TIME>CTS ( -- n )
	SYSTEMTIME wMonth W@ DUP 6 >
	IF
		6 - MON-LENGTH2 (TIME>CTS)
	ELSE
		MON-LENGTH1 (TIME>CTS)
	THEN
;

: TIME>CTS1 SYSTEMTIME GetLocalTime DROP TIME>CTS ;

;MODULE

\EOF
\ 31110 
\ 31000 -

\ 0xCE81D2C9
\ T1
\ 3000000
\ 0xBE14EF6F
  \ DEN 184 * TTRUEMASK XOR
 \ CTS>TIME
\ 0x266
\    0xD64AADA2
\    0xD64AADB2 
0xDAC9CD8E
0xDAC9D0F0
    2DUP > [IF] .( +) [ELSE] .( -) [THEN]
    -  ABS
1 [IF]
 HEX
\ TIME>CTS1 DUP U.
\ 1 PAUSE
\ TIME>CTS1 DUP U.
\ SWAP -
\ T1
DECIMAL
CTS>TIME
CR tDen . .( .) tMes . SPACE tChas . .( :) tMin . .( .) tSek . tmSek .( -) .
\ TIME>CTS1 DUP U.
\ T1
\ DECIMAL
\ CTS>TIME
[THEN]
CR tDen . .( .) tMes . SPACE tChas . .( :) tMin . .( .) tSek . tmSek .( -) .