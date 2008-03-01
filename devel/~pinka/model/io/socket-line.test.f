REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f

[UNDEFINED] BIND-DNODE-TAIL [IF]

`../data/list-plain.f.xml EMBODY    [THEN]

`../data/event-plain.f.xml EMBODY

`../data/events-common.f.xml EMBODY




: READOUT-SOCK ( a u1 h -- a u2 ior )
  >R OVER SWAP R> 
  ( a a h1 h )
  ReadSocket ( a u2 ior )
  DUP -1002 = IF 2DROP 0. THEN
;


`socket-line.f.xml   EMBODY


 SocketsStartup THROW

 startup FIRE-EVENT
 
 


 \ shutdown FIRE-EVENT
