\ CASE ... ENDCASE from Forth-2012 CORE-EXT
\ 2024-05-08

REQUIRE SYNONYM lib/include/wordlist-tools.f


: CASE \ Compilation: ( -- case-sys )
  \ Compilation actual: ( -- x.magic 0 )
  \ Run-time: ( -- )
  ?COMP 4 0
; IMMEDIATE

: OFT \ Compilation: ( case-sys1 -- case-sys2 of-sys )
  \ Compilation actual: ( x.magic +n.count1 -- orig x.magic +n.count2 ) \ +n.count2 = +n.count1 + 1
  \ Run-time: ( true --  |  false -- never )
  OVER 4 <> -22 ?ERROR
  2>R
  POSTPONE IF
  2R> 1+
; IMMEDIATE

SYNONYM ?OF OFT

: OF \ Compilation: ( case-sys1 -- case-sys2 of-sys )
  \ Compilation actual: ( x.magic +n.1 -- orig x.magic +n.2 ) \ +n.2 = +n.1 + 1
  \ Run-time: ( x1 x2\x1 -- x1 never  |  x1 x1 -- )
  POSTPONE OVER  POSTPONE =  POSTPONE OFT POSTPONE DROP
; IMMEDIATE

: ENDOF \ Compilation: ( case-sys1 of-sys -- case-sys2 )
  \ Compilation actual: ( orig1 x.magic +n.1 -- orig2 x.magic +n.1 )
  \ Run-time: ( never -- )
  2>R POSTPONE ELSE 2R>
; IMMEDIATE

: ENDCASE \ Compilation: ( case-sys -- )
  \ Compilation actual: ( +n.count*orig x.magic +n.count -- )
  \ Run-time: ( x -- )
  SWAP 4 <> -22 ?ERROR
  POSTPONE DROP  0 ?DO  POSTPONE THEN  LOOP
; IMMEDIATE
