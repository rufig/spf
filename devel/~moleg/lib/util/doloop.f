\ 22-02-2007 ~mOleg
\ Copyright [C] 2006-2007 mOleg mininoleg@yahoo.com
\ циклы DO LOOP для СПФ - портабельный вариант.

\ ВНИМАНИЕ для совместимости с библиотекой lib\ext\locals.f
\ необходимо, чтобы локалсы были загружены перед этой библиотекой

 REQUIRE COMPILE   devel\~moleg\lib\util\compile.f

?DEFINED [IF] lib\include\tools.f

TRUE ?DEFINED vocLocalsSupport DROP FALSE
[IF]
   ALSO vocLocalsSupport DEFINITIONS ALSO FORTH
     : DO    FORTH::POSTPONE DO     [  4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
     : ?DO   FORTH::POSTPONE ?DO    [  4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
     : LOOP  FORTH::POSTPONE LOOP   [ -4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
     : +LOOP FORTH::POSTPONE +LOOP  [ -4 CELLS ] LITERAL  uAddDepth +! ; IMMEDIATE
   PREVIOUS PREVIOUS DEFINITIONS
[THEN]

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

\ выход из цикла по EXIT
: exitdo ( --> ) RDROP RDROP RDROP ;

\ установили параметры цикла - выполняется один раз на входе
: (DO) ( up low --> ) R> -ROT 2>R ['] exitdo >R >R ;

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

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{ : simple 10 DUP DUP 0 DO DROP I LOOP 1 + <> THROW ; simple
      : test?do DEPTH >R 0 0 ?DO I LOOP DEPTH R> <> THROW ; test?do
      : testlv 3 DO I LEAVE LOOP ;
      : testleave 10 testlv 3 <> THROW ; testleave
      : testij 10 3 DO 10 3 DO I J UNLOOP LEAVE LOOP LOOP <> THROW ; testij
      : testexit 10 1 DO 20 9 DO EXIT LOOP LOOP -1 THROW ; testexit

  S" passed" TYPE
}test
