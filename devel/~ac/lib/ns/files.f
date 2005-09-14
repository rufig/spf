REQUIRE FIND-FILES-R      ~ac/lib/win/file/findfile-r.f 
REQUIRE ForEachDirWRstr   ~ac/lib/ns/iter.f

: FileExists ( addr u -- flag )
  R/O OPEN-FILE-SHARED ?DUP
  IF NIP DUP 2 =
        OVER 3 = OR
        OVER 206 = OR 
        SWAP 123 = OR
        0=
  ELSE CLOSE-FILE THROW TRUE
  THEN
;
<<: FORTH FIL
>> CONSTANT FIL-WL

<<: FORTH DIR
: SEARCH-WORDLIST { c-addr u oid -- 0 | xt 1 | xt -1 }

\ сначала ищем в методах класса
  c-addr u [ GET-CURRENT ] LITERAL SEARCH-WORDLIST ?DUP IF EXIT THEN

  c-addr u oid OBJ-NAME@ " {s}\{s}" STR@ ...
;
>> CONSTANT DIR-WL
