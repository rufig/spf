ONLY FORTH DEFINITIONS
ALSO Model1 DEFINITIONS

values e_m e_v e_Teta e_S e_time sBug ;

: edit-get
    e_Teta >float FTO Teta
    e_m >float FTO m 
    e_v >float FTO v
    e_S >float FTO S
 e_time >float FTO show_time
;

: fill-edit
        Teta >fnum e_Teta -text!
        m >fnum e_m -text!
        v >fnum e_v -text!
        S >fnum e_S -text!
show_time >fnum e_time -text!
;

: DRAW1 { \ w s1 s }
   GLWindow :new -> w
   0 w :create
   S" y(x) высота дальность" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   prepareRK 
   Graph2D :new -> s1   #steps s1 :points!
   #steps 0 DO
     runRK \ output CR
     xn yn s1 :point!
   LOOP
   s1 s :add

   s :autoScale

   ALSO Model1 info PREVIOUS

   w :show
   w :run 
   w :free
;


: DRAW2 { \ w s1 s }
   GLWindow :new -> w
   0 w :create
   S" v(t) Скорость от времени" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   prepareRK 
   Graph2D :new -> s1   #steps s1 :points!
   #steps 0 DO
     runRK \ output CR
     tn vn s1 :point! 
   LOOP
   s1 s :add

   s :autoScale

   w :show
   w :run 
   w :free
;

PROC: add-1 
 edit-get
 ." Model1: " Teta F. SPACE m F. SPACE v F. CR
 DRAW1
PROC;


PROC: add-2 
 edit-get
 DRAW2
PROC;


ONLY FORTH DEFINITIONS

