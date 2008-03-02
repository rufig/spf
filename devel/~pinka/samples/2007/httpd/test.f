REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f

REQUIRE Wait      ~pinka/lib/multi/Synchr.f
REQUIRE CreateSem ~pinka/lib/multi/Semaphore.f
REQUIRE CREATE-CS ~pinka/lib/multi/Critical.f


: STHROW ( addr u -- )  ER-U ! ER-A ! -2 THROW ;

: SCATCH ( -- addr u true | false ) 
  CATCH
  DUP 0EQ IF EXIT THEN
  DUP -2 NEQ IF THROW THEN
  DROP ER-A @ ER-U @ TRUE
;


[UNDEFINED] BIND-DNODE-TAIL [IF]

`env.f.xml FIND-FULLNAME2 EMBODY       [THEN]

`lib.f.xml FIND-FULLNAME2 EMBODY

`index.f.xml FIND-FULLNAME2 EMBODY

 SocketsStartup THROW


 `701 `localhost tcp-server::open tcp-server::start
 
