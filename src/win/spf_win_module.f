USER CURFILE

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

: +LibraryDirName ( addr u -- addr2 u2 )
\ Добавить addr u к полный_путь_приложения+devel\
  2>R
  ModuleDirName 2DUP +
  S" devel\" ROT SWAP MOVE
  6 + 2DUP +
  2R> DUP >R ROT SWAP 1+ MOVE 
  R> +
;
: SOURCE-NAME ( -- a u )
  CURFILE @ DUP IF ASCIIZ> ELSE 0 THEN
;
: is_path_delimiter ( c -- flag )
  DUP [CHAR] \ = SWAP [CHAR] / = OR
;
: CUT-PATH ( a u -- a u1 )
\ из строки "path\name" выделить строку "path\"
  OVER +
  BEGIN 2DUP <> WHILE DUP C@ is_path_delimiter 0= WHILE 1- REPEAT 1+ THEN
  OVER -
;
: +SourcePath ( addr u -- addr2 u2 )
  SOURCE-NAME CUT-PATH DUP >R
  PAD SWAP MOVE
  DUP R@ + R> PAD + SWAP >R SWAP 1+ MOVE
  PAD R> 
;
