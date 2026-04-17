\ $Id$
\

TARGET-POSIX [IF]
S" src/posix/module.f" INCLUDED
[ELSE]
S" src/win/spf_win_module.f" INCLUDED
[THEN]

USER CURFILE

: CROP ( a1 u1 a-dst u-dst-max -- a-rest u-rest )
  DUP >R ROT UMIN DUP >R 2DUP + >R  MOVE R> 2R> -
;
: CROP- ( a-dst u-dst-max a1 u1 -- a-rest u-rest )
  ROT DUP >R UMIN >R SWAP R@ 2DUP + >R MOVE R> 2R> -
;

: CUT-PATH ( a u -- a u1 )
\ Из строки a u выделить часть от начала до последнего
\ символа разделителя каталогов (включительно)
\ "some/path/name" -> "some/path/"
\ "some/path/" -> "some/path/"
\ "name" -> ""
\ Исходная строка остается неизменной (r/o).
  CHARS OVER +
  BEGIN 2DUP <> WHILE CHAR- DUP C@ is_path_delimiter UNTIL CHAR+ THEN
  OVER - >CHARS
;
\ A better name for the above word:
SYNONYM PATH-PREFIX CUT-PATH

: ModuleDirName ( -- addr u )
  ModuleName CUT-PATH
;

: +ModuleDirName ( addr u -- addr2 u2 )
\ Добавить addr u к "полный_путь_приложения/"
  2>R
  ModuleDirName 2DUP +
  2R> DUP >R ROT SWAP CHAR+ CHARS MOVE
  R> +
;

: +LibraryDirName ( addr u -- addr2 u2 )
\ Добавить addr u к "полный_путь_приложения/devel/"
  2>R
  ModuleDirName 2DUP +
  S" devel/" ROT SWAP CHARS MOVE
  6 + 2DUP +
  2R> DUP >R ROT SWAP CHAR+ CHARS MOVE
  R> +
;

: SOURCE-PATH ( -- sd.path )
  CURFILE @ DUP IF ASCIIZ> ELSE 0 THEN
;
\ Given words like `NAME>` and `FIND-NAME`, where "NAME" stands for "nt" (name token, a single-cell id),
\ `SOURCE-NAME` is an unfortunate name for the above word. Provide this name for backward compatibility only.
SYNONYM SOURCE-NAME SOURCE-PATH
