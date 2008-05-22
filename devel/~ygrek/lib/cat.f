\ $Id$
\ 
\ read file without querying its size 
\ useful for linux virtual fs e.g. /proc

REQUIRE STR+ ~ac/lib/str5.f

\ you must always STRFREE resulting str even if ior is not zero
: __cat ( a u -- str ior )
  R/O OPEN-FILE DUP IF NIP "" SWAP EXIT THEN
  DROP >R
  ""
  BEGIN
   PAD 1024 R@ READ-FILE DUP IF NIP R> CLOSE-FILE DROP EXIT THEN
   DROP
   DUP 0= IF DROP 0 R> CLOSE-FILE DROP EXIT THEN
   OVER PAD -ROT STR+
  AGAIN ;

: cat __cat DROP ;

