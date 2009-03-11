REQUIRE EMBODY    ~pinka/spf/forthml/index.f

REQUIRE STHROW    ~pinka/spf/sthrow.f


`list-plain.f.xml EMBODY

`events-common.f.xml EMBODY

`wordstack.f.xml EMBODY


startup FIRE-EVENT

  10 `n1 push-word
  20 `n2 push-word
  
  `n1 find-word . . CR
  `n2 find-word . . CR

  
  drop-word

  `n1 find-word . . CR
  `n2 find-word . TYPE CR
