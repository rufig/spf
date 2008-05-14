\ Andrey Filatkin, af@forth.org.ru
\ Сишные инкремент\декремент для VAR-переменных.

REQUIRE AT	~af/lib/var.f
REQUIRE 1-!	~af/lib/decr.f

\ Увеличить значение VAR-переменной на единицу
: ^++ ( "var" -- )
  POSTPONE AT
  STATE @ IF POSTPONE 1+! ELSE 1+! THEN
; IMMEDIATE

\ Положить значение VAR-переменной на стек, увеличить переменную на 1
: @++ ( "var" -- n )
  POSTPONE AT
  STATE @ IF POSTPONE DUP POSTPONE @ POSTPONE SWAP POSTPONE 1+!
  ELSE DUP @ SWAP 1+! THEN
; IMMEDIATE

\ Увеличить значение VAR-переменной на единицу, положить это значение на стек
: ++@ ( "var" -- n )
  POSTPONE AT
  STATE @ IF POSTPONE DUP POSTPONE 1+! POSTPONE @
  ELSE DUP 1+! @ THEN
; IMMEDIATE

: ^-- ( "var" -- )
  POSTPONE AT
  STATE @ IF POSTPONE 1-! ELSE 1-! THEN
; IMMEDIATE

: @-- ( "var" -- n )
  POSTPONE AT
  STATE @ IF POSTPONE DUP POSTPONE @ POSTPONE SWAP POSTPONE 1-!
  ELSE DUP @ SWAP 1-! THEN
; IMMEDIATE

: --@ ( "var" -- n )
  POSTPONE AT
  STATE @ IF POSTPONE DUP POSTPONE 1-! POSTPONE @
  ELSE DUP 1-! @ THEN
; IMMEDIATE
