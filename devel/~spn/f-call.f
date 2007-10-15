\ f-call.f, Peter Sovietov
\ stackless(fortran) procedures


: f-: ( "name" - here) : HERE 0 , ;
: f-; ( here)
   [COMPILE] ; HERE SWAP ! -1 ALLOT
   0xE9 C, ( jmp #) 0 , ; IMMEDIATE
: f-call ( "name")
   ' DUP @ 0xBB C, ( mov ebx, #) ,
   0xC7 C, 0x03 C, ( mov [ebx], #) HERE 9 + OVER @ 4 + - ,
   0xE9 C, HERE - , ; IMMEDIATE
