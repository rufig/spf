REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE STHROW    ~pinka/spf/sthrow.f
REQUIRE Wait      ~pinka/lib/multi/Synchr.f
REQUIRE CreateSem ~pinka/lib/multi/Semaphore.f
REQUIRE CREATE-CS ~pinka/lib/multi/Critical.f

\ WINAPI: InterlockedIncrement KERNEL32.DLL
\ WINAPI: InterlockedDecrement KERNEL32.DLL


\ paths is relatively to current directory(!)

`list-plain.f.xml EMBODY

`event-plain.f.xml EMBODY

`events-common.f.xml EMBODY

`pool.L1.f.xml EMBODY


 startup FIRE-EVENT

 10 release-worker pool-idle . CR
 20 release-worker pool-idle . CR
 30 release-worker pool-idle . CR

 hire-worker . pool-idle . CR
 hire-worker . pool-idle . CR
 hire-worker . pool-idle . CR

 900 wait-worker . CR

 \ shutdown FIRE-EVENT
