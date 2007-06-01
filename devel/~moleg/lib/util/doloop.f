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

REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
REQUIRE COMPILE   devel\~moleg\lib\util\compile.f

FALSE WARNING !
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

\ приращение счетчика цикла, проверка условия выхода из цикла. »
: (+LOOP) ( n --> flag )
          DUP 0 < IF    2R> ROT R> + R@ OVER >R <
                   ELSE 2R> ROT R> + R@ OVER >R < 0=
                  THEN -ROT 2>R ;

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

TRUE WARNING !

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : simple 10 DUP DUP 0 DO DROP I LOOP 1 + <> THROW ; simple
      : test?do DEPTH >R 0 0 ?DO I LOOP DEPTH R> <> THROW ; test?do
      : testlv 3 DO I LEAVE LOOP ;
      : testleave 10 testlv 3 <> THROW ; testleave
      : testij 10 3 DO 10 3 DO I J UNLOOP LEAVE LOOP LOOP <> THROW ; testij
  S" passed" TYPE
}test
