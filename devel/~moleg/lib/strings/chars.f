\ 2008-01-29 ~mOleg
\ Сopyright [C] 2008 mOleg mininoleg@yahoo.com
\ работа с символами разлиных типов

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE ADDR     devel\~moleg\lib\util\addr.f

0 \ формат стркутуры, описывающей текущий символьный поток
  ADDR -- off_char+  \ метод перехода к следующему символу
  ADDR -- off_char@  \ метод извлечения символа
  ADDR -- off_char!  \ метод сохранения символа
  ADDR -- off_char#  \ предельный размер символа, например, для utf-8 = 6
  ADDR -- off_<char  \ переместить указатель на один символ влево
 CONSTANT /chartype

\ методы для работы с символами
: (C@) ( addr 'stream --> char ) off_char@ @ EXECUTE ;
: (C+) ( addr 'stream --> addr ) off_char+ @ EXECUTE ;
: (C!) ( char addr 'stream --> ) off_char! @ EXECUTE ;
: (C#) ( addr --> # )            off_char# @ EXECUTE ;
: (<C) ( addr --> addr )         off_<char @ EXECUTE ;

\ указать методику работы с текущим входным потоком
: stream-type ( '@ '! '+ ', char# '<C 'strrec --> )
              DUP >R off_<char A!
                  R@ off_char# A!
                  R@ off_char+ A!
                  R@ off_char! A!
                  R> off_char@ A! ;

\ -- работа с символами входного потока ----------------------------------------

        \ хранилище для структуры описывающей текущий символьный поток
        USER-CREATE CSTREAM /chartype USER-ALLOT

\ методы для работы с символами текущего входного потока
: C@ ( addr --> char ) CSTREAM (C@) ;
: C! ( char addr --> ) CSTREAM (C!) ;
: C+ ( addr --> addr ) CSTREAM (C+) ;
: C# ( addr --> # )    CSTREAM (C#) ;
: <C ( addr --> addr ) CSTREAM (<C) ;
: C, ( char --> ) HERE TUCK C! C# ALLOT ;

\ установить параметры входного потока
: INPUT-STREAM ( '@ '! '+ ' # --> ) CSTREAM stream-type ;

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{
       : char# DROP CELL ;
       ' @ ' ! ' CELL+ ' char# ' CELL- INPUT-STREAM
       0x12345678 DUP HERE C! HERE C@ <> THROW
       HERE 0x23456789 DUP C, SWAP C@ <> THROW
  S" passed" TYPE
}test
