\ -----------------------------
\ Сетки

VARIABLE cur-grid
VARIABLE cur-row
VARIABLE cur-bind
VARIABLE cur-halign
VARIABLE cur-valign
VARIABLE cur-xx
VARIABLE cur-yy
VARIABLE cur-width
VARIABLE cur-height

0 == bleft
1 == bright
2 == bcenter
3 == bspan

: bhdir ( ->bl; n -- ) CREATE , DOES> @ cur-halign ! ;
: bvdir ( ->bl; n -- ) CREATE , DOES> @ cur-valign ! ;

bleft   bhdir -left
bright  bhdir -right
bcenter bhdir -center
bspan   bhdir -xspan
bleft   bvdir -top
bright  bvdir -bottom
bcenter bvdir -middle
bspan   bvdir -yspan

: bfield ( ->bl; var -- ) CREATE , DOES> ( n -- ) @ ! ;

cur-xx     bfield -xmargin
cur-yy     bfield -ymargin
cur-width  bfield -width
cur-height bfield -height

100000 == fixed
: -xfixed  fixed -width ;
: -yfixed  fixed -height ;

0
CELL -- :gsign 	 \ подпись "GRID"
CELL -- :glink   \ указатель на первый ряд
CELL -- :gwidth  \ ширина сетки: должна быть 3-ей (wm_getminmaxinfo)
CELL -- :gheight \ высота сетки: должна быть 4-ей (wm_getminmaxinfo)
CELL -- :gfixheight \ сумма фиксированных по высоте клеток
CELL -- :gbox	 \ рамка вокруг сетки
== #grid

0 
CELL -- :rlink   \ указатель на следующий ряд
CELL -- :rbacklink  \ указатель на предыдущий ряд
CELL -- :rblink  \ указатель на клетки ряда
CELL -- :rwidth  \ ширина ряда
CELL -- :rheight \ высота ряда
CELL -- :rfixwidth  \ сумма фиксированных по х клеток
== #row

0
CELL -- :blink     \ указатель на следующую клетку
CELL -- :bbacklink \ указатель на предыдущую клетку
CELL -- :bwidth   \ ширина клетки
CELL -- :bheight  \ высота клетки
CELL -- :brelw    \ относительная ширина клетки
CELL -- :brelh    \ относительная высота клетки
CELL -- :bxmargin \ горизонтальное поле
CELL -- :bymargin \ вертикальное поле
CELL -- :bhalign  \ выравнивание по горизонтали
CELL -- :bvalign  \ выравнивание по вертикали
CELL -- :bdweller \ обитатель клетки
CELL -- :bdwellerw \ его ширина
CELL -- :bdwellerh \ и высота
CELL -- :bnostretch \ не растягивать клетку
== #binding

VECT defaultbind

:NONAME ( -- ) -left -top  5 -xmargin  5 -ymargin  0 -width  0 -height ; TO defaultbind

: === ( -- )
  #row MGETMEM DUP
  cur-row @ OVER :rbacklink !
  cur-row @ ?DUP
  IF ( new new old) :rlink ! ELSE ( new new) cur-grid @ :glink ! THEN
  cur-row ! 
  defaultbind 
  cur-bind 0! ;

: GRID ( -- savedparams )
  this cur-grid @ cur-row @ cur-bind @
  cur-halign @ cur-valign @
  cur-xx @ cur-yy @
  cur-width @ cur-height @
  #grid MGETMEM >R
  CELL" GRID" R@ :gsign !
  -1 R@ :gwidth !
  -1 R@ :gheight !
  R> cur-grid !
  cur-row 0! 
  === ;

: | ( ctl/grid -- )
  #binding MGETMEM DUP
  cur-bind @ OVER :bbacklink !
  cur-bind @ ?DUP IF :blink ! ELSE cur-row @ :rblink ! THEN
  >R
  R@ :bdweller !
  cur-halign @ R@ :bhalign !
  cur-valign @ R@ :bvalign !
  cur-xx      @ R@ :bxmargin !
  cur-yy      @ R@ :bymargin !
  cur-width   @ R@ :brelw !
  cur-height  @ R@ :brelh !
  cur-width   @ 0= 0= R@ :bnostretch !
  R> cur-bind !
  defaultbind ;

