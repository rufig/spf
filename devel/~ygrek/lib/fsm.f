\ Finite State Machine
\ very lame implementation

0
CELL -- #col \ number of columns/inputs
CELL -- #state \ current internal state
CELL -- $table \ the table goes from this address
DROP

0 \ Each cell of the FSM contains the action and the next state to switch to
CELL -- .xt \ FSM action ( i*x -- )
CELL -- .tr \ transition to the next state
CONSTANT /cell

0 VALUE now:col
0 VALUE now:state

: FSM: ( #col "name" -- )
 CREATE , 0 ,
 DOES> ( i*x col addr ) 
  >R
  R@ #col @
  2DUP < 0= IF ABORT" bad col" THEN
  DUP TO now:col
  R@ #state @ 
  DUP TO now:state
  * +
  /cell * R@ $table +
  DUP .tr @ R> #state !
      .xt @ EXECUTE ;

: FSM; 
   LATEST NAME> >BODY >R 
   HERE R@ $table -
   R> #col @ /cell * MOD 0 <> IF ." Table not full!" CR ABORT THEN ;

: || NextWord SFIND 0= IF ABORT" Not found" THEN , NextWord EVALUATE , ;

\EOF

: classify-filter
   DUP 13 = IF 1 EXIT THEN
   DUP 27 = IF 2 EXIT THEN
   0 ;

3 FSM: fsm-filter
|| EMIT 0  || DROP 0   || BYE 0 
FSM;

: go-filter classify-filter fsm-filter ;

: classify-zxc ( ch -- ch n )
   DUP [CHAR] . = IF 1 EXIT THEN
   0 ;

2 FSM: zxc
\ 0               1
|| go-filter 0   || EMIT 1   \ initial
|| go-filter 1   || DROP 1   \ met dot already
FSM;
 
: go
  BEGIN
   KEY classify-zxc zxc
  AGAIN
;

go

