( Обработка ошибок.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  Ревизия: Cентябрь 1999
)

VECT ERROR      \ обработчик ошибок (ABORT)
VECT (ABORT")
USER ER-A
USER ER-U

128 CHARS CONSTANT /errstr_
0 \
1 CELLS     -- err.number
1 CELLS     -- err.line#
1 CELLS     -- err.in#
1 CHARS     -- err.notseen \ flag
[T] /errstr_ [I]
  CELL+     -- err.line
[T] /errstr_ [I]
  CELL+     -- err.file
CONSTANT /err-data

USER-CREATE ERR-DATA [T] /err-data [I] TC-USER-ALLOT
\ область, содержащая местоположение строки и саму строку

: SEEN-ERR? ( -- flag )
  ERR-DATA err.notseen C@ 0=
;
: SEEN-ERR  ( -- )
\ установить флаг, что видели ошибку.
  0 ERR-DATA err.notseen C!
;
: NOTSEEN-ERR  ( -- )
\ установить флаг, что не видели ошибку.
  -1 ERR-DATA err.notseen C!
;
: ERR-NUMBER ( -- ior ) \ номер ошибки
  ERR-DATA err.number @
;
: ERR-LINE# ( -- num ) \ номер траслируемой строки
  ERR-DATA err.line# @
;
: ERR-IN#   ( -- num ) \ указатель разобранной части >IN
  ERR-DATA err.in#   @
;
: ERR-LINE  ( -- a u ) \ строка SOURCE в момент ошибки
  ERR-DATA err.line COUNT
;
: ERR-FILE  ( -- a u ) \ имя траслируемого файла
  ERR-DATA err.file COUNT
;
: ERR-STRING ( -- a u )
\ формирует строку для LAST-WORD  по ERR-DATA
  BASE @ DECIMAL
  <#
  ERR-LINE HOLDS
  EOLN HOLDS

  S" :" HOLDS
  ERR-IN# 0 #S 2DROP
  S" :" HOLDS
  ERR-LINE# 0 #S 2DROP
  S" :" HOLDS
  ERR-FILE HOLDS
  S"  at: " HOLDS
  ERR-NUMBER DUP ABS 0 #S 2DROP 0< IF [CHAR] - HOLD THEN [CHAR] # HOLD
  S" Exception " HOLDS
  0 0 #> ROT BASE !
;

\ Заменяет при печати нулевые символы пробелами
: TYPE0 ( a n -- )
  OVER + SWAP ?DO
    I C@ ?DUP 0= IF BL THEN EMIT
  LOOP
;

: LAST-WORD ( -- )
  SEEN-ERR?
  IF
    SOURCE OVER >IN @ SCREEN-LENGTH
  ELSE
    SEEN-ERR
    ERR-STRING
    ERR-LINE DROP ERR-IN# SCREEN-LENGTH
  THEN

  -ROT TYPE0 CR
  2- 0 MAX SPACES [CHAR] ^ EMIT SPACE
;

: ?ERROR ( F, N -> )
  SWAP IF THROW ELSE DROP THEN
;

: (ABORT1") ( flag c-addr -- )
  SWAP IF COUNT ER-U ! ER-A ! -2 THROW ELSE DROP THEN
;

: SAVE-ERR ( err-num -- )
\ сохранить текущую PARSE-AREA (строка by SOURCE ) 
\ и параметры входного потока CURFILE, CURSTR  в область ERR-DATA
\ Цель - дальнейшая индикация  места,  вызвавшего исключение.

  ERR-DATA err.number !
  CURSTR @   ERR-DATA err.line# !
  >IN @      ERR-DATA err.in#   !
  SOURCE /errstr_ >CHARS UMIN  DUP
             ERR-DATA err.line C!   
             ERR-DATA err.line CHAR+ SWAP  CMOVE
          0  ERR-DATA err.line COUNT CHARS + C!
  CURFILE @ ?DUP IF ASCIIZ> ELSE S" H-STDIN" THEN
  /errstr_ >CHARS UMIN  DUP
             ERR-DATA err.file C!
             ERR-DATA err.file CHAR+ SWAP CHARS MOVE
          0  ERR-DATA err.file COUNT CHARS + C!
  NOTSEEN-ERR
;
