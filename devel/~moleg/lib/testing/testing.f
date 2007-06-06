\ 14-10-2006 ~mOleg for SPF4.17
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ Автоматическое тестирование библиотек, кода.

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE ADDR      devel\~moleg\lib\util\addr.f
 REQUIRE IFNOT     devel\~moleg\lib\util\ifnot.f

FALSE WARNING !

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

\ секция настроек -----------------------------------------------------------

\ внимание: один из Create всегда должен быть раскомментирован !!!

CREATE russian   \ сообщения на русском языке
\ CREATE english   \ select english messages

\ если хотим тестировать эту либу и все последующие
\ CREATE testing

\ -- слова, которых не хватает в СПФ ----------------------------------------

\ то же что и : только имя приходит на вершине стека данных в виде строки
\ со счетчиком:   S" name" S: код слова ;
?DEFINED S: : S: ( asc # --> ) SHEADER ] HIDE ;

\ слово берет очередную лексему из входного потока до тех пор, пока он »
\ не исчерпается.
: NEXT-WORD ( --> asc #|0 )
            BEGIN NextWord DUP WHILENOT
                  DROP REFILL DUP WHILE
                  2DROP
               REPEAT
            THEN ;

\ зря этого слова нет в СПФ
: IS POSTPONE TO ; IMMEDIATE

\ ---------------------------------------------------------------------------

\ все слова кроме интерфейсных прячем в отдельный словарь
VOCABULARY tests
           ALSO tests DEFINITIONS

\ векторизация этих слов позволяет просто расширять набор инструментов
        USER-VECT is-delimiter
        USER-VECT action

\ основной цикл
: process ( --> )
          BEGIN NEXT-WORD DUP WHILE
                2DUP is-delimiter WHILE
               action
           REPEAT 2DROP EXIT
          THEN
          S" test section not finished" ER-U ! ER-A A! -2 THROW ;

\ ищем слово идентифицируемое строкой в контексте
\ кстати, может в специальном словаре искать: каком-нибудь settings ?
: ?keyword ( asc # --> flag )
           SFIND
           IF DROP TRUE
            ELSE 2DROP FALSE
           THEN ;

\ ---------------------------------------------------------------------------

\ имя, которое оканчивает тестовую секцию
: test-delimiter  ( --> asc # ) S" ;test" ;

\ так быстрее, чем каждый раз искать в словарях ограничитель через SFIND
: is-test-delimiter ( asc # --> false|nfalse ) test-delimiter COMPARE ;

\ а это другая альтернатива 8)
: work-delimiter    ( --> asc # ) S" ;work" ;
: is-work-delimiter ( asc # --> false|nfalse ) work-delimiter COMPARE ;

\ а это поддержка коментариев в стиле СМАЛ32
: comm-delimiter    ( --> asc # ) S" comment;" ;
: is-comm-delimiter ( asc # --> false|nfalse ) comm-delimiter COMPARE ;

\ а это поддежка различных языков
: rus-delimiter     ( --> asc # ) S" ;rus" ;
: is-rus-delimiter ( asc # --> false|nfalse ) rus-delimiter COMPARE ;
: eng-delimiter     ( --> asc # ) S" ;eng" ;
: is-eng-delimiter ( asc # --> false|nfalse ) eng-delimiter COMPARE ;

\ ---------------------------------------------------------------------------

        PREVIOUS DEFINITIONS
                 ALSO tests

\ во время тестирования весь текст между ограничителями
\ интерпретируется или пропускается.
\ Можно использовать внутри определений!
: test: S" testing" ?keyword
         IF    ['] eval-word IS action
          ELSE ['] 2DROP IS action
         THEN
        ['] is-test-delimiter IS is-delimiter
        process ; IMMEDIATE

\ если ограничитель встречен во входном потоке, то значит по каким-то
\ причинам пропущено начало секции тестирования
test-delimiter S: CR ." testing delimiters unpaired!" ABORT ; IMMEDIATE

\ проходят действия обратные тестированию, то есть во время тестирования
\ данная секция выполняться не будет! но в другое время будет.
: work: S" testing" ?keyword
         IF    ['] 2DROP IS action
          ELSE ['] eval-word IS action
         THEN
        ['] is-work-delimiter IS is-delimiter
        process ; IMMEDIATE

work-delimiter S: CR ." working delimiters unpaired!" ABORT ; IMMEDIATE

\ поддержка коментариев в стиле СМАЛ32
: comment: ['] 2DROP IS action
           ['] is-comm-delimiter IS is-delimiter
           process ; IMMEDIATE

comm-delimiter S: CR ." comments unpaired!" ABORT ; IMMEDIATE


\ поддержка языков
: rus:  S" russian" ?keyword
         IF    ['] eval-word IS action
          ELSE ['] 2DROP IS action
         THEN
        ['] is-rus-delimiter IS is-delimiter
        process ; IMMEDIATE

: eng:  S" english" ?keyword
         IF    ['] eval-word IS action
          ELSE ['] 2DROP IS action
         THEN
        ['] is-eng-delimiter IS is-delimiter
        process ; IMMEDIATE

rus-delimiter S: CR ." пропущено начало секции rus!" ABORT ; IMMEDIATE
eng-delimiter S: CR ." eng section start is missed!" ABORT ; IMMEDIATE

        PREVIOUS


        ALSO tests DEFINITIONS

        0 VALUE marker  \ запоминаем глубину стека
        0 VALUE tester  \ запоминаем глубину стека 8)

\ в какую сторону направлен дисбаланс стека?
: ?where ( delta --> )
         0< IF  rus: ." На стеке оставлены лишние значения" ;rus
                eng: ." Data stack overflow." ;eng
             ELSE
                rus: ." Cо стека сняты лишние значения" ;rus
                eng: ." Data stack underflow." ;eng
            THEN ;

\ проверяем, не было ли изменений на стеке
: ?changes ( 0x --> flag )
           tester marker - CELL / DUP >R >R
           BEGIN R> 1- DUP WHILE >R
                       0=  WHILE
            REPEAT rus: ." Изменения на вершине стека данных " ;rus
                   eng: ." data stack contents is changed " ;eng
                   2R> -

                   rus: ." изменено " . ." -ое значение." ;rus
                   eng: . ." -th value changed." ;eng

                   EXIT
           THEN RDROP RDROP
           ." ы" ;

\ есть ли изменения на стеке?
: ?violations ( --> )
              SP@ marker - DUP
              IF ?where
               ELSE DROP ?changes
              THEN ;


        0 VALUE standoff \ отражает вложенность либ во время included

        PREVIOUS DEFINITIONS
                 ALSO tests

\ ---------------------------------------------------------------------------

\ определяем собственный included
: INCLUDED ( asc # --> )
           0x0D EMIT standoff DUP SPACES 3 + TO standoff

           2>R  SP@ TO tester
            0 0 0 0 0 0 0 0 0 0
           SP@ TO marker

           2R> ." including: " 2DUP TYPE 5 SPACES

           ['] (INCLUDED) CATCH

         standoff 3 - 0 MAX TO standoff

           IF rus: ." Проблемы со сборкой либы." CR ;rus
              eng: ." Can't make the library."   CR ;eng
              ERR-STRING TYPE

            ELSE ?violations
           THEN

    tester SP!
    0x0A EMIT ;

        PREVIOUS

\ взято из пакета СПФ.
: MARKER ( "<spaces>name" -- ) \ 94 CORE EXT
         HERE
         GET-CURRENT ,
         GET-ORDER DUP , 0 ?DO DUP , @ , LOOP
         CREATE ,
         DOES> @ DUP \ ONLY
         DUP @ SET-CURRENT CELL+
         DUP @ >R R@ CELLS 2* + 1 CELLS - R@ 0
         ?DO DUP DUP @ SWAP CELL+ @ OVER ! SWAP 2 CELLS - LOOP
         DROP R> SET-ORDER
         DP ! ;

TRUE WARNING !

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ \ пока просто тест на подключаемость.
  S" passed" TYPE
}test

\ ---------------------------------------------------------------------------

\ теперь все, что хотим протестировать, но при этом, хотим чтобы не
\ осталось в форт-системе, подключаем этим словом.
: testlib ( asc # --> )
          S" MARKER remove " EVALUATE
          INCLUDED
          S" remove" eval-word ;

comment:
     теперь  для  тестирования библиотеки достаточно ее подключить с
 помощью  S"  path\name"  testlib.  Во  время  сборки библиотечки ее
 тестирование  вестись  будет  лишь  в  случае,  если автор либы это
 предусмотрел.  Но  кроме этого контролируются ситуации, когда после
 подключения  библиотечки  наблюдается  дисбаланс  на  стеке данных:
 переполнение\переопустошение  либо  изменение стека на определенную
 глубину  (  если  нужно отслеживать изменение стека на большую, чем
 сейчас  глубину(10  ячеек),  необходимо  увеличить  кол-во  нулей в
 included. После подключения весь скомпилированный код удаляется.
comment;

\ ---------------------------------------------------------------------------

test: \ автоматически себя тестируем, если присутствует соответствующий ключ

 S" .\lib\include\core-ext.f" testlib
 S" .\lib\include\double.f"   testlib
 S" .\lib\include\string.f"   testlib
 S" .\lib\include\tools.f"    testlib
 S" .\lib\include\facil.f"    testlib

;test

comment:

нужно добавить проверку баланса стека для кода между test: ;test
- выдавать предупреждения

comment;