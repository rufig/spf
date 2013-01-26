\ $Id$

( Преобразование числовых литералов при интерпретации.
  ОС-независимые определения.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999
)

: ?SLITERAL1 ( c-addr u -> ... )
  \ преобразовать строку в число
  0 0 2SWAP
  OVER C@ [CHAR] - = DUP >R IF 1 - SWAP CHAR+ SWAP THEN
  DUP 1 > IF
    2DUP CHARS + CHAR- C@ [CHAR] . = DUP >R IF 1- THEN
  ELSE 0 >R THEN
  DUP 0= IF -2001 THROW THEN \ нулевая длина строки цифр
  >NUMBER NIP IF -2001 THROW THEN \ ABORT" -?"
  R> IF
       R> IF DNEGATE THEN
       [COMPILE] 2LITERAL
  ELSE D>S
       R> IF NEGATE THEN
       [COMPILE] LITERAL
  THEN
;
: ?LITERAL1 ( T -> ... )
  \ преобразовать строку в число
  COUNT ?SLITERAL1
;
: HEX-SLITERAL ( addr u -> flag )
  BASE @ >R HEX
  0 0 2SWAP 2- SWAP 2+ SWAP >NUMBER
  ?DUP IF
    1 = SWAP C@ [CHAR] L = AND 0= IF 2DROP FALSE R> BASE ! EXIT THEN
  ELSE DROP THEN
  D>S POSTPONE LITERAL TRUE
  R> BASE !
;
: ?SLITERAL2 ( c-addr u -- ... )
  ( расширенный вариант ?SLITERAL1:
    если строка - не число, то пытаемся трактовать её
    как имя файла для авто-INCLUDED)
  DUP 1 > IF OVER W@ 0x7830 ( 0x) = 
    IF 2DUP 2>R HEX-SLITERAL IF RDROP RDROP EXIT ELSE 2R> THEN THEN
  THEN
  2DUP 2>R ['] ?SLITERAL1 CATCH
  0= IF RDROP RDROP EXIT THEN
  2DROP 2R>

  DUP 0 U> IF ( не пустое )
       OVER C@ [CHAR] " = OVER 2 > AND
       IF 2 - SWAP 1+ SWAP THEN ( убрал кавычки, если есть)
       2DUP + 0 SWAP C!
       2DUP FILE-EXISTS
  IF ( имя файла, а не путь )
       ['] INCLUDED CATCH
       DUP 2 <> OVER 3 <> AND OVER 161 <> AND
       ( файл не найден или путь не найден,
       или неразрешенное имя файла)
       IF THROW EXIT THEN
  THEN THEN ( c-addr u | ior )
  -2003 THROW \ ABORT"  -???"
;
: ?LITERAL2 ( c-addr -- ... )
  ( расширенный вариант ?LITERAL1:
    если строка - не число, то пытаемся трактовать её
    как имя файла для авто-INCLUDED)
  COUNT ?SLITERAL2
;
