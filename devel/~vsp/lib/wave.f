\ Проиграть звуковой wav-файл
\ (c) Валентин Первых, 17 февраля 2004, вторник, 23:34

REQUIRE LOAD-CONSTANTS ~yz/lib/const.f
S" ~vsp/cons/mmedia.const" LOAD-CONSTANTS

WINAPI: PlaySound WINMM.DLL

: play-wav ( s -- )
  DROP >R (* SND_NODEFAULT SND_FILENAME *) 0 R> PlaySound DROP ;

: play-asynchro-wav ( s -- )
  DROP >R W: SND_FILENAME W: SND_ASYNC OR W: SND_NODEFAULT OR 0 R> 
  PlaySound DROP ;

: play-system-event-sound ( s -- )
 DROP >R (* SND_SYNC SND_ASYNC *) 0 R> PlaySound DROP
;

: play-synchro-system-event-sound ( s -- )
  DROP >R (* SND_SYNC SND_SYNC *) 0 R> PlaySound DROP ;


: stop-wave W: SND_APPLICATION 0 0 PlaySound DROP ;

\ S" SYSTEMEXIT" play-system-event-sound