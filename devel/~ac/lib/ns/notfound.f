\ NOTFOUND для SPF/Linux

: NOTFOUND ( a u -- )
\ обращение к словам в словарях в виде  vocname1::wordname
\ или vocname1::vocname2::wordname и т.п.
\ или vocname1:: wordname
  2DUP 2>R ['] ?SLITERAL CATCH ?DUP IF NIP NIP 2R>
  2DUP S" ::" SEARCH 0= IF 2DROP 2DROP THROW  THEN \ Вообще есть :: ?
  2DROP ROT DROP
  GET-ORDER  N>R
                         BEGIN ( a u )
    2DUP S" ::" SEARCH   WHILE ( a1 u1 a3 u3 )
    2 -2 D+ ( пропуск разделителя :: )  2>R
    R@ - 2 - SFIND              IF
    SP@ >R
    ALSO EXECUTE SP@ R> - 0=
    IF CONTEXT ! THEN
                                ELSE  ( a1 u' )
    RDROP RDROP
    NR>  SET-ORDER
    -2011 THROW                 THEN
    2R>                  REPEAT
  NIP 0= IF 2DROP NextWord THEN
  ['] EVAL-WORD CATCH
  NR> SET-ORDER THROW
 ELSE RDROP RDROP THEN
;
