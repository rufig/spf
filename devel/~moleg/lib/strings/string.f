\ 21-05-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ строковые литералы с поддержкой символов подстановки \n \r \t \\ \" \123

\ для подключения лишь уникальных слов:
REQUIRE ?: devel\~moleg\lib\util\ifcolon.f

?: A! ! ; ?: A@ @ ; ?: char 1 CHARS ;

\ пропустить один символ во входном потоке »
?: SkipChar ( --> ) char >IN +! ;

\ взять очередной символ из входного потока
\ flag = TRUE если входной поток исчерпан
?: NextChar ( --> char flag ) EndOfChunk PeekChar SWAP SkipChar ;

\ ---------------------------------------------------------------------------

\ инициализация буфера
: <| ( --> ) SYSTEM-PAD HLD A! ;

\ добавить символ во буфер PAD
\ отличие от HOLD в том, что символ добавляется в конец формируемой строки
\ а не в ее начало.
: KEEP ( char --> ) HLD A@ C! char HLD +! ;

\ вернуть сформированную строку
: |> ( --> asc # ) 0 KEEP SYSTEM-PAD HLD A@ OVER - ;

\ добавить строку в буфер PAD
\ действие аналогично HOLDS за исключением того, что строка добавляется
\ в конец формируемой строки, а не в ее начало.
: KEEPS ( asc # --> ) HLD A@ OVER HLD +! SWAP CMOVE ;

\ ---------------------------------------------------------------------------

\ преобразовать запись \123 в код символа
: CharCode ( asc # --> char )
           BASE @ >R DECIMAL
            0 0 2SWAP >NUMBER IF -1 THROW ELSE 2DROP THEN
           R> BASE ! ;

\ преобразовать символьную последовательность \? в символ
: expose ( --> char )
         PeekChar SkipChar
          [CHAR] t OVER = IF DROP 0x09 EXIT THEN  \ tab
          [CHAR] n OVER = IF DROP 0x0A EXIT THEN  \ cr
          [CHAR] r OVER = IF DROP 0x0D EXIT THEN  \ lf
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
: S" ( / name" --> ) [CHAR] " CookLine [COMPILE] SLITERAL ; IMMEDIATE

\EOF -- тестовая секция ----------------------------------------------------

: test S" \tSimple\nsample\n\"text\" \nwith\123codes\125" TYPE ;
test


