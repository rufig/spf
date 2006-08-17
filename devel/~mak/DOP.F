
C" H." FIND NIP 0=
[IF]
 : H.  BASE @ HEX SWAP U. BASE !  ;
\ OP1
[THEN]

: .COPX DUP  C@  H. ." XOR OR \ " INST
  ( DROP)  \ пускай гадят, может понадобится
 ;

: .COP0 CR ." OP0 @ C@ " OP0 @ .COPX ;
: .COP1 CR ." OP1 @ C@ " OP1 @ .COPX ;
: .COP2 CR ." OP2 @ C@ " OP2 @ .COPX ;
: .COP3 CR ." OP3 @ C@ " OP3 @ .COPX ;
: .COP4 CR ." OP4 @ C@ " OP4 @ .COPX ;
: .COP5 CR ." OP5 @ C@ " OP5 @ .COPX ;
: .COP6 CR ." OP6 @ C@ " OP6 @ .COPX ;
: .COP7 CR ." OP7 @ C@ " OP7 @ .COPX ;


: .WOPX DUP  W@  H. ." XOR OR \ " INST  ( DROP) ;

: .WOP0 CR ." OP0 @ W@ " OP0 @ .WOPX ;
: .WOP1 CR ." OP1 @ W@ " OP1 @ .WOPX ;
: .WOP2 CR ." OP2 @ W@ " OP2 @ .WOPX ;
: .WOP3 CR ." OP3 @ W@ " OP3 @ .WOPX ;
: .WOP4 CR ." OP4 @ W@ " OP4 @ .WOPX ;
: .WOP5 CR ." OP5 @ W@ " OP5 @ .WOPX ;
: .WOP6 CR ." OP6 @ W@ " OP6 @ .WOPX ;
: .WOP7 CR ." OP7 @ W@ " OP7 @ .WOPX ;

: .OPX DUP  @  H. ." XOR OR \ " INST  ( DROP) ;

: .OP0 CR ." OP0 @ @ " OP0 @ .OPX ;
: .OP1 CR ." OP1 @ @ " OP1 @ .OPX ;
: .OP2 CR ." OP2 @ @ " OP2 @ .OPX ;
: .OP3 CR ." OP3 @ @ " OP3 @ .OPX ;
: .OP4 CR ." OP4 @ @ " OP4 @ .OPX ;
: .OP5 CR ." OP5 @ @ " OP5 @ .OPX ;

: .TOPX DUP @ 0xFFFFFF AND  H. ." XOR OR \ " INST ( DROP) ;

: .TOP0 CR ." OP0 @ @ FFFFFF AND " OP0 @ .TOPX ;
: .TOP1 CR ." OP1 @ @ FFFFFF AND " OP1 @ .TOPX ;
: .TOP2 CR ." OP2 @ @ FFFFFF AND " OP2 @ .TOPX ;
: .TOP3 CR ." OP3 @ @ FFFFFF AND " OP3 @ .TOPX ;
: .TOP4 CR ." OP4 @ @ FFFFFF AND " OP4 @ .TOPX ;
: .TOP5 CR ." OP5 @ @ FFFFFF AND " OP5 @ .TOPX ;

