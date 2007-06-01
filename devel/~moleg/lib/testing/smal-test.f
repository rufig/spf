\ 27-04-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ поддержка возможности тестировани€ кода

\ слово берет очередную лексему из входного потока до тех пор, пока он
\ не исчерпаетс€.
: NEXT-WORD ( --> asc # | asc 0 )
            BEGIN NextWord DUP 0= WHILE
                  DROP REFILL DUP WHILE
                  2DROP
               REPEAT
            THEN ;

\ вызвать ошибку вместе со следующим сообщением
: SERROR ( asc # --> ) ER-U ! ER-A ! -2 THROW ;

\ 10-11-2006 решение проблемы необработки литералов стандартным EVAL-WORD
: eval-word
    SFIND ?DUP
    IF
         STATE @ =
         IF COMPILE, ELSE EXECUTE THEN
     ELSE
         S" NOTFOUND" SFIND
         IF EXECUTE
         ELSE 2DROP ?SLITERAL THEN
    THEN ;

\ начать слово с именем заданым строкой asc #
: S: ( asc # --> ) SHEADER ] HIDE ;

\ ----------------------------------------------------------------------------

        \ состо€ние режима тестировани€
        USER TESTING ( --> addr )

        \ €вл€етс€ ли указанна€ лексема завершающей дл€ секции
        USER-VECT is-delimiter ( --> flag )

        \ действи€ выполн€емые внутри секции
        USER-VECT action ( asc # --> xj )

\ поиск разделител€ во входном потоке. ¬ случае завершени€ входного потока,
\ если разделитель не был встречен, вызвать обработчик ошибок.
: process-test ( --> )
               BEGIN NEXT-WORD DUP WHILE
                     2DUP is-delimiter WHILE
                     action
                 REPEAT 2DROP EXIT
               THEN
               S" section not finished" SERROR ;

\ вернуть строку-ограничитель тестовой секции
: test-delimiter ( --> asc # ) S" }test" ;

\ €вл€етс€ ли указанна€ лексема завершающей дл€ секции теста
: is-test-delimiter ( asc # --> false|nfalse ) test-delimiter COMPARE ;

\ во врем€ тестировани€ весь текст между ограничител€ми
\ интерпретируетс€ или пропускаетс€.
\ ћожно использовать внутри определений!
: test{ ( --> )
        TESTING @
         IF    ['] eval-word TO action
          ELSE ['] 2DROP TO action
         THEN
        ['] is-test-delimiter TO is-delimiter
        process-test ; IMMEDIATE

\ если ограничитель встречен во входном потоке, то значит по каким-то
\ причинам пропущено начало секции тестировани€
test-delimiter S: ( --> ) S" testing delimiters unpaired!" SERROR ; IMMEDIATE

\ получить строку из входного потока и распечатать
: .S" ( / string" --> asc # )
      [COMPILE] S" 2DUP TYPE
      0x3E OVER - 0 MAX SPACES
      ; IMMEDIATE

FALSE WARNING !
\ чтобы не тестировались вложенные библиотеки
: REQUIRE  TESTING @ >R FALSE TESTING ! REQUIRE R> TESTING ! ;
: TESTED   TRUE TESTING ! DEPTH >R 2DUP INCLUDED
           DEPTH R> <> IF CR ."          stack leaking !!!" THEN 2DROP ;
: INCLUDED TESTING @ >R FALSE TESTING ! INCLUDED R> TESTING ! ;
TRUE WARNING !

: testing.. ." testing: " ; ' testing.. MAINX !
S" st.exe" SAVE BYE

\EOF -- тестова€ секци€ ------------------------------------------------------

test{ : simple ." simple sample" CR ;
      simple
}test

