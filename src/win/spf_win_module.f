\ $Id$

: is_path_delimiter ( c -- flag )
  DUP [CHAR] \ = SWAP [CHAR] / = OR
;

: ModuleName ( -- addr u )
  1024 SYSTEM-PAD 0 GetModuleFileNameA
  SYSTEM-PAD SWAP
;
