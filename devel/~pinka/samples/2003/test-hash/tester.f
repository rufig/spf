\ 01.Nov.2003 Sat 16:06

REQUIRE MARKER  lib\include\core-ext.f

REQUIRE [IF] lib\include\tools.f
REQUIRE {    lib\ext\locals.f
REQUIRE ""   ~ac\lib\str2.f


: HS ( a u -- )  \ hash stat
  S" make1.f" INCLUDED
;
: hs ( "ccc" -- )  \ hash stat
  NextWord " {s}" STR@  HS
;
WARNING  0!

hs hash-r2.f
hs hash-day3.f 
hs hash-core.f
hs hash-day2.f 
hs hash-Elf.f
\ hs hash-r1.f
\ hs hash-day.f
