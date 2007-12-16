\ 28-10-2007 ~mOleg
\ тестируем скорость работы алгоритма

 REQUIRE FOR  devel\~mOleg\lib\util\for-next.f
 REQUIRE own  devel\~moleg\lib\util\priority.f

                                   DECIMAL

\ для замера скорости
 REQUIRE ResetProfiles  devel\~pinka\lib\Tools\profiler.f

\ проверит скорость работы выбраного алгоритма
: sample ( --> ) 0x88888888 combs 2DROP ;

realtime own 0= THROW \ не могу установить приоритет

\ замерить скорость работы алгоритма
: test ( --> )
       ResetProfiles
         100 FOR sample TILL
       CR .AllStatistic ;


