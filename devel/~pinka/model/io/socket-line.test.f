REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE ReadSocket ~ac/lib/win/winsock/sockets.f

: READOUT-SOCK ( a u1 h -- a u2 ior )
  >R OVER SWAP R> 
  ( a a h1 h )
  ReadSocket ( a u2 ior )
  DUP -1002 = IF 2DROP 0. THEN
;

`../data/events-common.f.xml EMBODY

`socket-line.f.xml   EMBODY


 SocketsStartup THROW

 startup FIRE-EVENT
 
 


 \ shutdown FIRE-EVENT
