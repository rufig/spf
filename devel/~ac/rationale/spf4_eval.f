: Eval ( -- )
  BEGIN
    NextWord ?DUP
  WHILE
    TranslateWord
  REPEAT DROP
;
