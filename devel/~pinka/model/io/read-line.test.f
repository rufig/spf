REQUIRE EMBODY    ~pinka/spf/forthml/index.f


[UNDEFINED] BIND-DNODE-TAIL [IF]

`../data/list-plain.f.xml EMBODY    [THEN]

`../data/event-plain.f.xml EMBODY

`../data/events-common.f.xml EMBODY


  :NONAME H-STDIN READOUT-FILE THROW ; `read-line.f.xml EMBODY

 startup FIRE-EVENT

 .( Enter 3 lines: ) CR

next-line? . TYPE CR
next-line? . TYPE CR
next-line? . TYPE CR .( tnx ) OK

 \ shutdown FIRE-EVENT
