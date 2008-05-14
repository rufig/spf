\ Andrey Filatkin, af@forth.org.ru
\ Work in spf3, spf4
\ ”правл€ющие структуры, работающие в режиме интерпретации
\ использован код из
\ http://wiki.forth.org.ru/Ќе €вна€ компил€ци€  -  ~mak
\ первоначальна€ иде€ - Oleg Minin -
\ http://wiki.forth.org.ru/—н€тие ограничений на использование управл€ющих констукций

USER SAVE_CN USER SAVE_DP USER SAVE_AL

: DO-MDSW:
  STATE @ 0=
  IF
    99999 ALLOCATE THROW SAVE_AL !
    HERE SAVE_DP !
    SAVE_AL @ DP !
    1 SAVE_CN !
     :NONAME
  ELSE
    SAVE_CN @ IF SAVE_CN 1+! THEN
  THEN
;
: MDSW:
  :
  POSTPONE DO-MDSW:
  ' COMPILE,
  POSTPONE ; IMMEDIATE
;
: DO-MDSW;
  SAVE_CN @
  IF SAVE_CN @ 1- SAVE_CN !
    SAVE_CN @ 0= IF
      POSTPONE ;
      SAVE_DP @ DP !
      EXECUTE
      SAVE_AL @ FREE DROP
    THEN
  THEN
;
: MDSW; 
  :
  ' COMPILE,
  POSTPONE DO-MDSW;
  POSTPONE ;  IMMEDIATE
;

FALSE WARNING !
MDSW: DO  DO
MDSW: ?DO ?DO
MDSW; LOOP LOOP
MDSW; +LOOP +LOOP

MDSW: BEGIN BEGIN
MDSW; UNTIL UNTIL
MDSW; AGAIN AGAIN
MDSW; REPEAT REPEAT

MDSW: IF IF
MDSW; THEN THEN
TRUE WARNING !

\ TEST
( 
HERE

5 0 DO I VALUE LOOP A B C D E

 10 0 DO  I . LOOP CR
 10 BEGIN  1- DUP
    WHILE
      DUP 0 DO
        I DUP 2 MOD IF . ELSE DROP THEN
      LOOP CR
    REPEAT . CR

A . B . C . D . E . CR
)
\ 0 0= IF .( =0) ELSE .( <>0) THEN CR

\ HERE U. U.
