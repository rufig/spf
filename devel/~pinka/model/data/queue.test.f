REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE STHROW    ~pinka/spf/sthrow.f
REQUIRE Wait      ~pinka/lib/multi/Synchr.f
REQUIRE CreateSem ~pinka/lib/multi/Semaphore.f
REQUIRE CREATE-CRIT ~pinka/lib/multi/Critical.f



`events-common.f.xml EMBODY
                     \ paths is relatively to the current directory(!)

`http://forth.org.ru/~pinka/model/data/queue.L1.f.xml EMBODY

 startup FIRE-EVENT

 : T SOURCE TYPE SPACE ." --> " INTERPRET CR ;

  T queue-L1-hidden::pool-idle .
  T 10 enqueueN queue-length .
  T 20 enqueueN queue-length .
  T queue-L1-hidden::pool-idle .
  T dequeueN . queue-length .
  T dequeueN . queue-length .
  T queue-L1-hidden::pool-idle .

  T 30 enqueueN queue-length .
  T dequeueN . queue-length .

OK

\EOF

todo: величину limit (объем всех сообщений) сделать настраиваемой
