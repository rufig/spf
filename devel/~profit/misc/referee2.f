REQUIRE KEEP ~profit/lib/bac4th.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE FOR ~profit/lib/for-next.f
REQUIRE CLASS: ~day/joop/oop.f

: in-the-red-corner   S" joe louis.f" ;
: in-the-blue-corner  S" mike tyson.f" ;

VARIABLE game
: change-game ( move -- )  IF game 1+! ELSE -1 game +! THEN ;
: lost? ( -- lost? )  5 game @ - ABS 5 =  ; \ или =0 или =10

VARIABLE moves-made
: send-updates? ( -- send? ) moves-made DUP 1+! @ 5 MOD 0= ;
: show-game ( -- ) CR ." [" game @ FOR ." ." NEXT ." |" 10 game @ - FOR ." ." NEXT ." ]" ;

CLASS: fighter <SUPER Object

2 CELLS VAR name
CELL    VAR lastMove
CELL    VAR predMove

CELL    VAR move-xt
CELL    VAR board-xt

: :move   move-xt  @ EXECUTE ;
: :board  board-xt @ EXECUTE ;

: :init 123 lastMove !  123 predMove ! ;
: :free name @ FREE THROW ;

: :set ( addr u -- ) \ закачка методов из файла
WARNING KEEP WARNING 0!
2DUP HEAP-COPY OVER name 2! \ имя сохраняем
INCLUDED
S" move"  SFIND IF move-xt !  ELSE 2DROP THEN 
S" board" SFIND IF board-xt ! ELSE 2DROP THEN ;

: :print ( -- )  name 2@ CR TYPE SPACE ;

: :lost ( -- ) own :print ." lost!" ;
: :dsc ( -- )  own :print ." disqualified!" ;

: :check-moves ( move -- dsc? ) lastMove @ =  lastMove @ predMove @ = AND ;
: :record-move ( move -- ) lastMove @ predMove !  lastMove ! ;

: :make-move ( -- game-over? ) own :move ( move )
own :print DUP IF ." +" ELSE ." -" THEN
DUP own :check-moves IF own :dsc DROP TRUE EXIT THEN
DUP own :record-move
change-game
lost? DUP IF own :lost THEN ;

;CLASS

<< :move
<< :board
<< :set
<< :lost
<< :make-move

fighter :new VALUE red
in-the-red-corner red :set

fighter :new VALUE blue
in-the-blue-corner blue :set

: check-game show-game send-updates? IF game @ red :board  game @ blue :board THEN ;

: let-rumble-start
moves-made 0!
5 game !
show-game

\ Судья бросает монетку, кому делать первый ход:
32 CHOOSE 15 > 
IF red blue ELSE blue red THEN TO blue TO red
\ если надо меняем местами -- у красных есть право первого хода

BEGIN
red :make-move IF EXIT THEN
check-game
blue :make-move IF EXIT THEN
check-game
AGAIN ;

STARTLOG
let-rumble-start