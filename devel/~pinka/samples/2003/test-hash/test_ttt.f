\ 09.Oct.2003 Thu 17:24

REQUIRE [IF] lib\include\tools.f
REQUIRE {    lib\ext\locals.f

REQUIRE bin2gray  ..\gray.f


1 [IF]
S" "
: HASH { a u u1 \ h -- u2 } 
 0 -> h    a u + -> u
 BEGIN a u < WHILE
   h 5 LSHIFT 1+ a C@ +   -> h  a 1+ -> a
   h ?DUP IF 0x80000000 AND 1 AND  h XOR -> h THEN
 REPEAT  h
 u1 UMOD
;

[THEN]


1 [IF]

: HASH { a u u1 \ h -- u2 } 
 0 -> h    a u + -> u
 BEGIN a u < WHILE
   h 5 LSHIFT 1+ a C@ +   -> h  a 1+ -> a
   h ?DUP IF 0x80000000 AND 1 AND  h XOR -> h THEN
 REPEAT  h
 u1 UMOD
;

[THEN]

: _HASH  ( addr u u1 -- u2 )
[ BASE @ HEX
 57  C, 87  C, 45  C, 0  C,
 8B  C, C8  C, 81  C, F0  C,
 AA  C, AA  C, AA  C, AA  C,
 33  C, DB  C, 33  C, F6  C,
 8B  C, 55  C, 4  C, C1  C,
 C0  C, 6  C, 32  C, 4  C,
 13  C, 43  C, E2  C, F7  C,
 80  C, 7D  C, 0  C, 0  C,
 F  C, 84  C, 7  C, 0  C,
 0  C, 0  C, 33  C, D2  C,
 F7  C, 75  C, 0  C, 8B  C,
 C2  C, 8D  C, 6D  C, 8  C,
 5F  C, C3  C, 0  C, 0  C,

BASE ! ] ;


1 7 LSHIFT CONSTANT hash-mod  \
.( hash-mod ) hash-mod . CR

CREATE str1 S" A" S",

str1 COUNT hash-mod HASH  VALUE hash1

0 [IF]
\ просто max-(разность по модулю)

: fitness ( c -- w )
  <# HOLD 0. #> 
  DUP IF
    hash-mod HASH
    hash1 -  ABS NEGATE hash-mod +
  ELSE 2DROP 0 THEN
;

[THEN]

: bits1 ( x -- n )
  { \ c }
  BEGIN DUP WHILE DUP 1 AND IF ^ c 1+! THEN 1 RSHIFT REPEAT
  DROP c
;

1 [IF]
\ число совпадающих битов,
: fitness ( c -- w )
  <# HOLD 0. #>
  DUP IF
    hash-mod HASH
    hash1 XOR -1 XOR  bits1
  ELSE 2DROP 0 THEN
;
[THEN]


: ttt
  200 0 DO  I fitness . CR LOOP
;

: tt1
  200 0 DO  I bin2gray fitness . CR LOOP
;

: tt2
  200 0 DO  
    I <#  DUP HOLD HOLD    S" ABC" HOLDS     0. #>
    hash-mod HASH . CR
  LOOP
;
