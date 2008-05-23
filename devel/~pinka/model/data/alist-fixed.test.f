REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`list-plain.f.xml EMBODY

`event-plain.f.xml EMBODY

`events-common.f.xml EMBODY

`alist-fixed.f.xml EMBODY



 startup FIRE-EVENT

 `some-value-1 `key-1 store-pair
 `some-value-2 `key-2 store-pair
 
 `key-1 2DUP TYPE .(  -- ) obtain-value TYPE CR
 `key-2 2DUP TYPE .(  -- ) obtain-value TYPE CR
 `key-3 2DUP TYPE .(  -- ) obtain-value TYPE CR
  clear-alist
 `key-1 2DUP TYPE .(  -- ) obtain-value TYPE CR
 
 \ shutdown FIRE-EVENT
