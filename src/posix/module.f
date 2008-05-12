\ $Id$
\

0 VALUE ARGC \ Количество аргументов командной строки
0 VALUE ARGV \ Список аргументов

: is_path_delimiter ( c -- flag )
  [CHAR] / =
;

: ModuleName ( -- addr u )
  (( S" /proc/self/exe" DROP SYSTEM-PAD 1024 )) readlink
  DUP -1 = IF DROP 0 THEN
  SYSTEM-PAD SWAP 
  \ NB: not asciiz!
  \ 2DUP + 0 SWAP C!
;
