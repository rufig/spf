
REQUIRE [IF] ~MAK\CompIF1.f
REQUIRE INST ~mak\listing2.f 

C" H." FIND NIP 0=
[IF]
 : H.  BASE @ HEX SWAP U. BASE !  ;
\ OP1
[THEN]

: .OPX  @ DUP @  ."  @  @ " H. ." XOR OR \ " INST DROP ;
: .OP3 CR ." OP3" OP3 .OPX ;
: .OP2 CR ." OP2" OP2 .OPX ;
: .OP1 CR ." OP1" OP1 .OPX ;
: .OP0 CR ." OP0" OP0 .OPX ;

: .WOPX  @ DUP W@  ."  @  W@ " H. ." XOR OR \ " INST DROP ;
: .WOP4 CR ." OP4" OP4 .WOPX ;
: .WOP3 CR ." OP3" OP3 .WOPX ;
: .WOP2 CR ." OP2" OP2 .WOPX ;
: .WOP1 CR ." OP1" OP1 .WOPX ;
: .WOP0 CR ." OP0" OP0 .WOPX ;

: .COPX  @ DUP C@  ."  @  C@ " H. ." XOR OR \ " INST DROP ;
: .COP5 CR ." OP5" OP5 .COPX ;
: .COP4 CR ." OP4" OP4 .COPX ;
: .COP3 CR ." OP3" OP3 .COPX ;
: .COP2 CR ." OP2" OP2 .COPX ;
: .COP1 CR ." OP1" OP1 .COPX ;
: .COP0 CR ." OP0" OP0 .COPX ;
