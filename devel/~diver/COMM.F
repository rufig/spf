\  работа с  последовательным портом под ¬индовс

\ константы ¬индовс
-2147483648 CONSTANT GENERIC_READ
1073741824 CONSTANT GENERIC_WRITE

\ внутренние переменные
0 VALUE handle
VARIABLE WasRead
VARIABLE ReadBuffer
\ ф-ии ¬индовс

WINAPI: TransmitCommChar KERNEL32.DLL \ ( char handle -- ior )
WINAPI: SetCommTimeouts KERNEL32.DLL
WINAPI: GetCommTimeouts KERNEL32.DLL
WINAPI: BuildCommDCBA KERNEL32.DLL
WINAPI: SetCommState KERNEL32.DLL
WINAPI: GetCommState KERNEL32.DLL
WINAPI: WaitCommEvent KERNEL32.DLL
WINAPI: SetCommMask KERNEL32.DLL

0
CELL -- Internal
CELL -- InternalHigh
CELL -- Offset
CELL -- OffsetHigh
CELL -- hEvent
CONSTANT OVELAPPED
HERE DUP >R OVELAPPED DUP ALLOT ERASE VALUE overlap
VARIABLE Event

0   
CELL -- ReadIntervalTimeout
CELL -- ReadTotalTimeoutMultiplier
CELL -- ReadTotalTimeoutConstant
CELL -- WriteTotalTimeoutMultiplier
CELL -- WriteTotalTimeoutConstant
CONSTANT COMMTIMEOUTS
 
HERE DUP COMMTIMEOUTS DUP ALLOT ERASE VALUE CommTimeouts

0
CELL -- DCBlength           \ sizeof(DCB) 
CELL -- BaudRate            \ current baud rate 
CELL -- Mode
(   биты слова Mode
    ^-- fBinary:1            \ 1 - binary mode, no EOF check 
    ^-- fParity:1            \ 0 - enable parity checking 
    ^-- fOutxCtsFlow:1       \ 0 - CTS output flow control 
    ^-- fOutxDsrFlow:1       \ 0 - DSR output flow control 
    ^-- fDtrControl:2        \ 00 - DTR flow control type 
    ^-- fDsrSensitivity:1    \ 0 - DSR sensitivity 
    ^-- fTXContinueOnXoff:1  \ 0 - XOFF continues Tx 
    ^-- fOutX:1              \ 0 - XON/XOFF out flow control 
    ^-- fInX:1               \ 0 - XON/XOFF in flow control 
    ^-- fErrorChar:1         \ 0 - enable error replacement 
    ^-- fNull:1              \ 0 - enable null stripping 
    ^-- fRtsControl:2        \ 00 - RTS flow control 
    ^-- fAbortOnError:1      \ 0 - abort reads/writes on error 
    ^-- fDummy2:17           \ reserved 
)
2 -- wReserved            \ not currently used 
2 -- XonLim               \ transmit XON threshold 
2 -- XoffLim              \ transmit XOFF threshold 
1 -- ByteSize             \ number of bits/byte, 4-8 
1 -- Parity               \ 0-4=no,odd,even,mark,space 
1 -- StopBits             \ 0,1,2 = 1, 1.5, 2 
1 -- XonChar              \ Tx and Rx XON character 
1 -- XoffChar             \ Tx and Rx XOFF character 
1 -- ErrorChar            \ error replacement character 
1 -- EofChar              \ end of input character 
1 -- EvtChar              \ received event character 
2 -- wReserved1           \ reserved; do not use 
CONSTANT DCB

HERE DUP >R DCB DUP ALLOT ERASE VALUE MyDCB

: WaitComm overlap Event handle WaitCommEvent DROP Event @ ." Event" . ;

: CommOpen ( addr n -- -1|handle ) \ for example string "com1" or "com2"
DROP >R
0 0 OPEN_EXISTING 0 0 GENERIC_READ GENERIC_WRITE OR R> CreateFileA
DUP -1 = IF DROP 0 ELSE TO handle -1 THEN
;
: CommClose ( -- ior )
handle CloseHandle
;
\ передача символа в открытый порт
: CommOut ( char -- ) \ worked maybe :-)
handle TransmitCommChar DROP ;

\ прием символа из порта
: CommIn ( -- char ) \ WaitComm
0 WasRead 1 ReadBuffer handle ReadFile DROP ReadBuffer C@ ;

\ прием нескольких байт в выбранный буфер
: ReadFromComm' ( addr n -- )
SP@ 0 \ ( addr n &n 0 ) -> ( 0 &N N ADDR )
 SWAP 2SWAP SWAP
 handle ReadFile ." [" . ." ]"
;
: ReadFromComm ( addr n -- )
OVER + SWAP ?DO
CommIn I C!
LOOP
;
: ReadFromPriz ( addr n -- )
OVER + SWAP ?DO
CommIn 0x63 AND I C!
LOOP
;

: pause 1000 0 ?DO 5555 7777 * DROP LOOP ;

: WriteToComm ( addr n -- )
OVER + SWAP ?DO
I C@ CommOut ( pause ) 1 PAUSE
LOOP
;
: Timeouts ( ms -- flag ) \ установка интервалов ожидани€ дл€ чтени€/записи в порт
10 CommTimeouts ReadIntervalTimeout !
1 CommTimeouts ReadTotalTimeoutMultiplier !
 CommTimeouts ReadTotalTimeoutConstant !
100 CommTimeouts WriteTotalTimeoutMultiplier !
1 CommTimeouts WriteTotalTimeoutConstant !
CommTimeouts handle SetCommTimeouts 
;
: CommInit ( -- ior ) \ первоначальна€ инициализаци€ порта
DCB MyDCB DCBlength !
MyDCB handle GetCommState DROP
9600 MyDCB BaudRate ! 
0x80000000 MyDCB Mode !
8 MyDCB ByteSize C!
2 MyDCB StopBits C!
1 MyDCB Parity C!
MyDCB handle SetCommState 
; 
: SetComm ( BaudRate ByteSize StopBits Parity -- ior )
\ настройка порта
 MyDCB Parity C!
 MyDCB StopBits C!
 MyDCB ByteSize C!
 MyDCB BaudRate !
 MyDCB handle SetCommState 0 <>
;
\ choose port
: COM1 ( -- flag ) S" COM1" CommOpen DUP IF CommInit 1000 Timeouts 2DROP THEN ;
: COM2 ( -- flag ) S" COM2" CommOpen DUP IF CommInit 1000 Timeouts 2DROP THEN ;

\ тестовые слова
: TEST 0 ?DO I CommOut LOOP ;
