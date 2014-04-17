REQUIRE EMBODY          ~pinka/spf/forthml/index.f
REQUIRE TRHOW-DUMP      ~pinka/spf/throw-dump.f
REQUIRE STHROW          ~pinka/spf/sthrow.f
REQUIRE ReadSocketExact ~ac/lib/win/winsock/SOCKETS.F

`~pinka/model/trans/rules-slot.f.xml FIND-FULLNAME EMBODY

`~pinka/model/data/events-common.f.xml FIND-FULLNAME EMBODY

`sedna.f.xml EMBODY

  SocketsStartup THROW
  startup FIRE-EVENT

: init-cred ( -- )
  `SYSTEM `MANAGER `auction `localhost `5050
  assume-cred
; 
    init-cred
    open
    S" count( document('auction')//* ) " query-value TYPE CR

