WINAPI: fopen   MSVCRT.DLL
WINAPI: fgets   MSVCRT.DLL
WINAPI: ferror  MSVCRT.DLL
WINAPI: fclose  MSVCRT.DLL
WINAPI: _fdopen MSVCRT.DLL
WINAPI: gets    MSVCRT.DLL

: R/O S" r" DROP ;

: OPEN-FILE ( addr u mode -- file ior )
  NIP SWAP fopen NIP NIP
  DUP 0=
;
: chop ( addr -- u )
  ASCIIZ> 2DUP + 1- C@ 10 = IF 1- THEN NIP
;
: READ-LINE ( addr u file -- u2 flag ior )
  ROT ROT             ( file addr u )
  SWAP fgets          ( file u addr res )
  NIP NIP             ( file res )
  ?DUP IF NIP chop TRUE 0 EXIT THEN
  0 0 ROT ferror NIP
;
: CLOSE-FILE ( file -- ior )
  fclose NIP
;
: AsStream ( h mode -- file ior )
  SWAP _fdopen NIP NIP
  DUP 0=
;
: ACCEPT ( c-addr +n1 -- +n2 ) \ 94
\  H-STDIN READ-LINE THROW DROP
  DROP gets NIP
  ?DUP IF ASCIIZ> NIP ELSE -1 THROW THEN
;
: REFILL ( -- flag ) \ 94 FILE EXT
  CURSTR 1+!
  TIB C/L
  SOURCE-ID 0 > IF SOURCE-ID ( included text )
                   READ-LINE THROW ( ошибка чтения )
                   IF #TIB !
                   ELSE DROP FALSE EXIT THEN
                ELSE SOURCE-ID
                     IF 2DROP FALSE EXIT THEN ( evaluate string )
                     ACCEPT #TIB ! ( user input )
                THEN
  >IN 0! <PRE> -1
;
: MAIN1 ( -- )
  BEGIN
    REFILL
  WHILE
    INTERPRET OK
  REPEAT BYE
;
: QUIT ( -- ) ( R: i*x ) \ CORE 94
\ Сбросить стек возвратов, записать ноль в SOURCE-ID.
\ Установить стандартный входной поток и состояние интерпретации.
\ Не выводить сообщений. Повторять следующее:
\ - Принять строку из входного потока во входной буфер, обнулить >IN
\   и интепретировать.
\ - Вывести зависящее от реализации системное приглашение, если
\   система находится в состоянии интерпретации, все процессы завершены,
\   и нет неоднозначных ситуаций.

  BEGIN
    CONSOLE-HANDLES
    0 TO SOURCE-ID
    [COMPILE] [
    ['] MAIN1 CATCH
    ['] ERROR  CATCH DROP
 ( S0 @ SP! R0 @ RP! \ стеки не сбрасываем, т.к. это за нас делает CATCH :)
  AGAIN
;

: TEST
  S" 1.f" R/O OPEN-FILE THROW >R
  BEGIN
    PAD 1000 R@ READ-LINE THROW
  WHILE
    PAD SWAP TYPE CR
  REPEAT DROP
  R> CLOSE-FILE THROW
;