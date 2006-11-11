\ Minimalistic stack

REQUIRE HYPE ~day\hype3\hype3.f

CLASS CStack

   CELL PROPERTY data \ addres
   CELL PROPERTY count

: setSize ( n )
   data@ ?DUP
   IF
      SWAP RESIZE THROW
   ELSE
      ALLOCATE THROW
   THEN data!
;

init:
    1024 setSize
;

: checkEmpty
   count@ 0= S" Empty!" SUPER abort
;

: pop ( -- n )
    checkEmpty
    CELL NEGATE count +!
    data@ count@ + @
;

: push
   data@ count@ + !
   CELL count +!
;

: top ( -- n )
    pop DUP push
;

dispose: data@ ?DUP IF FREE THROW THEN ;

;CLASS