: grid? ( a -- ? ) @ CELL" GRID" = ;

:NONAME ( grid -- )
  DUP :glink @ ?DUP IF
    BEGIN
      DUP :rblink @ ?DUP IF
        BEGIN
          DUP :bdweller @
            DUP grid?
            IF del-grid ELSE ctl-destroy THEN
          DUP :blink @ SWAP MFREEMEM
        ?DUP 0= UNTIL
      THEN
      DUP :rlink @ SWAP MFREEMEM
    ?DUP 0= UNTIL
  THEN
  DUP :gbox @ ?DUP IF ctl-destroy THEN
  MFREEMEM ; TO del-grid

: traverse-grid ( xt -- )
  cur-grid @ :glink @ ?DUP IF
    BEGIN
      cur-row !
      DUP EXECUTE
      cur-row @ :rlink @
    ?DUP 0= UNTIL
  THEN DROP ;

: traverse-row ( xt -- )
  cur-row @ :rblink @ ?DUP IF
    BEGIN
      cur-bind !
      DUP EXECUTE
      cur-bind @ :blink @
    ?DUP 0= UNTIL
  THEN DROP ;

: save-grid-vars ( -- n n1 n2)
  cur-grid @ cur-row @ cur-bind @ ;
: restore-grid-vars ( n n1 n2 --  )
  cur-bind ! cur-row ! cur-grid ! ;

\ Вспомогательные операции с сеткой ---------

