: SEEN-ERR  ( -- )
\ установить флаг, что видели ошибку.
\  0 ERR-DATA err.notseen C!
;
: ERR-LINE# ( -- num ) \ номер траслируемой строки
\  ERR-DATA err.line# @
  CURSTR @
;
: ERR-IN#   ( -- num ) \ указатель разобранной части >IN
\  ERR-DATA err.in#   @
  >IN @
;
