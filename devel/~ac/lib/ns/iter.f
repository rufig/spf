REQUIRE ForEachDirWR ~ac/lib/ns/iterators.f
REQUIRE STR@         ~ac/lib/str5.f

: ForEachDirWRstr { str xt wid \ s -- }
\ xt: ( str item wid -- )
\ перебрать рекурсивно все словари, передавая в xt полный путь к словарю (str)
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
\ : swid. ( str item wid -- ) 2DROP ( WNAME TYPE ." :") STR@ TYPE CR ;
\ " FORTH" ' swid. FORTH-WORDLIST ForEachDirWRstr

: ForEachWRI { id xt wid \ id2 -- }
\ xt: ( id1 item wid -- id2 )
\ перебрать рекурсивно все словари и слова, передавая в xt id, вычисленный
\ xt родительского словаря (удобно для копирования с сохранением иерархии,
\ для замера макс.глубины вложенности и т.п.)
  wid CAR
  BEGIN
    DUP
  WHILE
    id OVER wid xt EXECUTE -> id2
    DUP wid W?VOC
    IF DUP id2 xt ROT wid ITEM>WID RECURSE THEN
    wid WCDR
  REPEAT DROP
;

\ : swidi. ( id item wid -- ) WNAME TYPE ." :" DUP . 1+ ;
\ 0 ' swidi. FORTH-WORDLIST ForEachWRI
