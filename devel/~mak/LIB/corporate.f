.( Corporate multitask )

REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE { ~mak\locals.f

USER STATUS
USER FOLLOWER
USER TOS
USER _R0
USER *BIG-PAUSE*
USER *END-PAUSE*

' NOOP *END-PAUSE* !
' NOOP *BIG-PAUSE* !

TlsIndex@ CONSTANT CONUSER


STATUS FOLLOWER !

: LOCAL         ( tid a | tid a -- a ) ( index another task's local variable )
                TlsIndex@ - ( address to offset )
                + ; ( offset to address )


: _PASS         ( STATUS -- ) ( hilevel absolute branch )
    CELL+ \    FOLLOWER
    @ DUP @ >R ;

' _PASS CONSTANT PASS

: BIG-PAUSE_ 
  RP@  _R0 @  R0 @ RP@ - -   R0 @ RP@ -  CMOVE
       _R0 @  R0 @ RP@ - -   RP!
;

: END-PAUSE_
  [ TOS ] LITERAL @ @ CELL-   R0 !
  RP@   R0 @ _R0 @ RP@ - -   _R0 @ RP@ -  CMOVE
        R0 @ _R0 @ RP@ - -    RP!
;

: _WAKE         ( STATUS -- ) ( restore follower )
    [  CONUSER STATUS - ] LITERAL +
  TlsIndex!  TOS @ SP! RP! *END-PAUSE* @ EXECUTE ;

' _WAKE CONSTANT WAKE

WAKE STATUS !

: C_PAUSE         ( -- ) ( allow another task to execute )
   *BIG-PAUSE* @ EXECUTE  RP@ SP@ TOS !  FOLLOWER @ DUP @ >R ;

: C_STOP          ( -- ) ( sleep current task )
                PASS STATUS ! C_PAUSE ;


: SLEEP         ( tid -- ) ( sleep another task )
                PASS SWAP STATUS LOCAL ! ;

: AWAKE         ( tid -- ) ( wake another task )
                WAKE SWAP STATUS LOCAL ! ;

: ACTIVATE      ( tid -- )
                R>
                OVER TOS LOCAL @ @ !      ( save sp in tos )
                AWAKE ;


: NEWTASK    { u s r \ tid size -- tid }
          USER-HERE u + s + r + TO size
          size 16 + ALLOCATE THROW TO tid
          CONUSER tid USER-HERE CMOVE
          tid size +    \ RP
          DUP CELL+ _R0 tid LOCAL !
          DUP     r -   \ RP SP
          DUP  S0 tid LOCAL !
          DUP TOS tid LOCAL !  !
          ['] END-PAUSE_ *END-PAUSE* tid LOCAL !
          ['] BIG-PAUSE_ *BIG-PAUSE* tid LOCAL !
          tid
;

\ initialize task tid, and put it to sleep

: ALSOTASK      ( tid -- )
                DUP  CONUSER =
                IF DROP EXIT THEN       ( not main task )
                DUP SLEEP                             ( sleep new task )
                FOLLOWER @ OVER FOLLOWER LOCAL !      ( link new task )
                STATUS LOCAL FOLLOWER ! ;             ( link old task )

: ONLYTASK      ( -- ) ( initialize main task )
                CONUSER TlsIndex!
                STATUS FOLLOWER !  AWAKE ;


' EKEY? 1+ REL@ CELL+ ' _VECT-CODE <>
[IF] S" ~mak\lib\key\accept.f" INCLUDED
       ACCEPTInit
     ' M_ACCEPT TO ACCEPT
[THEN]

: MULTI-EKEY? C_PAUSE [ ' EKEY? >BODY @ COMPILE, ] ;

: MULTI         ( -- )          \ enable multi-tasking
                ['] MULTI-EKEY? TO EKEY? ;

: SINGLE        ( -- )          \ disable multi-tasking
                [ ' EKEY? >BODY @ ] LITERAL TO EKEY? ;

\EOF TEST

0 400 1000 NEWTASK CONSTANT T1
 T1 ALSOTASK

: T1GO ( -- )
  T1 ACTIVATE DECIMAL 0
  BEGIN   1+ DUP >R AT-XY? 0 0 AT-XY R> . AT-XY  C_PAUSE
  AGAIN ;

T1GO
 MULTI
