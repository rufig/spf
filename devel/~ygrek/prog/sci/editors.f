REQUIRE vector vector.f

0
CELL -- ctl
CELL -- path
CONSTANT /EDITOR

/EDITOR svector VALUE editors

: editors-add ( z ctl -- i ) 
   editors vsize >R
\   CR ." add"
   R@ 1+ editors vresize
   R@ editors v[] ctl !
   R@ editors v[] path !
   R>
   \ DUP . ." done " 
;

: editors-ctl@ ( i -- ctl )
   editors v[] ctl @ ;

: editors-path@ ( i -- z )
   editors v[] path @ ;

: editors-print
   CR
   editors vsize 0 ?DO
    I editors v[]
    CR
    DUP ctl @ .
        path @ DUP . ASCIIZ> TYPE
   LOOP ;
