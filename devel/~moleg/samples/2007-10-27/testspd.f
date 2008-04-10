\ 28-10-2007 ~mOleg
\ тестируем скорость работы алгоритма

 REQUIRE ?DEFINED       devel\~moleg\lib\util\ifdef.f
?DEFINED similar CR .( use: spd.bat sample.f |enter ) BYE

 REQUIRE ResetProfiles  devel\~pinka\lib\Tools\profiler.f


: SIMILAR similar ;

: alll ( --> )
       CONTEXT @ @ >R
       BEGIN R@ WHILE
             CR R@ COUNT SIMILAR
         R> CDR >R
       REPEAT RDROP
       ;

: test  ResetProfiles alll alll alll CR CR .AllStatistic ;
