REQUIRE CLASS: ~nn/class/class.f

CLASS: Stack

        CELL FIELD data \ Начальный адрес стека
        CELL FIELD num

CONSTR: init
    1024 ALLOCATE THROW data !
;
        
M: Reinit  ( u -- )
    data @ SWAP RESIZE THROW data !
;

M: Push ( u -- )
   data @ num @ + !
   CELL num +!
;

M: Pop ( -- u )
   CELL NEGATE num +!
   data @ num @ + @
;

M: Top ( -- u )  data @ num @ + CELL- @ ;

M: Search ( u -- addr -1 | 0 )
     >R 0
     BEGIN
       DUP num @ <
     WHILE
       DUP data @ + @ R@ = IF RDROP data @ + -1 EXIT THEN
       CELL+
     REPEAT
     DROP 0 RDROP
;

M: Count ( -- u )   num @ CELL / ;

DESTR: free data @ FREE THROW ;

M: Drop CELL NEGATE num +! ;

M: 2Drop
    2 CELLS NEGATE num +!
;

M: Base ( -- addr)   data @ ;
;CLASS
