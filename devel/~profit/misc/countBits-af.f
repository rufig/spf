\ http://fforum.winglion.ru//viewtopic.php?t=465

\ Подсчет кол-ва битов в слов
\ Подключение преобразование системы счисления 

: countBitsInBytes ( i byte — i ) 
  SWAP OVER     1 AND IF 1+ THEN 
       OVER     2 AND IF 1+ THEN 
       OVER     4 AND IF 1+ THEN 
       OVER     8 AND IF 1+ THEN 
       OVER    16 AND IF 1+ THEN 
       OVER    32 AND IF 1+ THEN 
       OVER    64 AND IF 1+ THEN 
       OVER   128 AND IF 1+ THEN 
  NIP 
; 

\ Case2 -------------------------------------------------- 
: countBitsInCell ( i cell — i ) 
   DUP 0x55555555 AND SWAP 0xAAAAAAAA AND 1 RSHIFT + 
   DUP 0x33333333 AND SWAP 0xCCCCCCCC AND 2 RSHIFT + 
   DUP 0x0F0F0F0F AND SWAP 0xF0F0F0F0 AND 4 RSHIFT + 
   DUP 0x00FF00FF AND SWAP 0xFF00FF00 AND 8 RSHIFT + 
   DUP 0x0000FFFF AND SWAP 0xFFFF0000 AND 16 RSHIFT + 
 + 
; 

\ Case3 -------------------------------------------------- 
: BITS-BYTE \ byte — i 
DUP 0x55 AND SWAP 0xAA AND 1 RSHIFT + 
DUP 0x33 AND SWAP 0xCC AND 2 RSHIFT + 
DUP 0x0F AND SWAP 0xF0 AND 4 RSHIFT + 
; 

CREATE [BITS-BYTE] 256 ALLOT 

: GEN-TBL-BYTE 
[BITS-BYTE] 256 + [BITS-BYTE] 
DO 
  I [BITS-BYTE] - BITS-BYTE I C! 
LOOP 
; 

GEN-TBL-BYTE 

: BitsInByte ( i byte — i ) 
   [BITS-BYTE] + C@ 
   + 
; 

\ ----- Testing ------ 
    1024 CONSTANT KB 
 KB KB * CONSTANT MB 

100 MB * CONSTANT BytesInArray

\ Выделние тестового масиива 
USER Array 
  BytesInArray ALLOCATE THROW Array ! 

\ Заполнение массива 
: FillArray 
  BytesInArray 0 DO 
    I 256 MOD I Array @ + C! 
  LOOP 
; FillArray 

\ Гоняем на тестовом массиве первый метод 
: Case1 
  0 
  BytesInArray 0 DO 
     Array @ I + C@ countBitsInBytes 
  LOOP 
; 

\ Гоняем на тестовом массиве второй метод 
: Case2 
  0 
  BytesInArray 4 / 0 DO 
     Array @ I + @ countBitsInCell 
  LOOP 
; 

\ Гоняем на тестовом массиве третий метод 
: Case3 
  0 
  BytesInArray 0 DO 
     Array @ I + C@  BitsInByte 
  LOOP 
; 

\ Засекаем на время, что быстрее 
REQUIRE time-reset ~af/lib/elapse.f 

 time-reset Case1 .elapsed CR 
 time-reset Case2 .elapsed CR 
 time-reset Case3 .elapsed CR