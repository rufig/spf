\ 21-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ строковые литералы с поддержкой символов подстановки \n \r \t \\ \" \123

 REQUIRE ?DEFINED devel\~moleg\lib\util\ifdef.f
 REQUIRE KEEP     devel\~moleg\lib\spf_print\pad.f
 REQUIRE SkipChar devel\~mOleg\lib\util\parser.f
 REQUIRE COMPILE  devel\~mOleg\lib\util\compile.f

\ преобразовать запись \123 в код символа
: CharCode ( asc # --> char )
           BASE @ >R DECIMAL
            0 0 2SWAP >NUMBER IF -1 THROW ELSE 2DROP THEN
           R> BASE ! ;

\ преобразовать символьную последовательность \? в символ
\ если не встречена известная последовательность - сохраняется код
\ оригинального символа.
: expose ( --> char )
         PeekChar SkipChar
          [CHAR] t OVER = IF DROP 0x09 EXIT THEN  \ tab
          [CHAR] n OVER = IF DROP 0x0A EXIT THEN  \ cr
          [CHAR] r OVER = IF DROP 0x0D EXIT THEN  \ lf
       \ аналогичным образом сюда можно добавлять другие необходимые варианты
          DUP 0x0A DIGIT                          \ \XXX
          IF 2DROP CharAddr char - 3 CHARS CharCode 2 CHARS >IN +! EXIT THEN
         ;

\ вернуть следующий символ с учетом возможности подстановки
: IfChar ( char --> char ) [CHAR] \ OVER = IF DROP expose THEN ;

\ подготовить строку, завершенную указанным символом
: CookLine ( char --> asc # )
           <| BEGIN NextChar 0= WHILE
                    2DUP <> WHILE
                    IfChar KEEP
                 REPEAT 2DROP |> EXIT
              THEN -1 THROW ;

\ добавить литеральную строку в определение (либо просто вернуть строку)
: s" ( / name" --> ) [CHAR] " CookLine [COMPILE] SLITERAL ; IMMEDIATE

FALSE WARNING !

\ выделить строку, ограниченную символом " из входного потока,
\ компилировать в текущее слово код, выводящий строку на экран терминала
: ." ( --> ) ?COMP [COMPILE] s" COMPILE TYPE ; IMMEDIATE

TRUE WARNING !

?DEFINED test{ \EOF -- тестовая секция --------------------------------------

test{ \ пока просто тест на подключаемость.
  S" passed" TYPE
}test

\EOF

: test s" \tSimple\nsample\n\"text\" \nwith\123codes\125" TYPE ;
test


