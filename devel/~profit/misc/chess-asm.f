\ http://fforum.winglion.ru/viewtopic.php?t=547
\ Форт-ассемблер от chess'а

0x0 CONSTANT EAX
0x1 CONSTANT ECX
0x2 CONSTANT EDX
0x3 CONSTANT EBX
0x5 CONSTANT EBP
0x6 CONSTANT ESI

: SM \ я не знаю на самом деле что это делает, просто повторяется часто (profiT)
OR OR C, ;

: R=R  ( R1 R2 -- )    \ MOV  R1,  R2 
0x8B C, SWAP 3 LSHIFT 0xC0 SM ; 

: R=@R ( SM R1 R2 -- ) \ MOV  R1, (SM) [R2] 
ROT DUP >R -ROT 0x8B C, SWAP 3 LSHIFT
OVER EBP = R> 0<> OR
IF 
  0x40 SM C,
ELSE
  0x00 SM DROP
THEN  ;

: @R=R ( SM R1 R2 -- ) \ MOV (SM) [R1], R2 
ROT DUP >R -ROT 0x89 C,  3 LSHIFT 
OVER EBP = R> 0<> OR
IF 
  0x40 SM C,
ELSE 
  0x00 SM DROP
THEN  ; 

\ LEA R1, (SM) [R2] 
: R+SM ( SM R1 R2 -- )
0x8D C, SWAP 3 LSHIFT 0x40 SM C, ;

: R=#  ( # R -- ) \ MOV R, # 
0xC7 C, 0xC0 OR C, , ;

: @R=# ( # SM R -- )  \ MOV (SM) [R], # 
0xC7 C, 
  2DUP EBP = SWAP 0<> OR
  IF 
    0x40 OR C, C,
  ELSE 
    C, DROP
  THEN , ;

\EOF
: d [
1 EBP EAX R=@R
0 EBP EAX R=@R
1 EBP EAX @R=R
0 EBX EBX @R=R
RET,
1 0 EBX @R=#
1 0 EBP @R=#
0 EBP EAX @R=R
0 EAX EBP R=@R
1 EBP R=#
0 EAX EBP R+SM
] ;


REQUIRE SEE lib/ext/disasm.f
SEE d