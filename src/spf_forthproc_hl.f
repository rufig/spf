( Оставшиеся слова "форт-процессора" в виде высокоуровневых определений.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

0 CONSTANT FALSE ( -- false ) \ 94 CORE EXT
\ Вернуть флаг "ложь".

-1 CONSTANT TRUE ( -- true ) \ 94 CORE EXT
\ Вернуть флаг "истина", ячейку со всеми установленными битами.

4 CONSTANT CELL

: */ ( n1 n2 n3 -- n4 ) \ 94
\ Умножить n1 на n2, получить промежуточный двойной результат d.
\ Разделить d на n3, получить частное n4.
  */MOD NIP
;
: CHAR+ ( c-addr1 -- c-addr2 ) \ 94
\ Прибавить размер символа к c-addr1 и получить c-addr2.
  1+
;
: CHARS ( n1 -- n2 ) \ 94
\ n2 - размер n1 символов.
; IMMEDIATE

: MOVE ( addr1 addr2 u -- ) \ 94
\ Если u больше нуля, копировать содержимое u байт из addr1 в addr2.
\ После MOVE в u байтах по адресу addr2 содержится в точности то же,
\ что было в u байтах по адресу addr1 до копирования.
  >R 2DUP SWAP R@ + U< \ назначение попадает в диапазон источника или левее
  IF 2DUP U<           \ И НЕ левее
     IF R> CMOVE> ELSE R> QCMOVE THEN
  ELSE R> QCMOVE THEN
;
: ERASE ( addr u -- ) \ 94 CORE EXT
\ Если u больше нуля, очистить все биты каждого из u байт памяти,
\ начиная с адреса addr.
  0 FILL
;
: DABS ( d -- ud ) \ 94 DOUBLE
\ ud абсолютная величина d.
  DUP 0< IF DNEGATE THEN
;

: HASH ( addr u u1 -- u2 )
   2166136261 2SWAP
   OVER + SWAP 
   ?DO
      16777619 * I C@ XOR
   LOOP
   SWAP ?DUP IF UMOD THEN   
;

0  VALUE  DOES-CODE
