\ вставка кусков кода инлайном
\ Юрий Жиловец, 27.10.2003

: (: ( -- resolve xt id)
  ?COMP 0 BRANCH, >MARK HERE 0x3A28
; IMMEDIATE

: ;) ( -- resolve xt id)
  0x3A28 <> IF -2007 THROW THEN
  RET,  >R >RESOLVE1
  R> [COMPILE] LITERAL
; IMMEDIATE