\ Заметка на полях: вся работа с сетками изнутри смотрится некрасиво.
\ Проблема в том, что есть рекурсивные вызовы и при каждом таком вызове
\ приходится сохранять глобальные переменные.
\ Локальными обойтись нельзя, поскольку обработка размазана по многим словам.
\ Поэтому все в целом по стилю напоминает Фортран :-(

: (find-grid-x) ( x grid -- )
  :rblink @ DUP 0= IF EXIT THEN
  SWAP >R 0 SWAP
  BEGIN
    ( cnt link)
    DUP 0= IF PRESS RDROP EXIT THEN
    OVER R@ = IF PRESS RDROP EXIT THEN
    >R 1+ R> :blink @
  AGAIN ;

: (find-grid-y) ( y grid -- )
  :glink @ DUP 0= IF EXIT THEN
  ( y cnt) SWAP >R 0 SWAP
  BEGIN
    ( cnt link)
    OVER R@ = IF PRESS RDROP EXIT THEN
    DUP 0= IF PRESS RDROP EXIT THEN
    >R 1+ R> :rlink @
  AGAIN ;

: grid[] ( x y grid -- dweller/0)
  >R SWAP R> (find-grid-y) DUP 0= IF PRESS EXIT THEN
  ( x row) (find-grid-x) DUP 0= IF EXIT THEN 
  ( bind) :bdweller @ ;

: window[] ( x y win -- )
  DUP -grid@ ?DUP IF PRESS grid[] ELSE 2DROP DROP 0 THEN ;


VECT walk-do-grid
VECT walk-do-control

PROC: (walkbind)
  cur-bind @ :bdweller @ DUP grid? IF walk-do-grid ELSE walk-do-control THEN
PROC;

PROC: (walkrow)
  (walkbind) traverse-row
PROC;

: walk-controls ( grid do-grid do-ctl -- ) 
  TO walk-do-control TO walk-do-grid
  >R save-grid-vars
  R> cur-grid !
  (walkrow) traverse-grid
  restore-grid-vars ;

VECT show-grid ( grid -- )
:NONAME 
  DUP ['] show-grid ['] ctlshow walk-controls 
  :gbox @ ?DUP IF ctlshow THEN
; TO show-grid

VECT hide-grid ( grid -- )
:NONAME 
  DUP ['] hide-grid ['] ctlhide walk-controls 
  :gbox @ ?DUP IF ctlhide THEN
; TO hide-grid

PROC: (rgrid)
  CR ." bind" cur-bind @ 20 DUMP
PROC;

PROC: (ggrid)
  CR ." row" cur-row @ 10 DUMP
   (rgrid) traverse-row
 PROC;

: .grid ( grid -- ) >R save-grid-vars
   R> cur-grid !
  (ggrid) traverse-grid
 restore-grid-vars ;

\ Подгонка сетки --------------

VECT arrange-grid
VARIABLE temp
VARIABLE temp2

: grid-size ( grid -- w h)
  >R
  R@ :gwidth @ -1 = IF 
    save-grid-vars temp @ R@ arrange-grid temp ! restore-grid-vars
  THEN
  R@ :gwidth @ R> :gheight @ ;

: GRID; ( savedparams -- grid )
  \ заставим сетку рассчитать свои параметры
  cur-grid @ >R
  cur-height ! cur-width !
  cur-yy !
  cur-xx !
  cur-valign !
  cur-halign !
  cur-bind ! cur-row ! cur-grid ! TO this
  R> DUP grid-size 2DROP ;

: dweller-size ( a -- w h) DUP grid? IF grid-size ELSE ctl-size THEN ;

\ первый проход ряда:
\ проходим по всем клеткам, считаем максимальную высоту и общую ширину
PROC: row-pass1
  cur-bind @ >R
  R@ :bdweller @ dweller-size DUP R@ :bdwellerh ! OVER R@ :bdwellerw !
  R@ :bymargin @ 2* +
  SWAP R@ :bxmargin @ 2* + 2DUP ( y x ) R@ :bwidth ! R> :bheight !
  cur-row @ :rwidth +!  cur-row @ :rheight @ MAX cur-row @ :rheight ! 
\ ." rp1: " cur-bind @ :bwidth @ . cur-bind @ :bheight @ . CR
PROC;

\ первый проход:
\ считаем размеры каждого обитателя клетки + поля
\ и высчитываем размеры каждого ряда
PROC: grid-pass1
  cur-row @ :rwidth 0!  cur-row @ :rheight 0!
  row-pass1 traverse-row 
\ ." gp1: " cur-row @ :rwidth @ . cur-row @ :rheight @ . CR
PROC;

\ второй проход:
\ считаем общую высоту и максимальную ширину таблицы
PROC: grid-pass2
  cur-grid @ :gwidth @ cur-row @ :rwidth @ MAX cur-grid @ :gwidth !
  cur-row @ :rheight @ cur-grid @ :gheight +!
\ ." gp2: " cur-grid @ :gwidth @ . cur-grid @ :gheight @ . CR
PROC;

\ третий проход:
\ Находим все фиксированные клетки, запоминаем их размеры с обратным знаком
\ и накапливаем их общую сумму в параметрах ряда
PROC: row-pass3
  cur-bind @ :brelw @ fixed = IF
    cur-bind @ :bwidth @ DUP NEGATE cur-bind @ :brelw !
    cur-row @ :rfixwidth +!
  THEN
  \ если высота клетки фиксирована - отметим этот факт в temp
  cur-bind @ :brelh @ fixed = IF
    TRUE temp !
  THEN
\ ." rp3: rfixw=" cur-row @ :rfixwidth @ . ." fixwflag=" temp @ . 
\ ." brelw=" cur-bind @ :brelw @ . CR
PROC;

PROC: grid-pass3
  temp 0!
  row-pass3 traverse-row
  temp @ IF
  \ если высота ряда фиксирована, запишем ее с обратным знаком
    cur-row @ :rheight @ DUP NEGATE cur-row @ :rheight !
    \ и запомним в параметрах сетки
    cur-grid @ :gfixheight +!
  THEN
\ ." gp3: rfixh=" cur-grid @ :gfixheight @ . CR
PROC;

\ четвертый проход:
\ высчитываем размеры каждой нефиксированной клетки и каждого нефиксированного ряда
\ в %% к общей ширине таблицы

PROC: row-pass4
  cur-bind @ :brelw @ DUP 0< NOT IF
    ?DUP 0= IF 
      cur-bind @ :bwidth @ 1000 temp @ */
    \ если выставлена - перевести из % в %%
    ELSE 
      10 *
    THEN
  THEN
  cur-bind @ :brelw ! 
\ ." rp4: " cur-bind @ :brelw @ . ." %%" CR
PROC;

PROC: grid-pass4
  \ ширина текущего ряда без фиксированных клеток
  cur-row @ :rwidth @ cur-row @ :rfixwidth @ - temp !
  row-pass4 traverse-row
  cur-row @ :rheight @ 0 > IF
    \ посчитаем высоту ряда в %%
    cur-row @ :rheight @ 1000 cur-grid @ :gheight @ cur-grid @ :gfixheight @ - */
    cur-row @ :rheight !
  THEN
\ ." gp4: " cur-row @ :rheight @ . ." %%" CR
PROC;

VECT add-grid-to-window

: add-control ( dweller -- )
  DUP grid? IF 
    temp @ SWAP current-window add-grid-to-window
  ELSE 
    TRUE OVER -locked!
    DUP set-parent 
    DUP -ctladdpart@ ?DUP IF >R DUP R> EXECUTE THEN
    temp @ IF ctlshow ELSE DROP THEN
  THEN 
;

: add-controls-in-row ( row -- )
  \ ищем последнюю ячейку...
  ?DUP IF
    BEGIN
      ?DUP
    WHILE
      DUP cur-bind !
      :blink @
    REPEAT
     \ и проходим ячейки в обратном порядке
     cur-bind @ 
     BEGIN
       DUP :bdweller @ add-control
       :bbacklink @
    ?DUP 0= UNTIL
  THEN ;

\ Проходим всю сетку задом наперед и подключаем к окну 
\ все элементы управления
:NONAME ( show? grid win -- )
  ROT temp !
  current-window -ROT
  TO current-window
  cur-grid @ SWAP cur-grid !
  \ ищем последний ряд...
  cur-grid @ :glink @ ?DUP IF
    BEGIN
      ?DUP
    WHILE
      DUP cur-row !
      :rlink @
    REPEAT
    \ и проходим ряды в обратном порядке
    cur-row @ 
    BEGIN
      DUP :rblink @ add-controls-in-row
      :rbacklink @
    ?DUP 0= UNTIL
  THEN
  cur-grid @ :gbox @ ?DUP IF ctlshow THEN 
  cur-grid ! TO current-window
  ; TO add-grid-to-window

: (arrange-grid) ( grid -- ) cur-grid !
\ ." arrange-grid <<<" CR
  cur-grid @ :gwidth 0!  cur-grid @ :gheight 0!
  grid-pass1 traverse-grid
  grid-pass2 traverse-grid
  grid-pass3 traverse-grid 
  grid-pass4 traverse-grid 
\ ." arrange-grid >>>" CR
;

' (arrange-grid) TO arrange-grid

\ ---------------------------
VECT map-grid

\ в cur-halign и cur-valign запомним ширину ячейки и высоту ряда

PROC: map-bind { \ new-w new-h new-x new-y ww hh xm ym resize? }
  cur-bind @ :bwidth @ cur-halign !
  cur-bind @ :bxmargin @ TO xm
  cur-bind @ :bymargin @ TO ym
  cur-halign @ xm 2* - TO ww
  cur-valign @ ym 2* - TO hh
\ рассчитываем х
  cur-bind @ :bhalign @ CASE
    bleft   OF xm ENDOF
    bcenter OF 
      ww cur-bind @ :bdwellerw @ - 2/ xm +
    ENDOF
    bright  OF 
      cur-halign @ xm - cur-bind @ :bdwellerw @ - 2-
    ENDOF
    bspan   OF 
      ww TO new-w
      xm
    ENDOF
  ENDCASE TO new-x
\ рассчитываем y
  cur-bind @ :bvalign @ CASE
    bleft   OF ym ENDOF
    bcenter OF 
      hh cur-bind @ :bdwellerh @ - 2/ ym +
    ENDOF
    bright  OF 
      cur-valign @ ym - cur-bind @ :bdwellerh @ - 1+
    ENDOF
    bspan   OF 
      hh TO new-h
      ym
    ENDOF
  ENDCASE TO new-y
\ ." map-bind: xx=" cur-xx @ . ." width=" cur-halign @ .
\ ." newx=" new-x . ." newy=" new-y .
\ ." neww=" new-w . ." newh=" new-h . CR
\ если надо - изменяем размер
  new-w new-h + DUP TO resize? IF
    new-w 0= IF cur-bind @ :bdwellerw @ TO new-w THEN
    new-h 0= IF cur-bind @ :bdwellerh @ TO new-h THEN
  THEN
  \ 
  cur-bind @ :bdweller @ DUP grid? IF
    >R cur-xx @ new-x + cur-yy @ new-y + 
    resize? IF new-w new-h ELSE R@ grid-size THEN
    2OVER 2OVER R@ map-grid
    R> :gbox @ ?DUP IF 
      ( x y w h ctl)
      >R ym + SWAP xm + SWAP R@ resize
      ( x y)
      ym 2/ - SWAP xm 2/ - SWAP R> another-place
    ELSE 
      2DROP 2DROP
    THEN
  ELSE 
    resize? IF 
      DUP new-w new-h ROT ctlresize 
      new-w cur-bind @ :bdwellerw !
      new-h cur-bind @ :bdwellerh !
    THEN
    new-x cur-xx @ + new-y cur-yy @ + ROT another-place
  THEN
\ передвигаемся дальше
  cur-halign @ cur-xx +!
PROC;

PROC: calc-bind
  cur-bind @ :brelw @ DUP 0< 
    IF ABS ELSE cur-width @ cur-row @ :rfixwidth @ - 1000 */ THEN 
  DUP cur-bind @ :bwidth !  temp +!
  cur-bind @ :bnostretch @ IF cur-bind @ :bwidth @ temp2 +! THEN
PROC;

PROC: stretch-bind
  \ temp - общая сумма растяжения
  \ temp2 - сумма длин растягиваемых ячеек
  \ распределяем дополнительные длины пропорционально длине ячейки
  cur-bind @ :bnostretch @ 0= IF
    cur-bind @ :bwidth @ temp @ temp2 @ */ cur-bind @ :bwidth +!
  THEN
PROC;

PROC: map-row
  cur-row @ :rheight @ DUP 0< 
    IF ABS ELSE cur-height @ cur-grid @ :gfixheight @ - 1000 */ THEN
  cur-valign !
\ ." map-row: yy=" cur-yy @ . ." height=" cur-valign @ . CR
\ высчитаем ширину каждой ячейки, общую сумму ячеек (temp) 
\ и сумму нерастягиваемых ячеек (temp2)
  temp 0!  temp2 0!
  calc-bind traverse-row
\ растянем при необходимости ячейки
  cur-width @ temp @ - 1 > IF
    \ сумма растягиваемых ячеек
    temp @ temp2 @ - temp2 !
    \ общая сумма растяжения
    cur-width @ temp @ - temp !
    stretch-bind traverse-row
  THEN
\ расставим содержание ячеек
  cur-xx @
  map-bind traverse-row
  cur-valign @ cur-yy +!
  cur-xx !
PROC;

:NONAME ( xbeg ybeg width height grid -- )
\ ." map-grid: xbeg=" 4 PICK . ." ybeg=" 3 PICK . ." w=" 2 PICK . ." h=" 1 PICK . CR
  >R >R >R >R >R
  \ сохраним все глобальные переменные
  save-grid-vars
  cur-width @ cur-height @
  cur-xx @ cur-yy @
  cur-halign @ cur-valign @
  R> cur-xx ! R> cur-yy ! 
  R> cur-width ! R> cur-height ! R> cur-grid !
  map-row traverse-grid
  \ восстановим глобальные переменные
  cur-valign ! cur-halign !
  cur-yy ! cur-xx !
  cur-height ! cur-width !
\ ." /map-grid" CR
  restore-grid-vars ; 
TO map-grid

: resize-window-grid ( win -- )
  >R current-window
  R@ TO current-window
  0 0 R@ -xsize@ R@ -ysize@ R> -grid@ map-grid
  TO current-window ;

:NONAME { grid win -- }
  grid -grid win store
  grid 0= IF EXIT THEN
  grid grid-size ( w h)
  win max-win-size ( w h maxw maxh)
  ROT MIN >R MIN R> ( neww newh)
  win winresize
  TRUE grid win add-grid-to-window
; -grid window storeset

:NONAME ( -- )
  thiswin resize-window-grid
; -gridresize window store
