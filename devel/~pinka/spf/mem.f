\ 03.Oct.2003 Ruv
\ 02.Aug.2004 перенес код с переопределениями в mem2.f, 
\             тут оставил вариант без дополнительной ячейки для HEAP-ID
\
\ $Id$


REQUIRE [DEFINED] lib/include/tools.f

: HEAP-ID! ( heap -- )
\ установить хип, с которым будут работать ALLOCATE/FREE
  THREAD-HEAP !
;
: HEAP-ID ( -- heap )
\ дать установленный ранее хип для ALLOCATE/FREE
  THREAD-HEAP @
;

\ ===

[DEFINED] GetProcessHeap [IF]

: HEAP-GLOBAL ( -- )
  GetProcessHeap HEAP-ID!
;

[THEN]
