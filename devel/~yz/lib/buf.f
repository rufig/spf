USER-VALUE BUF   USER-VALUE BUF2

1024 == buf-size 

: (<*)  buf-size GETMEM TO BUF  0 TO BUF2 ;
: (<**) (<*) buf-size GETMEM TO BUF2 ;

: <*    R>  BUF >R  BUF2 >R  >R (<*) ;
: <**   R>  BUF >R  BUF2 >R  >R (<**) ;

: *>
  BUF FREEMEM  BUF2 ?DUP IF FREEMEM THEN
  R>   R> TO BUF2  R> TO BUF  >R ;

