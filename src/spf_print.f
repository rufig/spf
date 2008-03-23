( Слова форматной печати чисел.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Преобразование из 16-разрядного в 32-разрядный код - 1995-96гг
  Ревизия - сентябрь 1999 [переход на USER-переменные и
  замена CODE-слов высокоуровневыми определениями]
)

USER     HLD  \ переменная - позиция последней литеры, перенесенной в PAD

USER     BASE ( -- a-addr ) \ 94
\ a-addr - адрес ячейки, содержащей текущее основание системы счисления (2..36).

4096 DUP CONSTANT NUMERIC-OUTPUT-LENGTH

USER-CREATE SYSTEM-PAD
CHARS
TC-USER-ALLOT \ Область форматного преобразования - обязательно перед PAD

USER-CREATE PAD ( -- c-addr ) \ 94 CORE EXT
\ c-addr - адрес области для промежуточной обработки данных.
1024 CHARS TC-USER-ALLOT


: HEX ( -- ) \ 94 CORE EXT
\ Установить содержимое BASE равным шестнадцати.
  16 BASE !
;

: DECIMAL ( -- ) \ 94
\ Установить основание системы счисления равным десяти.
  10 BASE !
;

: HOLD ( char -- ) \ 94
\ Добавить char к началу форматной числовой строки.
\ Исключительная ситуация возникает, если использовать HOLD
\ вне <# и #>, ограничивающивающих преобразование чисел.
  HLD @ CHAR- 
  DUP SYSTEM-PAD U< IF -17 THROW THEN
  DUP HLD ! C!
;

: HOLDS ( addr u -- ) \ from eserv src
  TUCK CHARS + SWAP 0 ?DO DUP I CHARS - CHAR- C@ HOLD ( /CHAR +LOOP FIXME) LOOP DROP
;

: <# ( -- ) \ 94
\ Начать форматное преобразование чисел.
  PAD CHAR- HLD !
  0 PAD CHAR- C!
;

: # ( ud1 -- ud2 ) \ 94
\ Делением ud1 на значение BASE выделить одну цифру с конца и
\ добавить ее в буфер форматного преобразования чисел,
\ оставив частное ud2.
\ Исключительная ситуация возникает, если использовать #
\ вне <# и #>, ограничивающивающих преобразование чисел.
  0 BASE @ UM/MOD >R BASE @ UM/MOD R>
  ROT DUP 10 < 0= IF 7 + THEN 48 + 
  HOLD
;

: #S ( ud1 -- ud2 ) \ 94
\ Выделять цифры D1 по слову # до получения нуля.
\ ud2 - ноль.
\ Исключительная ситуация возникает, если использовать #S
\ вне <# и #>, ограничивающивающих преобразование чисел.
  BEGIN
    # 2DUP D0=
  UNTIL
;

: #> ( xd -- c-addr u ) \ 94
\ Убрать xd. Сделать буфер форматного преобразования доступным в виде
\ строки символов, заданной c-addr и u.
\ Программа может менять символы в этой строке.
  2DROP HLD @ PAD OVER - >CHARS 1-
;

: SIGN ( n -- ) \ 94
\ Если n отрицательно, добавить в строку форматного преобразования
\ чисел минус.
\ Исключительная ситуация возникает, если использовать SIGN
\ вне <# и #>, ограничивающивающих преобразование чисел.
  0< IF [CHAR] - HOLD THEN
;

: (D.) ( d -- addr len )
  DUP >R DABS <# #S R> SIGN #> ;

: D. ( d -- ) \ 94 DOUBLE
\ Вывести d на дисплей в свободном формате.
  (D.) TYPE SPACE ;


: . ( n -- ) \ 94
\ Напечатать n в свободном формате.
  S>D D.
;

: U. ( u -- ) \ 94
\ Напечатать u в свободном формате.
  U>D D.
;

: .0
  >R 0 <# #S #> R> OVER - 0 MAX DUP 
    IF 0 DO [CHAR] 0 EMIT LOOP
    ELSE DROP THEN TYPE 
;

: .TO-LOG ( n -- )
\ Напечатать n в свободном формате в лог-файл
  S>D DUP >R DABS <# BL HOLD #S R> SIGN #> TO-LOG
;

: >PRT
  DUP BL U< IF DROP [CHAR] . THEN
;

: PTYPE
  0 DO DUP C@ >PRT EMIT 1+ LOOP DROP
;

: DUMP ( addr u -- ) \ 94 TOOLS
  DUP 0= IF 2DROP EXIT THEN
  BASE @ >R HEX
  15 + 16 U/ 0 DO
    CR DUP 4 .0 SPACE
    SPACE DUP 16 0
      DO I 4 MOD 0= IF SPACE THEN
        DUP C@ 2 .0 SPACE 1+
      LOOP SWAP 16  PTYPE
  LOOP DROP R> BASE !
;

: (.") ( T -> )
  COUNT TYPE
;
' (.") TO (.")-CODE

\ : DIGIT ( C, N1 -> N2, TF / FF ) 
\ N2 - значение литеры C как
\ цифры в системе счисления по основанию N1
(  SWAP
  DUP 58 <
      OVER 47 > AND
      IF \ within 0..9
         48 -
      ELSE
         DUP 64 >
         IF
           DUP 96 > IF 87 ELSE 55 THEN -
         ELSE 2DROP 0 EXIT THEN
      THEN
   TUCK > DUP 0= IF NIP THEN
;)

: >NUMBER ( ud1 c-addr1 u1 -- ud2 c-addr2 u2 ) \ 94
\ ud2 - результат преобразования символов строки, заданной c-addr1 u1,
\ в цифры, используя число в BASE, и добавлением каждой к ud1 после
\ умножения ud1 на число в BASE. Преобразование продолжается слева
\ направо до первого непреобразуемого символа, включая символы "+" и "-",
\ или до полного преобразования строки.
\ c-addr2 - адрес первого непреобразумого символа или первого символа
\ за концом строки, если строка была полностью преобразована.
\ u2 - число непреобразованных символов в строке.
\ Неоднозначная ситуация возникает, если ud2 переполняется во время
\ преобразования.
  BEGIN
    DUP
  WHILE
    >R
    DUP >R
    C@ BASE @ DIGIT 0=     \ ud n flag
    IF R> R> EXIT THEN     \ ud n  ( ud = udh udl )
    SWAP BASE @ UM* DROP   \ udl n udh*base
    ROT BASE @ UM* D+      \ (n udh*base)+(udl*baseD)
    R> CHAR+ R> 1-
  REPEAT
;

: SCREEN-LENGTH ( addr n -- n1 ) \ экранная-длина
\ дать длину строки при выводе (при печати)
\  - число знакомест, которое строка займет на экране.
\ addr n  - строка. n1 число знакомест на экран.
  0 -ROT CHARS OVER + SWAP ?DO
    I C@ 9 = IF 3 RSHIFT 1+ 3 LSHIFT
    ELSE 1+ THEN
  \ /CHAR +LOOP \ FIXME
  LOOP
;
