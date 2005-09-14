REQUIRE ForEachDirWR ~ac/lib/ns/iterators.f
REQUIRE STR@         ~ac/lib/str5.f

: ForEachDirWRstr { str xt wid \ s -- }
\ xt: ( str item wid -- )
  wid CAR
  BEGIN
    DUP
  WHILE
    DUP wid W?VOC
    IF 
       DUP wid WNAME str STR@ ?DUP IF " {s}/{s}" ELSE DROP " {s}" THEN -> s
       DUP s xt ROT wid ITEM>WID RECURSE
       DUP s SWAP wid xt EXECUTE s STRFREE
    THEN
    wid WCDR
  REPEAT DROP
;
: swid. ( str item wid -- ) 2DROP ( WNAME TYPE ." :") STR@ TYPE CR ;

\ " FORTH" ' swid. FORTH-WORDLIST ForEachDirWRstr

