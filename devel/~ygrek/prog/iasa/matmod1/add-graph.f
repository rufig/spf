PROC: add-graph

 gr @ -1 = IF " Выберите модель!" msg EXIT THEN
 gr @ 1 =
 IF ALSO Model1 [ ALSO Model1 ]
  e1tau >float FTO tau tau F.
   e1T0 >float FTO T0 T0 F.
   e1Tc >float FTO Tc Tc F.
  S" Модель Ньютона" THEN
 gr @ 2 =
 IF ALSO Model2 [ ALSO Model2 ]
  e2mju >float FTO mju
    e2K >float FTO K
   e2N0 >float FTO N0
 S" Модель Фергюльста" THEN
 gr @ 3 = 
 IF ALSO Model3 [ ALSO Model3 ]
    e3r >float FTO r
    1e r F- FTO m
   e3K >float FTO K
  e3N0 >float FTO N0
 S" Модель Пригожина" THEN
 gr @ 4 = 
 IF ALSO Model4 [ ALSO Model4 ]
  e4alpha >float FTO alpha
    e4mju >float FTO mju
      e4g >float FTO g
      e4a >float FTO a
      e4s >float FTO s
     e4k0 >float FTO k0
 S" Модель Соллоу" THEN

 S" init" SFIND DROP TO difur-init
 S" func" SFIND DROP TO difur-func
 S" solution" SFIND DROP TO difur-solution

 ( addr u ) RUN
PREVIOUS  [ PREVIOUS ]
\ ." After RUN."

PROC;
