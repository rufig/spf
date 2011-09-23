( Библиотека для построчного буферизированного чтения из pipe.
  [1:1 скопировано из socketline2.f]
  Copyright 1996-2008 A.Cherezov ac@eserv.ru
)

REQUIRE { lib/ext/locals.f

10000 VALUE PL_LINE_BUFF_SIZE      \ размер буфера

0                                  \ структура "строчный канал"
4 -- pl_pipe                       \ читаемый pipe
4 -- pl_point                      \ смещение в буфере текущей позиции чтения
4 -- pl_last                       \ адрес в буфере текущей позиции выборки
CONSTANT /pl


\ PipeLine инициализирует буфер для построчного чтения заданного канала
\ и возвращает адрес этой структуры

: PipeLine ( pipe -- addr-S )
  { \ addr }
  PL_LINE_BUFF_SIZE /pl + ALLOCATE THROW -> addr
  addr pl_pipe !
  addr pl_point 0!
  addr /pl + addr pl_last !
  addr
;

\ PipeGetPending получает из буфера всё, что там осталось,
\ не меняя указателей в буфере

: PipeGetPending ( addr-S -- addr1 u1 )
  { addr }
  addr pl_last @
  addr /pl + addr pl_point @ + OVER - 0 MAX
;

\ PipeReadFromPending получает из оставшихся в буфере данных
\ не более u1 байт
\ Указатели сдвигаются, т.е. эти данные "убираются" из буфера.

: PipeReadFromPending ( u1 addr-S -- addr1 u2 ) \ u2 <= u1
  { u1 addr }
  addr PipeGetPending NIP u1 > 0=
  IF addr PipeGetPending
     addr pl_point 0!
     addr /pl + addr pl_last !
  ELSE
     addr PipeGetPending u1 MIN
     addr pl_last @ OVER + addr pl_last !
  THEN
;

\ PipeContRead
\

: PipeContRead1 ( addr-S -- )
  { addr \ a u }
  addr PipeGetPending
  OVER C@ 10 ( LF ) = OVER 0 > AND IF 1- SWAP 1+ SWAP THEN -> u -> a
  a addr /pl + u MOVE
  addr /pl + addr pl_last !

  addr /pl + u +
  PL_LINE_BUFF_SIZE u -
  DUP 0 > 
  IF
    addr pl_pipe @ READ-FILE
    DUP 109 = IF DROP -1002 THEN
    THROW
    u + addr pl_point !
  ELSE 2DROP THEN
;
: PipeContRead2 ( addr-S -- ior )
  { addr \ a u }
  addr PipeGetPending -> u -> a
  a addr /pl + u MOVE
  addr /pl + addr pl_last !

  addr /pl + u +
  PL_LINE_BUFF_SIZE u -
  addr pl_pipe @ READ-FILE
  DUP 109 = IF DROP -1002 THEN
\  DUP 10060 = IF a u DUMP CCR THEN
  DUP IF NIP EXIT THEN SWAP ( 0 n )
  u + addr pl_point !
;
: PipeContRead PipeContRead2 THROW ;

\ PipeReadLine читает строку, ограниченную LF или CRLF
\ Сам ограничитель в возвращаемую строку не включается.
\ Если строка достигла размера буфера, но разделитель не
\ найден, то строка режется на текущей длине. Остаток будет
\ выдаваться следующими вызовами этой функции.
\ Если разделитель не найден, и в буфере еще есть куда
\ читать, то продолжается реальное чтение из канала
\ (возможно блокирующее).
: PipeReadLine ( addr -- addr1 u1 )
  { addr \ pa1 pu1 acr }
  BEGIN
    addr PipeGetPending -> pu1 -> pa1
    pa1 pu1 LT 1+ 1 SEARCH
    IF
        DROP -> acr
        acr 1+ addr pl_last !
        pa1 acr OVER - 
        BEGIN
          2DUP + 1- C@ 13 = OVER 0 > AND
        WHILE 1- 0 MAX REPEAT
        EXIT
    THEN  2DROP
    pu1 PL_LINE_BUFF_SIZE =
    IF
       addr pl_point 0!
       addr /pl + addr pl_last !
       pa1 pu1 EXIT
    THEN
    addr PipeContRead2
    DUP -1002 = IF pu1 IF DROP
       addr pl_point 0!
       addr /pl + addr pl_last !
       pa1 pu1 EXIT
    THEN THEN THROW
  AGAIN
;
