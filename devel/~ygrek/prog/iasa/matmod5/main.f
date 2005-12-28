\ Колебания
\ Математическое моделирование
\ (c) yGREK Heretix mailto:heretix@yandex.ru
\ 21.Apr.2005

REQUIRE runRK         ~ygrek/lib/difur.f
REQUIRE GLWindow      ~ygrek/lib/joopengl/GLWindow.f

PRINT-FIX
FDOUBLE
ERROR-MODE

model.f

: DRAW1 { \ w s1 s }
   GLWindow :new -> w
   w :create
   S" Автоколебания" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   difur-init 
   Graph2D :new -> s1   #steps s1 :points!
   #steps 0 DO
     runRK \ output CR
     Model::tn Model::xn s1 :point!
   LOOP
   s1 s :add

   s :autoScale

   w :show
   w :run 
   w :free
;


: DRAW2 { \ w s1 s }
   GLWindow :new -> w
   w :create
   S" Мат моделирование - Колебания" w :setText
   w :maximize

   GLPlot2D :new -> s
   s w :add

   difur-init 
   Graph2D :new -> s1   #steps s1 :points!
   #steps 0 DO
     runRK \ output CR
     Model::xn Model::yn s1 :point! 
   LOOP
   s1 s :add

   s :autoScale

   w :show
   w :run 
   w :free
;


REQUIRE button ~ygrek/~yz/lib/winctl.f

0 VALUE e_M  0 VALUE e_R   0 VALUE e_L
0 VALUE e_C  0 VALUE e_a   0 VALUE e_S
0 VALUE e_q0 0 VALUE e_q0' 0 VALUE e_time

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

add-graph.f

: main 
  WINDOWS...
  " Times New Roman Cyr" 12 create-font default-font
  0 dialog-window TO winmain
  " Мат моделирование N5. yGREK heretix. КА-21" winmain -text!

  GRID

    grid.f

    hline 500 1 this ctlresize |
    ===
    " График1" button -right add-graph1 this -command! | 
    " График2" button -left  add-graph2 this -command! | 
  GRID; winmain -grid!
  winmain wincenter
  winmain winshow

  fill-edit.f

  ...WINDOWS
\  ." ...WINDOWS"
  BYE
;

main
\EOF
' main TO <MAIN>
S" laba5.exe" SAVE
BYE


