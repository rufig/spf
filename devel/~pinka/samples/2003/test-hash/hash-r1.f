\ 01.Nov.2003 Sat 15:07 ruv
\ from   Arc\work\Forth\SPF\devel\~pinka\hash\search-wordlist.f    at 16.11.2000
\ и подзаточено..

REQUIRE { lib\ext\locals.f

: HASH { a u u1 \ h -- u2 } 
 0 -> h    a u + -> u
 BEGIN a u < WHILE
   h 5 LSHIFT 1+ a C@ +   -> h  a 1+ -> a
   h ?DUP IF 0x80000000 AND 1 AND  h XOR -> h THEN
 REPEAT  h
 u1 IF u1 UMOD THEN
;
