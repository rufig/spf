REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE Wait      ~pinka/lib/multi/Synchr.f
REQUIRE CreateSem ~pinka/lib/multi/Semaphore.f
REQUIRE CREATE-CS ~pinka/lib/multi/Critical.f


\ paths is relatively to the current directory(!)

`list-plain.f.xml EMBODY

`event-plain.f.xml EMBODY

`events-common.f.xml EMBODY

`queue.L1.f.xml EMBODY


 startup FIRE-EVENT

 : T SOURCE TYPE SPACE ." --> " INTERPRET CR ;

  T queue-L1-hidden::pool-idle .
  T 10 enqueueN queue-length .
  T 20 enqueueN queue-length .
  T queue-L1-hidden::pool-idle .
  T dequeueN . queue-length .
  T dequeueN . queue-length .
  T queue-L1-hidden::pool-idle .
