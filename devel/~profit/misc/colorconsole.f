REQUIRE { lib/ext/locals.f
REQUIRE #define ~af/lib/c/define.f

#define FOREGROUND_BLUE	1
#define FOREGROUND_GREEN 2
#define FOREGROUND_RED 4
#define FOREGROUND_INTENSITY 8
#define BACKGROUND_BLUE	16
#define BACKGROUND_GREEN 32
#define BACKGROUND_RED 64
#define BACKGROUND_INTENSITY 128


WINAPI: FillConsoleOutputAttribute KERNEL32

: xy ( x y -- xy ) 16 LSHIFT + ;

: setColorsInRow ( x y n color -- )
2>R xy ( xy R: n color )
RP@ \ получили адрес ячейки в стеке возвратов, так как функции нужен адрес переменной куда она будет писать
SWAP 2R@ ( addr xy n color )
H-STDOUT FillConsoleOutputAttribute DROP RDROP RDROP ;

\ 10 0 200 FOREGROUND_RED BACKGROUND_GREEN OR setColorsInRow

: setColorsForBlock ( x y w h c -- ) { c -- }
ROT TUCK + SWAP DO 2DUP I SWAP c setColorsInRow LOOP 2DROP ;

10 0 7 3 FOREGROUND_RED BACKGROUND_GREEN OR setColorsForBlock

\ На "бис", ещё более простой вариант

VARIABLE XY
XY 0!

: setXY ( x y -- ) xy XY ! ;
: move ( dx dy -- ) xy XY +! ;
: moveDown 0 1 move ;

VARIABLE color
: setColor ( c -- ) color ! ;

: setColorsInRow ( n -- )  \ ничего себе сокращение?..
0 >R RP@ SWAP XY @ SWAP color @ H-STDOUT FillConsoleOutputAttribute DROP RDROP ;

BACKGROUND_RED FOREGROUND_GREEN OR setColor
15 0 setXY
3 setColorsInRow

: setColorsForBlock ( w h -- )
XY @ >R \ сохраняем значение курсора, т.к. оно меняется
0 DO DUP setColorsInRow moveDown LOOP DROP
R> XY ! ;

8 5 setColorsForBlock