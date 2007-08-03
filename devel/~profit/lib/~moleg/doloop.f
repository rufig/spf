REQUIRE /TEST ~profit/lib/testing.f
REQUIRE vocLocalsSupport lib/ext/locals.f

MODULE: mOleg-DO-LOOP

\ ---------------------------------------------------------------------------

\ на стеке возвратов лежит 4-ре параметра.
\ адрес выхода из слова
\ верхний предел счета
\ счетчик цикла
\ адрес выхода за LOOP метку

\ установили параметры цикла - выполняется один раз на входе
\ тут ошибка!!! не определен новый LEAVE - используется старый!
: (DO) ( up low --> ) R> -ROT 2>R ['] LEAVE >R >R ;

\ приращение счетчика цикла, проверка условия выхода из цикла. »
: (+LOOP) ( n --> flag )
          DUP 0 < IF    2R> ROT R> + R@ OVER >R <
                   ELSE 2R> ROT R> + R@ OVER >R < 0=
                  THEN -ROT 2>R ;

\ ---------------------------------------------------------------------------
EXPORT

WARNING @ WARNING 0!

\ экстренный выход из цикла
: LEAVE ( --> ) RDROP RDROP RDROP RDROP ;

\ вернули счетчик текущего цикла
: I ( --> index )
    \ 2R> R@ -ROT 2>R
    2 CELLS RP+@ ;

\ вернуть счетчик внешнего цикла.
: J ( --> ext_index ) 6 CELLS RP+@ ;

\ начать выполнение цикла, инициализровать счетчик цикла
: DO ( up low --> )
     ?COMP
     HERE 0 RLIT, 1 + \ загрузка адреса выхода по LEAVE
     POSTPONE (DO)
     0
     [COMPILE] BEGIN ; IMMEDIATE

\ начать выполнение цикла с предусловием - если up меньше low
\ выполнение цикла отменяется
: ?DO ( up low -->  )
      ?COMP
      HERE 0 RLIT, 1 + \ загрузка адреса выхода по LEAVE
      POSTPONE 2DUP POSTPONE > [COMPILE] IF
     POSTPONE (DO)
      [COMPILE] BEGIN ; IMMEDIATE

\ место завершения или повторения цикла, начатого описателем DO или ?DO
\ приращение счетчика цикла определяется содержимым верхнего
\ элемента стека данных
: +LOOP ( n --> )
        ?COMP
        POSTPONE (+LOOP)
        [COMPILE] UNTIL
                  POSTPONE RDROP POSTPONE RDROP POSTPONE RDROP POSTPONE RDROP

        DUP IF [COMPILE] ELSE POSTPONE 2DROP POSTPONE RDROP [COMPILE] THEN
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

\ ===
\ переопределение соответствующих слов для возможности использовать
\ временные переменные внутри  цикла DO LOOP  и независимо от изменения
\ содержимого стека возвратов  словами   >R   R>

{{ vocLocalsSupport DEFINITIONS

: DO    FORTH::POSTPONE DO     [  4 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: ?DO   FORTH::POSTPONE ?DO    [  4 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: LOOP  FORTH::POSTPONE LOOP   [ -4 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: +LOOP FORTH::POSTPONE +LOOP  [ -4 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: >R    FORTH::POSTPONE >R     [  1 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: R>    FORTH::POSTPONE R>     [ -1 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
: RDROP FORTH::POSTPONE RDROP  [ -1 CELLS ] LITERAL  uAddDepth +! ;; IMMEDIATE
\ ===
}} DEFINITIONS

WARNING !

;MODULE

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f
REQUIRE TYPE>STR ~ygrek/lib/typestr.f

TESTCASES DO-LOOP

:NONAME 10 0 ." [" ?DO I . LOOP ." ]" ; TYPE>STR STR@
S" [0 1 2 3 4 5 6 7 8 9 ]" TEST-ARRAY

:NONAME 0 0  ." [" ?DO I . LOOP ." ]" ; TYPE>STR STR@
S" []" TEST-ARRAY

:NONAME 10 0 ." [" ?DO I . EXIT LOOP ." ]" ; TYPE>STR STR@
S" [0 " TEST-ARRAY

:NONAME 10 0 ." [" ?DO I . LEAVE LOOP ." ]" ; TYPE>STR STR@
S" [0 ]" TEST-ARRAY

:NONAME 10 0 DO CR 10 0 DO J . I . SPACE LOOP LOOP ; TYPE>STR STR@ "
0 0  0 1  0 2  0 3  0 4  0 5  0 6  0 7  0 8  0 9
1 0  1 1  1 2  1 3  1 4  1 5  1 6  1 7  1 8  1 9
2 0  2 1  2 2  2 3  2 4  2 5  2 6  2 7  2 8  2 9
3 0  3 1  3 2  3 3  3 4  3 5  3 6  3 7  3 8  3 9
4 0  4 1  4 2  4 3  4 4  4 5  4 6  4 7  4 8  4 9
5 0  5 1  5 2  5 3  5 4  5 5  5 6  5 7  5 8  5 9
6 0  6 1  6 2  6 3  6 4  6 5  6 6  6 7  6 8  6 9
7 0  7 1  7 2  7 3  7 4  7 5  7 6  7 7  7 8  7 9
8 0  8 1  8 2  8 3  8 4  8 5  8 6  8 7  8 8  8 9
9 0  9 1  9 2  9 3  9 4  9 5  9 6  9 7  9 8  9 9  " STR@ TEST-ARRAY

:NONAME 10 0 DO CR 10 0 DO J . I . SPACE LEAVE LOOP LOOP ; TYPE>STR STR@ "
0 0
1 0
2 0
3 0
4 0
5 0
6 0
7 0
8 0
9 0  " STR@ TEST-ARRAY

:NONAME ." [" 10 0 DO ." |" I . I 5 = IF UNLOOP EXIT THEN LOOP ." ]" ; TYPE>STR STR@
S" [|0 |1 |2 |3 |4 |5 " TEST-ARRAY

10 :NONAME { a -- } ." [" 10 0 DO I a + . LOOP ." ]" ; TYPE>STR STR@
S" [10 11 12 13 14 15 16 17 18 19 ]" TEST-ARRAY

END-TESTCASES