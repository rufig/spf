REQUIRE EMBODY    ~pinka/spf/forthml/index.f
REQUIRE STHROW    ~pinka/spf/sthrow.f

`lib-r.f.xml EMBODY

\ `~pinka/model/data/data-space.f.xml FIND-FULLNAME EMBODY

\ 50000 ALLOCATED DATASPACE!

: put TYPE ;


`~pinka/model/data/list-plain.f.xml  FIND-FULLNAME EMBODY

`~pinka/model/data/event-plain.f.xml FIND-FULLNAME EMBODY

`~pinka/model/data/events-common.f.xml FIND-FULLNAME EMBODY

`index.f.xml EMBODY

 startup FIRE-EVENT

 S" test passed" Reply200txt CR

