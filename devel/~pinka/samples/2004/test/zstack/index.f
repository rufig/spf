\ 02.Sep.2004 

REQUIRE >CELLS  ~pinka\lib\core-ext.f 

S" common.f" INCLUDED
S" zstack.f" INCLUDED
S" vfm.f"    INCLUDED

\ ---

: OK2
  STATE @ 0=
  IF
    ZDEPTH 6 < IF
                 ZDEPTH IF ."  Ok ( " ZDEPTH .ZN  ." )" CR
                       ELSE ."  Ok" CR
                       THEN
               ELSE ."  Ok ( [" ZDEPTH 0 <# #S #> TYPE ." ].. "
                    5 .ZN ." )" CR
               THEN
  THEN
;

' OK2 TO OK

: ZQUIT ( -- ) ( R: i*x ) \ CORE 94
  BEGIN
    [COMPILE] [
    ['] MAIN1 CATCH
    ['] ERROR CATCH DROP
    S0 @ SP!
    ZS0 ZSP!
  AGAIN
;


' ZQUIT TO <MAIN>

.( Type WORDS  to print what you have ;]) CR

ONLY ZOP DEFINITIONS
