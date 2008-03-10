\ 07-10-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ работа с utf8: диапазон символов 0 -- 0x7FFFFFFF

 REQUIRE B,        devel\~mOleg\lib\util\bytes.f  \ чтобы не путаться с C@

\ ------------------------------------------------------------------------------

CREATE utf8cnt \ табличка для определения длины символа в utf8 кодировке
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B, 0x01 B,
               0x02 B, 0x02 B, 0x02 B, 0x02 B, 0x02 B, 0x02 B, 0x02 B, 0x02 B,
               0x03 B, 0x03 B, 0x03 B, 0x03 B, 0x04 B, 0x04 B, 0x05 B, 0x06 B,

\ определить длину символа.
\ на входе адрес, где символ лежит, на выходе его длина
: CHAR# ( 'char --> # ) B@ 2 RSHIFT [ utf8cnt ] LITERAL + B@ ;

CREATE utf8hdr \ маска для выделения данных из первого байта
               0x7F B, 0x3F B, 0x1F B, 0x0F B, 0x07 B, 0x03 B, 0x01 B,

\ извлечь символ из указанной позиции.
\ на входе адрес, по которому хранится символ, на выходе его 32 битное значение
: CHAR@ ( 'char --> char )
        DUP B@ DUP 0x80 < IF NIP EXIT THEN
        OVER CHAR# [ utf8hdr ] LITERAL + B@ AND
        BEGIN SWAP 1 + TUCK
              B@ DUP 0xC0 AND 0x80 = WHILE
              0x3F AND  SWAP 6 LSHIFT  OR
        REPEAT DROP NIP ;

CREATE utf8hhh \ маска для сохранения счетчика в первом байте
               0x00 B, 0x00 B, 0xC0 B, 0xE0 B, 0xF0 B, 0xF8 B, 0xFC B,

\ преобразовать длинный символ в последовательность utf8 байт.
\ на стеке байты лежат в обратном порядке.
: charr ( char --> [ 1 .. n ] )
        0 BEGIN OVER WHILE
                OVER 0x3F AND 0x80 OR
                ROT 6 RSHIFT
                ROT 1 +
          REPEAT NIP
        [ utf8hhh ] LITERAL + B@ OR ;

\ сохранить символ char в utf8 кодировке по указанному адресу.
: CHAR! ( char addr --> )
        OVER 0x80 U< IF C! EXIT THEN
        >R 0 SWAP charr
        R> BEGIN OVER WHILE
                 TUCK B! 1 +
           REPEAT 2DROP ;

\ компилировать utf8 символ на вершину кодфайла
: CHAR, ( char --> ) HERE TUCK CHAR! CHAR# ALLOT ;

\ является ли текст utf8 кодированным.
\ на входе адрес начала текста.
: ?utf8 ( addr --> flag ) @ 0xFFFFFF AND 0xBFBBEF = ;

\ является ли символ utf8 символом длиной от двух до шести байт
\ адрес должен указывать на начало символа.
: ?utf8char ( addr --> flag )
            DUP B@ 0xE0 OVER AND 0xC0 = SWAP
                   0xF0 OVER AND 0xE0 = SWAP
                   0xF8 OVER AND 0xF0 = SWAP
                   0xFC OVER AND 0xF8 = SWAP
                   0xFE AND 0xFC = OR OR OR OR
            SWAP 1+ B@ 0xC0 AND 0x80 = AND ;

\ содержит ли фрагмент текста utf8 символ(ы)
: isUTF8 ( asc # --> flag )
         OVER ?utf8 IF 2DROP TRUE EXIT THEN \ ?сигнатура
         OVER + SWAP
         BEGIN 2DUP <> WHILE   \ ищем начало двух и более байтового символа
               DUP B@ DUP 0x7F < SWAP 0xC0 AND 0x80 = OR WHILE
             1 +
           REPEAT NIP ?utf8char EXIT
         THEN 2DROP FALSE ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{

0x7F HERE CHAR!  HERE CHAR@ 0x7F <> THROW
0x80 HERE CHAR!  HERE CHAR@ 0x80 <> THROW
HERE ?utf8char INVERT THROW
0x7FF HERE CHAR!  HERE CHAR@ 0x7FF <> THROW
0xFFFF HERE CHAR!  HERE CHAR@ 0xFFFF <> THROW
0x7FFFFFFF HERE CHAR!  HERE CHAR@ 0x7FFFFFFF <> THROW
HERE CHAR# 6 <> THROW
CREATE proba 0xBFBBEF , 0x45 CHAR, 0x7FD CHAR, 0xFFFF CHAR, 0x7FFFFFFF CHAR, 0 B,
proba ?utf8 INVERT THROW
proba HERE OVER - isUTF8 INVERT THROW
proba HERE OVER - 1 -1 D+ isUTF8 INVERT THROW
proba HERE OVER - 3 -3 D+ isUTF8 INVERT THROW

S" passed" TYPE
}test
