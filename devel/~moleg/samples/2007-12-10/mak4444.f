\
\
\

REQUIRE { devel\~mak\locals4.f

\ вернуть количество бит в стандартной €чейке
: bits/cell ( --> u ) 0 -1 BEGIN TUCK WHILE 1+ SWAP 2* REPEAT NIP ;

        0 VALUE buffer \ адрес места, где хранитс€ результирующий массив

\ выделение пам€ти под массив и его инициализаци€
 1 bits/cell 4 / LSHIFT CELLS CELL + ALLOCATE THROW DUP TO buffer 0!

\
: aCount ( addr --> addr # ) DUP CELL + SWAP @ ;

\ отправить значение в буфер
: ->buf ( u --> )
        buffer aCount + !
        CELL buffer +! ;


: MINBIT
  DUP
  INVERT 1+
  XOR
 INVERT 1+ 1 RSHIFT
;

: TEMPLATE! { tmpl \ it nt -- }
tmpl INVERT TO it
tmpl MINBIT TO nt
0
BEGIN
 it OR
 nt +
 tmpl AND DUP ->buf
 DUP 0=
UNTIL DROP
;

: combs ( um --> addr # ) 0 buffer ! TEMPLATE! buffer aCount ;