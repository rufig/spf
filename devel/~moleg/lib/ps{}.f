\. 21-07-2004 à¥ «¨§ æ¨ï ¨á¯®«­¨¬ëå ¬ áá¨¢®¢ ¤«ï ¯®áâáªà¨¯â 

Unit: eArray

\ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

\      5 CONSTANT nesting

CREATE nStack 0 , nesting CELLS ALLOT

: n-- ( --> )
      nStack DUP @
      IF 1-!
       ELSE TRUE ABORT" n underflow!"
      THEN ;

: n++ ( --> )
      nStack DUP @ nesting <
      IF 1+!
       ELSE TRUE ABORT" n overflow!"
      THEN ;

: nd  ( --> ) nStack @ ;
: na  ( --> ) nStack DUP @ CELLS + ;
: n>  ( --> ) na @ DP !  n-- ;
: >n  ( --> ) n++ HERE na ! ;

\ ÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ

\    1000 CONSTANT def#

F: :def ( --> addr )
       def# ALLOCATE THROW
       >n DP ! :NONAME ;F

F: ;def ( addr --> addr )
       [COMPILE] ;
       HERE OVER - RESIZE THROW
       n> nd IF ] THEN
       ;F
EndUnit

\EOF

\ ­ ç âì ®¯¨á ­¨¥ ¨á¯®«­ï¥¬®£® ¬ áá¨¢ 
: { % ( --> addr )
    eArray :def ; IMMEDIATE

\ § ª®­ç¨âì ®¯¨á ­¨¥ ¨á¯®«­ï¥¬®£® ¬ áá¨¢ 
: } % ( addr --> obj )
    eArray ;def
    psObject token
    ?compName
    ; IMMEDIATE
