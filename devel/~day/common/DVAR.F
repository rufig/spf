\ Работа с переменными двойной длины


: D=
  DNEGATE D+ OR 0=
;
: D, , , ;

: D@ DUP CELL+ @ SWAP @ ;
: D! DUP >R ! R> CELL+ ! ;

: DVAR 
    CREATE 0. D, DOES>
;
: DCONST 
    CREATE D, DOES> D@ 
;
