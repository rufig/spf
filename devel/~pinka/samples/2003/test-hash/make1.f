( a u -- )
 MARKER qqq_forget1

  \ HashDefinition NIP        [IF]
  \ HashDefinition INCLUDED   [THEN]

H-STDOUT 0 TO H-STDOUT
\ DIS-OPT
REQUIRE GetTimes  ~pinka\lib\Tools\profiler.f  profile off
\ SET-OPT
TO H-STDOUT

profile on
  2DUP TYPE CR
  INCLUDED
profile off

  S" test-hash.f" INCLUDED
  S" wl.txt" rcv
  stat.  S" HASH" GetTimes [IF] DROP 16 UD.RS  [THEN]
  CR

 qqq_forget1
