\ 08-10-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с utf16 : диапазон от 0 до 0xD7FF и от 0xE000 до 0xFFFFF.

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f

?DEFINED IS : IS POSTPONE TO ; IMMEDIATE

\ ------------------------------------------------------------------------------

\ поменять местами два байта слова
: BSWAP ( W[B|L] --> W[L|B] ) DUP 8 LSHIFT SWAP 8 RSHIFT OR 0xFFFF AND ;

\ прочесть, сохранить двухбайтовое значение с обратным порядком следования байт
\ от принятого на данной архитектуре
: W@' ( addr --> w ) W@ BSWAP ;
: W!' ( w addr --> ) >R BSWAP R> W! ;

\ прочитать пару байт, начинающихся с указанного адреса
\ так как порядок байт зависит от архитектуры и от потока
\ в переменную записывается то(либо) W@ либо W@ BSWAP
  USER-VECT WN@ ( addr --> W )
  USER-VECT WN! ( w addr --> )
            ' W@ IS WN@
            ' W! IS WN!

\ определить размер символа
\ если двухбайтного символа находится в диапазоне 0xD800-0xDFFF
\ символ занимает 4 байта, иначе два.
: CHAR# ( addr --> # ) WN@ 0xDC00 AND 0xD800 = IF 4 ELSE 2 THEN ;

\ извлечь значение символа, хранящегося по указанному адерсу addr
: CHAR@ ( addr --> char )
        DUP WN@ 0xD800 2DUP AND =
        IF SWAP 2 + WN@
           0x03FF AND 10 LSHIFT SWAP 0x03FF AND OR 0x10000 +
         ELSE NIP
        THEN ;

\ сохранить символ char по указанному адресу addr
\ символы в запрещенном диапазоне 0xD800 0xDFFF пишутся, как обычно
\ слово сохраняющее значение в код этой тонкости знать, мне кажется, не должно
: CHAR! ( char addr --> )
        OVER 0xFFFF >
        IF >R 0x10000 - DUP 10 RSHIFT  \ l h
           0x3FF AND 0xDC00 OR R@ 2 + WN!
           0x3FF AND 0xD800 OR R> WN!
         ELSE WN!
        THEN ;

\ компилировать utf8 символ на вершину кодфайла
\ внимание, сначала пишем, затем защищаем с помощью ALLOT
: CHAR, ( char --> ) HERE TUCK CHAR! CHAR# ALLOT ;

\ является ли текст utf16 кодированным.
\ на входе адрес начала текста.
: ?utf16 ( addr --> flag ) W@ 0xFEFF OVER 0xFFFE = -ROT = OR ;

\ является ли символ по указанному адресу utf16 символом
\ наверняка можно опознать только длинный символ, или несколько
\ идущих подряд символов одинарной длины.
: ?utf16char ( addr --> flag )
            DUP WN@ DUP 0xD800 0xDFFF WITHIN
                    IF SWAP 2 + WN@ AND 0xD800 AND 0xD800 =
                     ELSE 2DROP FALSE
                    THEN ;

\ содержит ли фрагмент текста utf8 символ(ы)
\ я предполагаю, что подразумевается, что текст в utf16 кодировке всегда
\ начинается с четного адреса, и любой символ всегда начинается с четного
\ адреса.
: isUTF16 ( asc # --> flag )
          OVER ?utf16 IF 2DROP TRUE EXIT THEN
          OVER ?utf16char IF 2DROP TRUE EXIT THEN
         \ дальше предполагаем, что строка состоит хотя бы из трех символов,
         \ находящихся в одной кодовой странице
         6 < IF DROP FALSE EXIT THEN
         DUP CHAR# OVER +
         DUP CHAR# DUP 4 = IF DROP NIP ?utf16char EXIT THEN OVER +
         DUP CHAR# 4 = IF NIP NIP ?utf16char EXIT THEN
         WN@ 0xFF00 AND ROT WN@ 0xFF00 AND ROT WN@ 0xFF00 AND
         OVER = >R = R> AND
         ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{
      0x2315 DUP HERE CHAR! HERE CHAR@ <> THROW
      0x12315 DUP HERE CHAR! HERE CHAR@ <> THROW
      HERE 0xFFFE W, 0x2315 CHAR, 0x2316 CHAR, 0x23FF CHAR, 0x12432 CHAR,
                     0x2320 CHAR, 0x238F CHAR,
      DUP 14 isUTF16 0= THROW
      2 + DUP 12 isUTF16 0= THROW
      2 + DUP 10 isUTF16 0= THROW
      2 + DUP 8  isUTF16 0= THROW
      2 + DUP 6  isUTF16 0= THROW
      2 + 4  isUTF16 THROW
S" passed" TYPE
}test

