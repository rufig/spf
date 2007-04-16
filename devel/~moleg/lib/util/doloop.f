\ 22-02-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ циклы DO LOOP для СПФ - портабельный вариант.

\ ВНИМАНИЕ для совместимости с библиотекой lib\ext\locals.f
\ необходимо подправить locals в следующим образом:
\ : DO    POSTPONE DO     [  4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
\ : ?DO   POSTPONE ?DO    [  4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
\ : LOOP  POSTPONE LOOP   [ -4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
\ : +LOOP POSTPONE +LOOP  [ -4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
\ то есть указать, что на стеке возвратов оказывается не три, как обычно,
\ а четыре параметра.

\ lib\ext\disasm.f
\ для подключения лишь уникальных слов:
REQUIRE ?: devel\~moleg\lib\util\ifcolon.f

\ делает то же, что и ['] name COMPILE,
?: COMPILE ( --> )
           ?COMP
           ' LIT, ['] COMPILE, COMPILE,
          ; IMMEDIATE

\ ---------------------------------------------------------------------------

\ на стеке возвратов лежит 4-ре параметра.
\ адрес выхода из слова
\ верхний предел счета
\ счетчик цикла
\ адрес выхода за LOOP метку

\ вернули счетчик текущего цикла
: I ( --> index )
    \ 2R> R@ -ROT 2>R
    8 RP+@ ;

\ вернуть счетчик внешнего цикла.
: J ( --> ext_index ) 24 RP+@ ;

\ экстренный выход из цикла
: LEAVE ( --> ) RDROP RDROP RDROP RDROP ;

\ установили параметры цикла - выполняется один раз на входе
: (DO) ( up low --> ) R> -ROT 2>R ['] LEAVE >R >R ;

\ приращение счетчика цикла, проверка условия выхода из цикла.
: (+LOOP) ( n --> flag ) 2R> ROT R> + R@ OVER >R > -ROT 2>R ;

\ ---------------------------------------------------------------------------

\ начать выполнение цикла, инициализровать счетчик цикла
: DO ( up low --> )
     ?COMP
     HERE 0 RLIT, 1 + \ загрузка адреса выхода по LEAVE
     0
     COMPILE (DO)
     [COMPILE] BEGIN ; IMMEDIATE

\ начать выполнение цикла с предусловием - если up меньше low
\ выполнение цикла отменяется
: ?DO ( up low -->  )
      ?COMP
      HERE 0 RLIT, 1 + \ загрузка адреса выхода по LEAVE
      COMPILE 2DUP COMPILE > [COMPILE] IF
      COMPILE (DO)
      [COMPILE] BEGIN ; IMMEDIATE

\ место завершения или повторения цикла, начатого описателем DO или ?DO
\ приращение счетчика цикла определяется содержимым верхнего
\ элемента стека данных
: +LOOP ( n --> )
        ?COMP
        COMPILE (+LOOP)
        [COMPILE] UNTIL
                  COMPILE RDROP COMPILE RDROP COMPILE RDROP COMPILE RDROP

        DUP IF [COMPILE] ELSE COMPILE 2DROP COMPILE RDROP [COMPILE] THEN
             ELSE DROP
            THEN
        HERE SWAP !

        ; IMMEDIATE

\ место завершения или повторения цикла, начатого описателем DO или ?DO
\ приращение счетчика цикла = 1
: LOOP ( --> ) ?COMP 1 LIT, [COMPILE] +LOOP ; IMMEDIATE

\ Убрать параметры цикла текущего уровня. UNLOOP требуется для каждого
\ уровня вложения циклов перед выходом из определения по EXIT.
: UNLOOP ( --> ) R> RDROP RDROP RDROP RDROP >R ;

\EOF -- тестовая секция -----------------------------------------------------

DECIMAL CR

: test  CR 10 0 ." a " ?DO I . LOOP ." c " ;         test
: testa CR 0 0  ." a " ?DO I . LOOP ." c " ;         testa
: testb CR 10 0 ." a " ?DO I . EXIT LOOP ." c " ;    testb
: testc CR 10 0 ." a " ?DO I . LEAVE LOOP ." c " ;   testc

: testd CR 10 0 DO 10 0 DO J . I . SPACE LOOP CR LOOP ; testd
: teste CR 10 0 DO 10 0 DO J . I . SPACE LEAVE LOOP CR LOOP ; teste

: testf CR ." a " 10 0 DO ." b " I . I 5 = IF UNLOOP EXIT THEN LOOP ." c " ;
testf
