\ Minimalistic stack

REQUIRE HYPE ~day\hype3\hype3.f

CLASS CStack

   CELL PROPERTY data \ addres
   CELL PROPERTY count
   CELL PROPERTY maxData

: setSize ( n )
\ n in cells!
   DUP maxData !
   CELLS
   data@ ?DUP
   IF
      SWAP RESIZE THROW
   ELSE
      ALLOCATE THROW
   THEN data!
;

init:
    2 setSize
;

: checkEmpty
   count@ 0= S" Empty!" SUPER abort
;

: pop ( -- n )
    checkEmpty
    -1 count +!
    data@ count@ CELLS + @
;

: incStack
    count@ maxData@ < 0= \ >=
    IF
      maxData@ 3 * 2/ setSize
    THEN
;

: push
   incStack
   data@ count@ CELLS + !
   count 1+!
;
      	
: top ( -- n )
    pop DUP push
;

dispose: data@ ?DUP IF FREE THROW THEN ;

;CLASS

\EOF
CStack NEW stack

10 ALLOCATE THROW stack push
10 ALLOCATE THROW stack push
10 ALLOCATE THROW stack push
10 ALLOCATE THROW stack push
10 ALLOCATE THROW stack push

stack count@ . 

: freeStrings
     BEGIN
       stack count
     WHILE
       stack pop FREE THROW
     REPEAT
;
