REQUIRE CONT ~profit/lib/bac4th.f

\ Генерирует nfa всех слов из списка wid
: NFA=> ( wid --> nfa )
  PRO
  @
  BEGIN
    DUP
  WHILE 
    ( nfa ) CONT ( nfa )
    CDR ( nfa2 )
  REPEAT
  DROP ;

: VOC> ( xt -- wid ) ALSO EXECUTE CONTEXT @ PREVIOUS ;

\ Определить идентификатор словаря
\ Если vocname не словарь - результат не определен
: [WID] ( "vocname" -- wid ) ' VOC> POSTPONE LITERAL ; IMMEDIATE

\EOF

\ REQUIRE [IF] ib/include/tools.f

: search-nfa2 ( a u wid -- 0 | nfa ) 
\ найти словарную статью для заданного слова в списке wid
\ вернуть его NFA
  START{
    CUT:
    NFA=> 
    >R 2DUP R@ -ROT ( a u nfa a u )
    R> COUNT 2DUP CR TYPE
    COMPARE 0= IF CR ." FOUND" -CUT THEN 
  }EMERGE 
  2DROP ;

: search-nfa 
  @
  BEGIN
    DUP
  WHILE 
    >R 2DUP R@ COUNT COMPARE R> SWAP
  WHILE
    CDR ( nfa2 )
  REPEAT THEN
  >R 2DROP R> ;
