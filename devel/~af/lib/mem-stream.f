\ Andrey Filatkin, af@forth.org.ru
\ Работа с куском динамической памяти как с потоком.
\ Память должна быть с нулевым байтом в конце.
\ Служебная ячейка используется как указатель последнего прочитанного байта.

REQUIRE FStream          ~af/lib/stream_io.f
REQUIRE [DEFINED]        lib/include/tools.f

: READ-MEM ( c-addr u1 hmem -- u2 ior=0 )
\ потоковое чтение из памяти
  CELL- DUP >R @
  TUCK + OVER
  BEGIN  2DUP > OVER C@ AND  WHILE  1+  REPEAT
  NIP DUP R> !
  OVER - >R SWAP R@ MOVE
  R> 0
;
: MEM>RSTREAM ( hmem -- s )
  DUP DUP CELL- ! \ указатель текущей позиции
  ['] READ-MEM
  FStream::HANDLE>STREAM-WITH
;
: INCLUDE-MEM ( i*x hmem -- j*x )
  BLK 0!
  MEM>RSTREAM DUP >R
  [ ALSO FStream ] 
    ['] READ-LINE
    ['] TranslateFlow RECEIVE-WITH-XT
    R> CLOSE-STREAM THROW
  [ PREVIOUS ] 
  THROW
;
: INCLUDED-MEM ( i*x hmem c-addr u -- j*x )
  CURFILE @ >R
  HEAP-COPY CURFILE !
  INCLUDE-MEM
  CURFILE @ FREE THROW
  R> CURFILE !
;
