\ File Name: tm_com.f
\ Работа через COM с телемеханикой "ТЕЛЕКАНАЛ"
\ Абдрахимов И.А.
\ v 0.7	от 29.09.2004г.
\ v 0.8	от 07.10.2004г.
\ + В tmTUp и tmTUe добавлены флаги успешного чтения данных
\ v 0.9 от 05.01.2005г. 
\ + Добавлены слова SETCOMMMASK и WAITCOMMEVENT
\ v 1.0 от 16.11.2005г.
\ ! Изменения в словах COM-WRITE вместо THROW стоит DROP
\ 	COM-READ-L вместо THROW стоит IF DROP 0 TO cbr ELSE TO cbr THEN
\ v 1.1 от 22.11.2005г.
\ ! Изменение в слове COM-WRITE вместо DROP поставил IF PurgeTrs THEN, т.е 
\ очищаю буфер передачи при ошибке записи
S" ~ilya\lib\winmodem.f" INCLUDED

WINAPI: CreateEventA KERNEL32.DLL 
WINAPI: WaitForSingleObject KERNEL32.DLL 
WINAPI: GetOverlappedResult KERNEL32.DLL 
VARIABLE CBR
0 VALUE _brk-com-read	\ Флаг об прекращении ожидания в слове COM-READ-NL 
VARIABLE MASK

: SETCOMMMASK ( mask -- ) com-handle SetCommMask DROP ;
: WAITCOMMEVENT 0  com_event com-handle WaitCommEvent DROP ;
: GETCOMMMASK  MASK com-handle GetCommMask DROP MASK @ ;

0
    WORD1  wPacketLength       \ packet size, in bytes 
    WORD1  wPacketVersion      \ packet version 
    DWORD dwServiceMask       \ services implemented 
    DWORD dwReserved1         \ reserved 
    DWORD dwMaxTxQueue        \ max Tx bufsize, in bytes 
    DWORD dwMaxRxQueue        \ max Rx bufsize, in bytes 
    DWORD dwMaxBaud           \ max baud rate, in bps 
    DWORD dwProvSubType       \ specific provider type 

    DWORD dwProvCapabilities  \ capabilities supported 
    DWORD dwSettableParams    \ changable parameters 
    DWORD dwSettableBaud      \ allowable baud rates 
    WORD1  wSettableData       \ allowable byte sizes 
    WORD1  wSettableStopParity \ stop bits/parity allowed 
    DWORD dwCurrentTxQueue    \ Tx buffer size, in bytes 
    DWORD dwCurrentRxQueue    \ Rx buffer size, in bytes 
    DWORD dwProvSpec1         \ provider-specific data 
    DWORD dwProvSpec2         \ provider-specific data 

    1 -- wcProvChar       \ provider-specific data 
     CONSTANT _COMMPROP 
 CREATE COMMPROP _COMMPROP ALLOT


: PurgeRcv
\ PURGE_TXCLEAR com-handle PurgeComm
PURGE_RXCLEAR com-handle PurgeComm DROP
;
: PurgeTrs
PURGE_TXCLEAR com-handle PurgeComm DROP
\ PURGE_RXCLEAR com-handle PurgeComm DROP
;


\ прием символа из порта
: CommIn ( -- char ) \ WaitComm
\ SETRTS com-handle EscapeCommFunction DROP
\ WAITCOMMEVENT
ComReadBuffer 1 com-handle  READ-FILE THROW  ComReadBuffer C@
\ CLRRTS com-handle EscapeCommFunction DROP
;

	
: Com-Read \ { addr n  -- }
0 TO cbr
 \ EV_RLSD ( EV_CTS OR ) SETCOMMMASK
 OVER + SWAP ?DO
CommIn I C! DROP
cbr 1+ TO cbr
\ 30 10 AT-XY ." I=" I .
LOOP

;
: OPEN-FILE-OVER ( c-addr u fam -- fileid ior ) \ 94 FILE
\ Открыть файл с именем, заданным строкой c-addr u, с методом доступа fam.
\ Смысл значения fam определен реализацией.
\ Если файл успешно открыт, ior ноль, fileid его идентификатор, и файл
\ позиционирован на начало.
\ Иначе ior - определенный реализацией код результата ввода/вывода,
\ и fileid неопределен.


  NIP SWAP >R >R
  0 FILE_FLAG_OVERLAPPED
  OPEN_EXISTING
  0 ( secur )
  0 ( share )  
  R> ( access=fam )
  R> ( filename )
  CreateFileA DUP -1 = IF GetLastError ELSE 0 THEN
  CR ." Open OK" .S CR
;
: READ-FILE-OVER ( c-addr u1 fileid -- u2 ior ) \ 94 FILE
\ Прочесть u1 символов в c-addr из текущей позиции файла,
\ идентифицируемого fileid.
\ Если u1 символов прочитано без исключений, ior ноль и u2 равен u1.
\ Если конец файла достигнут до прочтения u1 символов, ior ноль
\ и u2 - количество реально прочитанных символов.
\ Если операция производится когда значение, возвращаемое
\ FILE-POSITION равно значению, возвращаемому FILE-SIZE для файла
\ идентифицируемого fileid, ior и u2 нули.
\ Если возникла исключительная ситуация, то ior - определенный реализацией
\ код результата ввода/вывода, и u2 - количество нормально переданных в
\ c-addr символов.
\ Неопределенная ситуация возникает, если операция выполняется, когда
\ значение, возвращаемое FILE-POSITION больше чем значение, возвращаемое
\ FILE-SIZE для файла, идентифицируемого fileid, или требуемая операция
\ пытается прочесть незаписанную часть файла.
\ После завершения операции FILE-POSITION возвратит следующую позицию
\ в файле после последнего прочитанного символа.
S" com-event" DROP 0 0 0 CreateEventA
overlap hEvent !
  >R 2>R
