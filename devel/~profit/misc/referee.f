REQUIRE RANDOM lib/ext/rnd.f
REQUIRE NOT ~profit/lib/logic.f
REQUIRE __ ~profit/lib/cellfield.f

VARIABLE game
5 game !

: in-the-red-corner  S" joe louis.f" ;
: in-the-blue-corner S" mike tyson.f" ;




VECT red-move
VECT red-board

VECT blue-move
VECT blue-board

in-the-red-corner INCLUDED
' move TO red-move
' board TO red-board

WARNING @ WARNING 0!
in-the-blue-corner INCLUDED
WARNING !

' move TO blue-move
' board TO blue-board

VARIABLE moves-made
VARIABLE first-strike

0
__ predMove
__ predMove2
CONSTANT fighterMoves

CREATE red  fighterMoves ALLOT
CREATE blue fighterMoves ALLOT

: check-moves ( move fighter -- flag )
DUP predMove @ OVER predMove2 @ =
SWAP predMove @ = ;

: record-moves ( move fighter -- )
DUP predMove @ OVER predMove2 !
predMove ! ;

: change-game ( flag -- )  IF game 1+! ELSE -1 game +! THEN ;

: make-move ( flag -- lost )  change-game  5 game @ - ABS 5 =  ; \ или =0 или =10 

: red-make-move ( -- )
red-move CR in-the-red-corner TYPE ." :" DUP .
DUP red check-moves IF
in-the-red-corner CR CR TYPE CR ABORT" disqual!"
EXIT                THEN
DUP red record-moves
make-move IF
in-the-red-corner CR CR TYPE CR ABORT" lost!"
EXIT      THEN
moves-made @ 5 MOD 0= IF game @ red-board THEN
;

: blue-make-move ( -- )
red-move CR in-the-blue-corner TYPE ." :" DUP .
DUP blue check-moves IF
in-the-blue-corner CR CR TYPE CR ABORT" disqual!"
EXIT                 THEN
DUP blue record-moves
make-move IF
in-the-blue-corner CR CR TYPE CR ABORT" lost!"
EXIT      THEN
moves-made @ 5 MOD 0= IF game @ red-board THEN ;

: box ( -- )
moves-made 0!

\ Судья бросает монетку, кому делать первый ход:
32 CHOOSE 15 > first-strike !

first-strike @ IF red-make-move THEN

BEGIN
blue-make-move
first-strike @ IF moves-made 1+! THEN

red-make-move
first-strike @ NOT IF moves-made 1+! THEN
AGAIN ;

box