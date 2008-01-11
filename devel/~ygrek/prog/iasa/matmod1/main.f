REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f
\ REQUIRE >FNUM ~ygrek/lib/float-fnum.f


model1.f model2.f model3.f model4.f

PRINT-FIX

: RUN ( addr u ) { \ w s1 s d -- }
   GLWindow :new -> w
   0 w :create
   ( addr u ) w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   Graph2D :new -> s1   
   difur-init 
   #steps s1 :points!
   #steps 0 DO
     runRK \ output CR
     tn fn s1 :point!
   LOOP
   s1 s :add

   \ Горизонтальная линия - стационарная точка
(   Graph2D :new -> s1
    2 2 * 8 * ALLOCATE THROW -> d
    2 d s1 :data!
    2 0 DO
     interval I DS>F F* d DF!   d 8 + -> d
     S" limit" SFIND DROP EXECUTE d DF!          d 8 + -> d
    LOOP
   Magenta s1 <color @ :set
   s1 s :add)

   s :autoScale

   w :show
   w :run 
   w :free
;

WARNING 0!
REQUIRE radio ~ygrek/~yz/lib/winctl.f
TRUE WARNING !


0 VALUE e1T0  0 VALUE e1Tc   0 VALUE e1tau
0 VALUE e2N0  0 VALUE e2K    0 VALUE e2mju
0 VALUE e3N0 0 VALUE e3K   0 VALUE e3r
0 VALUE e4alpha 0 VALUE e4mju 0 VALUE e4g
0 VALUE e4a 0 VALUE e4s 0 VALUE e4k0

0 VALUE times
: -times times this -font! ;
: >float ( ctl -- F: x ) 
  >R 
  R@ -text# ALLOCATE THROW  
  DUP R@ -text@
  DUP 
  R> -text# >FLOAT 0= IF 0e THEN
  FREE THROW
;
\ учитываем что без символа "e" вещественное число не воспринимается
: >fnum >FNUM OVER + DUP [CHAR] e SWAP C! 1+ 0 SWAP C! ;
\ : >fnum >FNUM OVER + 0 SWAP C! ;

GROUP gr

add-graph.f

: main 
  WINDOWS...
  " Times New Roman Cyr" 12 create-font TO times
  0 dialog-window TO winmain
  " Мат моделирование N1. yGREK heretix. КА-21" winmain -text!

  GRID

    grid.f

    hline 500 1 this ctlresize |
    ===
    " График" button -times -center
           add-graph this -command! | 
  GRID; winmain -grid!
  winmain wincenter
  winmain winshow

  fill-edit.f

  ...WINDOWS
\  ." ...WINDOWS"
  BYE
;

main
