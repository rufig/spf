\ 01.Nov.2003 Sat 16:04


1024 2* CONSTANT hash-mod 

hash-mod CELLS  CONSTANT /table

CREATE table  /table ALLOT  table /table ERASE

: t[] ( i -- value )
  CELLS table + @
;
: t[]^ ( i -- a )
  CELLS table +
;

VARIABLE ccc

: (transl-chank)
  BEGIN NextWord DUP WHILE
    hash-mod HASH
      DUP hash-mod U< 0= ABORT" Out of range!"
    t[]^ 1+!
    ccc  1+!
  REPEAT 2DROP
;

: rcv ( "ccc" -- )
  &INTERPRET @ >R
  ['] (transl-chank) &INTERPRET !
  ['] INCLUDED CATCH
  R> &INTERPRET !
                        THROW
;

\ === stat
S" stat.f" INCLUDED

\ ===
REQUIRE {    lib\ext\locals.f

: stat. ( -- )
  { \ c }
  hash-mod 0 DO
    I t[]  STAT+
    I t[]  ^ c +!
  LOOP
  STAT. ." | " ccc @ .  
  ." | " c .
;

\ =================
