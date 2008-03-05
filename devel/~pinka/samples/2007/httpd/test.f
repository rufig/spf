REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f

REQUIRE STHROW    ~pinka/spf/sthrow.f
REQUIRE Wait      ~pinka/lib/multi/Synchr.f
REQUIRE CreateSem ~pinka/lib/multi/Semaphore.f
REQUIRE CREATE-CS ~pinka/lib/multi/Critical.f

[UNDEFINED] InterlockedIncrement [IF]
WINAPI: InterlockedIncrement KERNEL32.DLL
WINAPI: InterlockedDecrement KERNEL32.DLL
[THEN]

[UNDEFINED] GetCurrentThreadId [IF]
WINAPI: GetCurrentThreadId KERNEL32.DLL
[THEN]


[UNDEFINED] BIND-DNODE-TAIL [IF]

`env.f.xml FIND-FULLNAME2 EMBODY       [THEN]

`lib.f.xml FIND-FULLNAME2 EMBODY

`index.f.xml FIND-FULLNAME2 EMBODY

 SocketsStartup THROW


 `701 `localhost tcp-server::assume-listen
 tcp-server::start
 
 
\ : BYE  tcp-server::stop 200 PAUSE BYE ;
