\ Ю. Жиловец, 7.04.2002
\ Небольшое расширение CASE:
\ 1. END-CASE не убирает число из стека
\ 2. Добавлены <OF< и =OF

REQUIRE CASE  lib/ext/case.f

( 10 20 <OF< входит ли число в диапазон 10..20 ?  )
: <OF<  
  POSTPONE 2>R POSTPONE DUP POSTPONE 2R> POSTPONE 1+ POSTPONE WITHIN
  [COMPILE] IF POSTPONE DROP
; IMMEDIATE

( OF вообще без проверки  5 < =OF )
: =OF 
  [COMPILE] IF POSTPONE DROP
; IMMEDIATE

: END-CASE
  BEGIN SP@ CSP@ = 0=  WHILE  [COMPILE] THEN  REPEAT -CSP
; IMMEDIATE
