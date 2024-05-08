\ 2024-05-08 ruv

: CASE ( -- case-sys )
  \ actual: ( -- x.magic 0 )
  ?COMP 4 0
; IMMEDIATE

: ?OF ( case-sys1 -- case-sys2 of-sys )
  \ actual: ( x.magic u1 -- orig x.magic u2 )
  OVER 4 <> -22 ?ERROR
  2>R
  POSTPONE IF  POSTPONE DROP
  2R> 1+
; IMMEDIATE

: OF ( case-sys1 -- case-sys2 of-sys )
  \ actual: ( x.magic u1 -- orig x.magic u2 )
  POSTPONE OVER  POSTPONE =  POSTPONE ?OF
; IMMEDIATE

: ENDOF ( case-sys1 of-sys -- case-sys2 )
  \ actual: ( orig1 x.magic u2 -- orig2 x.magic u2 )
  2>R POSTPONE ELSE 2R>
; IMMEDIATE

: ENDCASE ( case-sys -- )
  \ actual: ( i*orig x.magic u.i -- )
  SWAP 4 <> -22 ?ERROR
  POSTPONE DROP  0 ?DO  POSTPONE THEN  LOOP
; IMMEDIATE
