
\ Ruvim, 15.11.1999
\ SPF370
: JMP   ( xt1 xt2 -- )   \  Name-new-ver Name-old-ver JMP
  0x0E9 OVER C!     \ jmp-code
  1+  DUP >R
  CELL+ - R> !
;


\ 13.04.2000.   у  AC, кстати,  было так сделано  ;)
\ : JMP ( addr-to addr-from -- )
\   >R
\   0E9 R@ C!
\   R@ 1+ CELL+ - R> 1+ !
\ ;
