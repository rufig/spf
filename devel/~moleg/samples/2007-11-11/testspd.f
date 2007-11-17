\ 28-10-2007 ~mOleg
\ тестируем скорость работы алгоритма

 REQUIRE FOR  devel\~mOleg\lib\util\for-next.f
 REQUIRE own  priority.f
                                   DECIMAL

 16000 CONSTANT #array   \ размер массива в ячейках

       CREATE array      \ сам массив начинается отсюда
            #array CELLS ALLOT

 \ проверка коректности работы:
 HEX 12345678 SP@ 1 revarr 1E6A2C48 <> THROW
     87654321 SP@ 1 revarr 84C2A6E1 <> THROW
 DECIMAL

 REQUIRE ?DEFINED       devel\~moleg\lib\util\ifdef.f
 REQUIRE RANDOM         devel\~day\common\RND.F

\ заполнить массив случайными числами
: filarr ( --> ) array #array FOR RANDOM OVER ! CELL + TILL DROP ;

\ для замера скорости
 REQUIRE ResetProfiles  devel\~pinka\lib\Tools\profiler.f

\ реверс порядка бит для каждой ячейки массива
: sample ( --> ) array #array revarr ;

realtime own 0= THROW \ не могу установить приоритет

: test ( --> )
       filarr
         ResetProfiles
         100 FOR sample TILL
        CR .AllStatistic ;

normal own DROP
