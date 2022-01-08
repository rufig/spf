\ 08.Feb.2008

\ http://fforum.winglion.ru/viewtopic.php?t=1157

REQUIRE EMBODY ~pinka/spf/forthml/index.f

REQUIRE STHROW ~pinka/spf/sthrow.f

REQUIRE 2NIP ~pinka/lib/ext/basics.f


WARNING @ WARNING 0!

: StoN ( c-addr u -- x )
  forthml-hidden::I-LIT IF EXIT THEN `#NaN STHROW
;
: NtoS ( x -- a u ) 
  S>D (D.) \ HERE OVER 2SWAP S,
;

: / ( a b -- c ) DUP 0= IF `#zerro-div STHROW THEN / ;

WARNING !


S" mini.f.xml" FIND-FULLNAME2 EMBODY
