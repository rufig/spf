\ $Id$
\ Если имя файла не содержит путь, то к нему в качестве пути прибавляется
\ текущий каталог

WINAPI: GetCurrentDirectoryA   KERNEL32.DLL

: is_path_delimiter ( c -- flag )
  DUP [CHAR] \ = SWAP [CHAR] / = OR
;
: is_path ( a u -- f )
  OVER + SWAP DO
    I C@ is_path_delimiter IF TRUE UNLOOP EXIT THEN
  LOOP
  FALSE
;
: end\ ( a u1 -- a u2)
  2DUP + 1- C@ is_path_delimiter 0= IF
    2DUP + [CHAR] \ OVER C!
    0 SWAP 1+ C!
    1+
  THEN
;
: GetCurDirectory ( -- a u )
  PAD DUP 1024 GetCurrentDirectoryA
  end\
;
: GetFullName ( a1 u1 -- a2 u2)
  2DUP is_path 0= IF
    2>R
    GetCurDirectory 2DUP +
    2R> DUP >R ROT SWAP 1+ MOVE 
    R> +
  THEN
;
