REQUIRE [IF] lib/include/tools.f
REQUIRE STRUCT: lib/ext/struct.f
REQUIRE AUS ~ygrek/lib/aus.f
REQUIRE LOAD-CONSTANTS ~ygrek/~yz/lib/winlib.f
REQUIRE { ~ac/lib/locals.f

[UNDEFINED] TrackMouseEvent [IF] 
WINAPI: TrackMouseEvent USER32.DLL
[THEN]

STRUCT: TRACKMOUSEEVENT
 CELL -- cbSize
 CELL -- dwFlags
 CELL -- hwndTrack
 CELL -- dwHoverTime
;STRUCT


: track-mouse { h tme | tr }
   TEMPAUS TRACKMOUSEEVENT tr
   TRACKMOUSEEVENT::/SIZE DUP ALLOCATE THROW TO tr

    tr. cbSize !
   tme tr. dwFlags !
   h   tr. hwndTrack !
   W: HOVER_DEFAULT tr. dwHoverTime !

   tr TrackMouseEvent ERR IF CR ." track error " . THEN ;

: track-mouse-leave ( h -- ) W: TME_LEAVE track-mouse ;
: track-mouse-hover ( h -- ) W: TME_HOVER track-mouse ;
