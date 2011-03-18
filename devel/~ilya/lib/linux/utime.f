\ utime.f
REQUIRE tm_sec lib/include/facil.f
1 NSYM: asctime
: U-TIME&DATE ( n -- sec min hr day mt year )
  (( SP@ TM )) localtime_r DROP 
  DROP
  TM tm_sec @
  TM tm_min @
  TM tm_hour @
  TM tm_mday @
  TM tm_mon @ 1 +
  TM tm_year @ 1900 +
;

: ASCTIME 
TM asctime
;
\ 1282083060 U-TIME&DATE ASCTIME 
\EOF
: ft
1282083060 U-TIME&DATE CR .S
S>D <# # # # # DROP 46 HOLD # # DROP 46 HOLD # # DROP 32 HOLD DROP SWAP ROT S>D # # DROP 58 HOLD # # DROP 58 HOLD # # #> CR TYPE
;
ft
