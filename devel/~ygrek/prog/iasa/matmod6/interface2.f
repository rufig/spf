ONLY FORTH DEFINITIONS
ALSO Model2 DEFINITIONS

values e_m e_v e_Teta e_mf e_T0 e_time e_timeF sBug ;

: edit-get
    e_Teta >float FTO Teta
    e_m >float FTO m0 
    e_v >float FTO v0
   e_mf >float FTO mf
   e_T0 >float FTO T0
   e_timeF >float FTO tf
 e_time >float FTO show_time
;

: fill-edit
        Teta >fnum e_Teta -text!
        m0 >fnum e_m -text!
        v0 >fnum e_v -text!
        T0 >fnum e_T0 -text!
        mf >fnum e_mf -text!
        tf >fnum e_timeF -text!
show_time >fnum e_time -text!
;

: DRAW1 { \ w s s1 str }
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

\    s :autoScale
   0e xmax ymax FMAX 
   0e FOVER s1 :setScale
   s1 :makeScale

   ALSO Model2 info PREVIOUS

   w :show
   w :run 
   w :free
;


: DRAW2 { \ w s1 s s2 }
   GLWindow :new -> w
   0 w :create
   S" v(t) Скорость от времени" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   prepareRK 
   Graph2D :new -> s1   #steps s1 :points!
   Graph2D :new -> s2   #steps s2 :points!
    Yellow s2 <color @ :set

   #steps 0 DO
     runRK \ output CR
     tn vn s1 :point! 
     tn yn s2 :point!
   LOOP
   s1 s :add
   s2 s :add

    s :autoScale
\   0e xmax ymax FMAX 
\   0e FOVER s1 :setScale
\   s1 :makeScale

   0e tn ymax FMAX 
   0e FOVER s2 :setScale
   s2 :makeScale  

   w :show
   w :run 
   w :free
;

PROC: add-1 
 edit-get
 DRAW1
 ." Model2 finish "
PROC;


PROC: add-2 
 edit-get
 DRAW2
PROC;


ONLY FORTH DEFINITIONS

