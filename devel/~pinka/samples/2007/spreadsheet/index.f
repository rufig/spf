\ 08.Feb.2008

\ http://fforum.winglion.ru/viewtopic.php?t=1157

REQUIRE EMBODY ~pinka/spf/forthml/index.f

: STHROW ( addr u -- )  ER-U ! ER-A ! -2 THROW ;

: SCATCH ( -- addr u true | false ) 
  CATCH
  DUP 0EQ IF EXIT THEN
  DUP -2 NEQ IF THROW THEN
  DROP ER-A @ ER-U @ TRUE
;

: 2NIP 2SWAP 2DROP ;

: StoN ( c-addr u -- x )
  forthml-hidden::I-LIT IF EXIT THEN `#NaN STHROW
;
: NtoS ( x -- a u ) 
  S>D (D.) \ HERE OVER 2SWAP S,
;

WARNING @ WARNING 0!
: / ( a b -- c ) DUP 0= IF `#zerro-div STHROW THEN / ;
WARNING !

S" mini.f.xml" FIND-FULLNAME2 EMBODY