overlap lpNumberOfBytesRead R> R> R@ 
  ReadFile CR ." Read=>" CR .S CR  ERR
  0xFFFF overlap hEvent @ WaitForSingleObject .
  \ lpNumberOfBytesRead @ SWAP
  TRUE CBR overlap R> GetOverlappedResult CR ." Rez=" .
  CBR @ FALSE
;

: WRITE-FILE-OVER ( c-addr u fileid -- ior ) \ 94 FILE
\ Записать u символов из c-addr в файл, идентифицируемый fileid,
\ в текущую позицию.
\ ior - определенный реализацией код результата ввода-вывода.
\ После завершения операции FILE-POSITION возвращает следующую
\ позицию в файле за последним записанным в файл символом, и
\ FILE-SIZE возвращает значение большее или равное значению,
\ возвращаемому FILE-POSITION.
 \ OVER >R
  >R 2>R
S" com-event" DROP 0 0 0 CreateEventA
overlap hEvent !

overlap lpNumberOfBytesWritten R> R> R> DUP ." hand=" .
  WriteFile CR DUP . ." write=>" .lerr ERR ( ior )
   0xFFFF overlap hEvent @ WaitForSingleObject .
   FALSE
   CR ." After write" .S ." <=" CR
  \ ?DUP IF RDROP EXIT THEN
  \ lpNumberOfBytesWritten @ R> <>
  ( если записалось не столько, сколько требовалось, то тоже ошибка )
;

\ Открыть СОМ порт
: COM-OPEN ( cadr cn -- )
R/W OPEN-FILE THROW TO com-handle
;
\ Открыть СОМ порт
: COM-OPEN-OVER ( cadr cn -- )
R/W OPEN-FILE-OVER THROW TO com-handle
;
: COM-CLOSE
	com-handle CLOSE-FILE THROW
	\ esc-buf-size 0= IF ELSE esc-buf FREEMEM THEN
;

\ Записать в СОМ порт n - байт начиная с адреса adr
: COM-WRITE ( adr n -- ior )
\ DROP
EV_RXCHAR EV_TXEMPTY OR SETCOMMMASK
esc-buf cbs com-handle WRITE-FILE  IF PurgeTrs THEN 
10000 0 DO
\ 1 PAUSE
GETCOMMMASK EV_TXEMPTY AND
IF LEAVE THEN
LOOP
;

\ Записать в СОМ порт n - байт начиная с адреса adr
: COM-WRITE-OVER ( adr n -- ior )
esc-buf cbs com-handle WRITE-FILE-OVER  THROW 
;

\ Прочитать из СОМ порта n - байт по адресу adr
\ с тайм-аутом
: COM-READ-L	{ n -- } ( n -- ior )
\ EV_RXCHAR SETCOMMMASK
EV_RXCHAR EV_TXEMPTY OR SETCOMMMASK
\ S" com-event" DROP 0 0 0 CreateEventA DROP
\ GetTickCount
\ WAITCOMMEVENT GetTickCount SWAP - CR ." com_event=" com_event @ . .
10000 0 DO
\ 1 PAUSE
GETCOMMMASK EV_RXCHAR AND
IF LEAVE THEN
LOOP
10000
BEGIN
\ 1 PAUSE
CLEARCOMMERROR
\ LPCOMSTAT fBinState @ CR ." fBinState=" .H
LPCOMSTAT  cbInQue @ \ DUP  ." cbInQue=" .   \ DUP CR n . ." cbInQue=" . CR
n 1- >  SWAP 1- SWAP OVER 0= OR
UNTIL
DROP
rcv-buf
n com-handle  READ-FILE  IF  DROP 0 TO cbr ELSE TO cbr THEN 
;

\ Прочитать из СОМ порта n - байт по адресу adr
\ без тайм-аута
: COM-READ-NL	{ n -- } ( n -- ior )
0 TO _brk-com-read
BEGIN
\ 1 PAUSE
CLEARCOMMERROR
\ LPCOMSTAT fBinState @ CR ." fBinState=" .H
LPCOMSTAT  cbInQue @  \ DUP CR n . ." cbInQue=" . CR
n 1- > _brk-com-read OR
UNTIL
rcv-buf
n com-handle  READ-FILE THROW TO cbr
;

VECT COM-READ
' COM-READ-L TO COM-READ

\ Прочитать из СОМ порта n - байт по адресу adr
: COM-READ-OVER	( n -- ior )
rcv-buf SWAP 
com-handle  READ-FILE-OVER CR ." st=" .S THROW TO cbr
;

: COM-INIT1 { sp -- }
	( S" COM1") COM-OPEN
	200 com-handle SetTimeOut THROW
	( 38400) sp 8 2 0 com-handle SetModemParameters THROW
	
;

: ModemStatus ( adr -- )
com-handle GetCommModemStatus 0= IF 1 THROW THEN
;



: PurgeSnd
( PURGE_RXCLEAR) PURGE_TXABORT	 com-handle PurgeComm DROP
;
: SetCommBreak com-handle SetCommBreak DROP ;
: ClearCommBreak com-handle ClearCommBreak DROP ;
