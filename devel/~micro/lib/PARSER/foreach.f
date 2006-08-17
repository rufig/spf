REQUIRE STR>MEM ~micro/lib/strmem.f

: ForEachLineTo ( xt addr u -- )
  STR>MEM >R
  >R
  BEGIN
    REFILL 0= ABORT" Unexpected end of file" 
    NextWord 2R@ DROP COUNT COMPARE
  WHILE
    >IN 0!
    R@ EXECUTE
  REPEAT
  RDROP RDROP
;

: ForEachLineTo"
  [CHAR] " PARSE ForEachLineTo
;

: ForEachLine
  S" ;" ForEachLineTo
;

: ToAll
  ' >R
  BEGIN
    >IN @
    NextWord NIP
  WHILE
    >IN !
    R@ EXECUTE
  REPEAT
  RDROP
  DROP
;

 