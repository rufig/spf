REQUIRE Object ~day\joop\oop.f

CLASS: Stack <SUPER Object

        CELL VAR Data \ Начальный адрес стека
        CELL VAR Num

: :init
    own :init
    1024 ALLOCATE THROW Data !
;
        
: :reinit  ( u -- )
    Data @ SWAP RESIZE THROW Data !
;

: :push ( u -- )
   Data @ Num @ + !
   CELL Num +!
;
: :pop ( -- u )
   CELL NEGATE Num +!
   Data @ Num @ + @
;

: :top ( -- u )
   Data @ Num @ + CELL- @
;

: :search ( u -- addr -1 | 0 )
     >R 0
     BEGIN
       DUP Num @ <
     WHILE
       DUP Data @ + @ R@ = IF RDROP Data @ + -1 EXIT THEN
       CELL+
     REPEAT
     DROP 0 RDROP
;

: :count ( -- u )
   Num @ CELL /
;

: :free
    Data @ FREE THROW
    own :free
;

: :drop
    CELL NEGATE Num +!
;

: :2drop
    2 CELLS NEGATE Num +!
;

: :base ( -- addr)
   Data @
;
;CLASS

<< :reinit
<< :push
<< :pop
<< :top
<< :search
<< :count
<< :drop
<< :2drop
<< :base