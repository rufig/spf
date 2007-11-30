\ $Id$
\ 
\ Распознавание вещественных чисел
\ - Числа вида 12.34e - на float стек (lib/include/float2.f)
\ - Числа вида 12.34f - на стек данных (в вещественном IEEE формате 4 байта)
\ - Числа вида 12.34d - на стек данных (в вещественном IEEE формате 8 байт) - двойное значение

\ NB В связи с тем что float2.f распознаёт числа 12.3d также как и 12.3e то эта либа может нарушить совместимость.

REQUIRE enqueueNOTFOUND ~pinka/samples/2006/core/trans/nf-ext.f
REQUIRE \1 ~ygrek/lib/re/ext.f
REQUIRE COMPARE-U ~ac/lib/string/compare-u.f
REQUIRE replace-str- ~pinka/samples/2005/lib/replace-str.f
REQUIRE >FLOAT lib/include/float2.f

:NONAME { a u | s -- }
  a u RE" [-+]?\d+(.?\d*)?([fFdD])([-+]?\d+)?" re_match? NOT IF a u FALSE EXIT THEN
  a u " {s}" -> s
  s \2 " {s}" " e" replace-str- 
  s STR@ >FLOAT NOT IF s STRFREE a u FALSE EXIT THEN
  s STRFREE
  \2 S" f" COMPARE-U 0 = IF
   FLOAT>DATA32 POSTPONE LITERAL
  ELSE
   FLOAT>DATA SWAP POSTPONE 2LITERAL
  THEN
  TRUE ; preemptNOTFOUND

\ -------------------------------------------------

/TEST

REQUIRE TESTCASES ~ygrek/lib/testcase.f

: stk ( i*x n*x n -- n*x ) N>R S0 @ SP! NR> DROP ;
: ff DEPTH FDEPTH 2 stk FINIT ;

TESTCASES auto float literals
(( 12.34e     ff -> 0 1 ))
(( 12.34E+01  ff -> 0 1 ))
(( 12.34f     ff -> 1 0 ))
(( 12.34d     ff -> 2 0 ))
(( 12.34F-200 ff -> 1 0 ))
(( 12.34D3    ff -> 2 0 ))
(( 12.f-2     ff -> 1 0 ))
(( 0.12d      ff -> 2 0 ))
(( 12.f123    ff -> 1 0 ))
(( 12d3       ff -> 2 0 ))
(( +0.12f     ff -> 1 0 ))
(( +12d-3     ff -> 2 0 ))
(( -0.12f     ff -> 1 0 ))
(( -12d-3     ff -> 2 0 ))
(( -1.2f-3    ff -> 1 0 ))
(( -1.d-3     ff -> 2 0 ))
END-TESTCASES
