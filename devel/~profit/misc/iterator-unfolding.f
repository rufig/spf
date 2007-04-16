~profit\lib\bac4th-closures.f

: iter
0 RLIT, RET, HERE DUP 5 - SWAP ( br-addr r-addr )
CREATE-VC ROT OVER XT-VC SWAP !
( r-addr vc ) TUCK
10 0 DO
2DUP VC-COMPILE, LOOP

2DROP
VC-RET,
; IMMEDIATE

: r iter 2 DUP * . ;
r

lib/ext/disasm.f
SEE r