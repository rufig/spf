\ 14.Aug.2004 Sat 02:41


REQUIRE .AllStatistic ~pinka\lib\tools\profiler.f
profile off

0 VALUE N

VECT Xt

profile on

: ProfilingXt ( -- )
  Xt
;
: ProfilingXtN ( -- )
  N 0 ?DO Xt LOOP
;

profile off

: CountProfile ( xt -- )
  ResetProfiles  
  TO Xt ProfilingXt
  .AllStatistic
;

: NCountProfile ( xt N -- )
  ResetProfiles  
  TO N TO Xt ProfilingXtN
  .AllStatistic
;
: CountProfileN  NCountProfile ;
