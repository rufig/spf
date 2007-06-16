\ 15-06-2007 ~mOleg
\ Copyright [C] 2007 mOleg mininoleg@yahoo.com
\ обработка параметров командной строки

 REQUIRE ?DEFINED  devel\~moleg\lib\util\ifdef.f
 REQUIRE SEAL      devel\~moleg\lib\util\useful.f
 REQUIRE cmdline>  devel\~mOleg\lib\util\parser.f
 REQUIRE VLIST     devel\~mOleg\lib\util\words.f

  VOCABULARY SPELLS  \ словарь для хранений опций командной строки
  VOCABULARY SECRET  \ словарь, в котором хранятся секретные опции

\ начать описание заклинания
: SPELL: ( --> ) ALSO SPELLS DEFINITIONS : PREVIOUS ;

\ начать описание секретного заклинания
: SECRET: ( --> ) ALSO SECRET DEFINITIONS : PREVIOUS ;

\ завершить создание заклинания
: ;S ( --> ) [COMPILE] ; DEFINITIONS ; IMMEDIATE

\ -- скрытые заклинания -----------------------------------------------------

\ иногда хочется уметь попасть в консоль
SECRET: ~ ( --> ) ONLY ." My Master" CR QUIT BYE ;S

\ если опция не опознана - отображаем ошибку и машем ручкой
SECRET: NOTFOUND ( asc # --> ) ." invalid spell: " TYPE BYE ;S

\ -- открытые заклинания ----------------------------------------------------

\ отобразить список заклинаний
SPELL: -? ( --> ) ." spells are: " CONTEXT @ 1 VLIST BYE ;S

\ добавляем все необходимые заклинания
SPELL: --help ( --> ) ." add any spells you need." CR ;S

\ ---------------------------------------------------------------------------

\ обработать опции командной строки
: options ( --> )
          SECRET SEAL ALSO SPELLS cmdline>
          SeeForw IF DROP ['] INTERPRET CATCH ELSE DROP TRUE THEN

          ( --> err|0 )
          \ тут должен быть вызов главного слова, если только оно
          \ не запускается по NOTFOUND или ключем.

         BYE ;

\ ' options MAINX ! S" sample.exe" SAVE

?DEFINED test{ \EOF -- тестовая секция ---------------------------------------

test{
  S" passed" TYPE
}test

