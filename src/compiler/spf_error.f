( ќбработка ошибок.
  Copyright [C] 1992-1999 A.Cherezov ac@forth.org
  –евизи€: Cент€брь 1999
)

VECT ERROR      \ обработчик ошибок (ABORT)
VECT (ABORT")
USER ER-A
USER ER-U

128 CONSTANT /errstr_
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
\ область, содержаща€ местоположение строки и саму строку

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
: ERR-FILE  ( -- a u ) \ им€ траслируемого файла
  ERR-DATA err.file COUNT
;
: ERR-STRING ( -- a u )
\ формирует строку дл€ LAST-WORD  по ERR-DATA
  <#
  ERR-LINE HOLDS
  LT LTL @ HOLDS

  S" :" HOLDS
  ERR-IN# 0 #S 2DROP
  S" :" HOLDS
  ERR-LINE# 0 #S 2DROP
  S" :" HOLDS
  ERR-FILE HOLDS
  S"  at: " HOLDS
  ERR-NUMBER DUP ABS 0 #S 2DROP 0< IF [CHAR] - HOLD THEN [CHAR] # HOLD
  S" Exception " HOLDS
  0 0 #>
;
: LAST-WORD ( -- )
  SEEN-ERR?            IF
  >IN @  SOURCE        ELSE
  SEEN-ERR
  ERR-IN# ERR-STRING   THEN

  TYPE  CR
  2- 0 MAX SPACES [CHAR] ^ EMIT SPACE
;

: ?ERROR ( F, N -> )
  SWAP IF THROW ELSE DROP THEN
;

: (ABORT1") ( flag c-addr -- )
  SWAP IF COUNT ER-U ! ER-A ! -2 THROW ELSE DROP THEN
;

