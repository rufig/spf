\ 03.Sep.2004 Fri 07:32

REQUIRE [UNDEFINED]  lib\include\tools.f

: TRANSLATE-WL ( ... a u wid -- ... true|false )
\ транслировать слово с именем  a u из словаря wid
  SEARCH-WORDLIST  DUP IF
    STATE @ =  IF
    COMPILE,   ELSE 
    EXECUTE    THEN 
    TRUE               THEN
;

USER uFOUND-IMMED

: FOUND-IMMED ( -- flag )
  uFOUND-IMMED @
;
: SCOMPILE, ( a u -- )
  SFIND DUP IF -1 <> uFOUND-IMMED !
    COMPILE,
  ELSE -321 THROW THEN
;
: SIMMED? ( a u -- flag )
  SFIND DUP IF NIP -1 <> DUP uFOUND-IMMED !
  ELSE -321 THROW THEN
;
: SEXECUTE ( a u -- )
  SFIND DUP IF -1 <> uFOUND-IMMED !
    EXECUTE
  ELSE -321 THROW THEN
;

