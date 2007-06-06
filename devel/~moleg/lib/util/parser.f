\ 04-06-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ Дополнительные слова для работы с парсером

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE WHILENOT devel\~mOleg\lib\util\ifnot.f

FALSE WARNING !

?DEFINED char  1 CHARS CONSTANT char

\ слово откатывает >IN назад, на начало непонятого слова asc #
: <back ( asc # --> ) DROP TIB - >IN ! ;

\ пропустить один символ во входном потоке
: SkipChar ( --> )  >IN @ char + >IN ! ;

\ взять очередной символ из входного потока
: NextChar ( --> char flag ) EndOfChunk PeekChar SWAP SkipChar ;

\ вернуть адрес и длинну еще не проинтерпретированной части входного буфера.
: REST ( --> asc # ) SOURCE >IN @ DUP NEGATE D+ 0 MAX ;

\ заглянуть вперед во входном потоке
: SeeForw ( --> asc # ) >IN @ NextWord ROT >IN ! ;

\ из входного потока выкусить имя файла
: ParseFileName ( --> asc # )
                PeekChar [CHAR] " =
                IF [CHAR] " SkipChar
                 ELSE BL
                THEN PARSE
                2DUP + 0 SWAP C! ;

\ установить SOURCE на строку параметров »
: cmdline> ( --> )
           -1 TO SOURCE-ID
           GetCommandLineA ASCIIZ> SOURCE!
           ParseFileName 2DROP ;

\ слово берет очередную лексему из входного потока до тех пор, пока он
\ не исчерпается.
: NEXT-WORD ( --> asc # | asc 0 )
            BEGIN NextWord DUP WHILENOT
                  DROP REFILL DUP WHILE
                  2DROP
               REPEAT
            THEN ;

TRUE WARNING !

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ тут просто проверка на собираемость.
  S" passed" TYPE
}test
