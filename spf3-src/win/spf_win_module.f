: ModuleName ( -- addr u )
  1024 PAD 0 GetModuleFileNameA
  PAD SWAP
;
: ModuleDirName ( -- addr u )
  ModuleName OVER >R +
  BEGIN
    1- DUP C@ [CHAR] \ = OVER R@ = OR
    IF 0 SWAP 1+ C! TRUE ELSE FALSE THEN
  UNTIL 
  R> ASCIIZ>
;
: +ModuleDirName ( addr u -- addr2 u2 )
  2>R
  ModuleDirName 2DUP +
  2R> DUP >R ROT SWAP 1+ MOVE 
  R> +
;

