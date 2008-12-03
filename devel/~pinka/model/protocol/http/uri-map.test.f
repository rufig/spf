REQUIRE EMBODY    ~pinka/spf/forthml/index.f

`http://forth.org.ru/~pinka/model/data/list-plain.f.xml EMBODY
`http://forth.org.ru/~pinka/model/trans/rules-slot.f.xml EMBODY

`uri-map.f.xml EMBODY

: t1 ." t1: " pathname TYPE CR TRUE  ;  ' t1 add-handler
: t2 ." t2  "               CR FALSE ;  ' t2 add-handler

:NONAME ." key1: " pathname TYPE CR ; `key1 add-segment-handler

 S" test/passed" dispatch-pathname . CR CR

 S" key1/key2/key3" dispatch-pathname . CR CR
