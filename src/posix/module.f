\ $Id$
\

0 VALUE ARGC \ Количество аргументов командной строки
0 VALUE ARGV \ Список аргументов

: is_path_delimiter ( c -- flag )
  [CHAR] / =
;

: ModuleName ( -- addr u )
  ARGV @ ASCIIZ> SYSTEM-PAD SWAP
  DUP >R CMOVE SYSTEM-PAD R>
;
