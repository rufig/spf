\ замена реализации слова OLD-WORD на NEW-WORD
\ без перекомпиляции
( в начало старого слова вставляется переход на новое)

BASE @ HEX
: JMP ( addr-to addr-from -- )
  >R
  0E9 R@ C!
  R@ 1+ CELL+ - R> 1+ !
;
BASE !

\ ' NEW-WORD ' OLD-WORD JMP
