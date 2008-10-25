REQUIRE EMBODY          ~pinka/spf/forthml/index.f
REQUIRE STHROW          ~pinka/spf/sthrow.f
REQUIRE ReadSocketExact ~ac/lib/win/winsock/SOCKETS.F

`~pinka/model/trans/rules-slot.f.xml FIND-FULLNAME EMBODY

`~pinka/model/data/events-common.f.xml FIND-FULLNAME EMBODY

`sedna.f.xml EMBODY

  SocketsStartup THROW
  startup FIRE-EVENT

    open
    S" count( document('auction')//* ) " query-value TYPE CR

