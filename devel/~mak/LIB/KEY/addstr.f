\                                            Максимов М.О. 
REQUIRE $+!  ~mak\place.f

0x100 04 LSHIFT CONSTANT $_SIZE \ 16 промежуточных значений
$_SIZE 1- CONSTANT $_MASKA

CREATE $_BUFF $_SIZE ALLOT

VARIABLE $&ADDR

: $ADDR $&ADDR @ ;

: $>ADDR!  (  c-addr u -- )
     $&ADDR @ 
     $_BUFF - MAX$@ 1+ + $_MASKA AND
     $_BUFF + DUP
     $&ADDR !  $! ;

: $@ ( vaddr -- a1 c )
   COUNT $>ADDR! $ADDR COUNT ;

: $SWAP+ ( c-addr2 u2 c-addr1 u1 -- c-addr u )
     $>ADDR!
     $ADDR $+!
     $ADDR COUNT ;

: $+ ( c-addr1 u1 c-addr2 u2 -- c-addr u )
  2SWAP $SWAP+  ;

: VARIABLE$ ( -- \name )
  CREATE MAX$@ 1+ ALLOT ;

\EOF TEST

 S" 1" S" 2" S" 3" $+ $+ 
 S" 4" S" 5"   $+ $+  TYPE
